module main

import encoding.binary
import json2
import net.unix
import os
import os.filelock
import time

const ipc_magic = 'i3-ipc'
const ipc_header_size = 14
const ipc_max_payload = 16 * 1024 * 1024
const ipc_command = u32(0)
const ipc_get_workspaces = u32(1)
const ipc_subscribe = u32(2)
const ipc_get_tree = u32(4)
const ipc_event_window = u32(0x80000003)
const max_history_entries = 2
const log_rotate_size = i64(1024 * 1024)
const reconnect_initial_ms = 250
const reconnect_max_ms = 5000

struct Workspace {
	id      i64
	focused bool
}

struct Node {
	id             i64
	focused        bool
	type_          string @[json: 'type']
	nodes          []Node
	floating_nodes []Node
}

struct WindowEvent {
	change    string
	container Node
}

struct IpcMessage {
	message_type u32
	payload      string
}

struct CommandResult {
	success bool
	error   string
}

struct SubscriptionResult {
	success bool
}

struct RuntimePaths {
	dir     string
	log     string
	log_old string
	lock    string
}

fn runtime_paths() !RuntimePaths {
	uid := os.getuid()
	base := os.getenv_opt('XDG_RUNTIME_DIR') or { '/tmp' }
	dir := os.join_path(base, 'sway-mru-${uid}')
	os.mkdir_all(dir)!
	os.chmod(dir, 0o700) or {}
	return RuntimePaths{
		dir:     dir
		log:     os.join_path(dir, 'mru-window.log')
		log_old: os.join_path(dir, 'mru-window.log.old')
		lock:    os.join_path(dir, 'track.lock')
	}
}

fn rotate_log(paths RuntimePaths) {
	if !os.exists(paths.log) {
		return
	}
	info := os.stat(paths.log) or { return }
	if info.size < log_rotate_size {
		return
	}
	os.rm(paths.log_old) or {}
	os.mv(paths.log, paths.log_old) or {}
}

fn log_line(paths RuntimePaths, level string, event string, details string) {
	rotate_log(paths)
	mut line := '${time.now().format_rfc3339()} level=${level} event=${event}'
	if details != '' {
		line += ' ${details}'
	}
	mut file := os.open_append(paths.log) or {
		eprintln('mru-window: cannot open log: ${err}')
		return
	}
	defer {
		file.close()
	}
	file.writeln(line) or { eprintln('mru-window: cannot write log: ${err}') }
}

fn state_file(paths RuntimePaths, workspace_id i64) string {
	return os.join_path(paths.dir, 'workspace-${workspace_id}')
}

fn parse_history_text(text string) []i64 {
	mut result := []i64{}
	for raw_line in text.split_into_lines() {
		line := raw_line.trim_space()
		if line.len == 0 {
			continue
		}
		id := line.i64()
		if id <= 0 || id in result {
			continue
		}
		result << id
		if result.len == max_history_entries {
			break
		}
	}
	return result
}

fn read_history(paths RuntimePaths, workspace_id i64) []i64 {
	path := state_file(paths, workspace_id)
	text := os.read_file(path) or { return []i64{} }
	return parse_history_text(text)
}

fn write_history_entries(paths RuntimePaths, workspace_id i64, entries []i64) ! {
	path := state_file(paths, workspace_id)
	tmp := '${path}.tmp.${os.getpid()}.${time.now().unix_micro()}'
	mut unique := []i64{}
	for id in entries {
		if id <= 0 || id in unique {
			continue
		}
		unique << id
		if unique.len == max_history_entries {
			break
		}
	}
	mut text := ''
	for id in unique {
		text += '${id}\n'
	}
	os.write_file(tmp, text)!
	os.chmod(tmp, 0o600) or {}
	os.mv(tmp, path) or {
		os.rm(tmp) or {}
		return err
	}
}

fn record_focus(paths RuntimePaths, workspace_id i64, focused_id i64) ! {
	mut entries := []i64{cap: max_history_entries}
	entries << focused_id
	for id in read_history(paths, workspace_id) {
		if id != focused_id {
			entries << id
		}
		if entries.len == max_history_entries {
			break
		}
	}
	write_history_entries(paths, workspace_id, entries)!
}

fn read_exact(mut conn unix.StreamConn, size int) ![]u8 {
	mut buf := []u8{len: size}
	mut offset := 0
	for offset < size {
		read_count := conn.read(mut buf[offset..])!
		if read_count <= 0 {
			return error('unexpected EOF while reading IPC message')
		}
		offset += read_count
	}
	return buf
}

fn write_request(mut conn unix.StreamConn, message_type u32, payload string) ! {
	if payload.len > ipc_max_payload {
		return error('IPC request payload exceeds limit')
	}
	mut frame := []u8{len: ipc_header_size + payload.len}
	for index, byte in ipc_magic.bytes() {
		frame[index] = byte
	}
	binary.little_endian_put_u32(mut frame[6..10], u32(payload.len))
	binary.little_endian_put_u32(mut frame[10..14], message_type)
	for index, byte in payload.bytes() {
		frame[ipc_header_size + index] = byte
	}
	written := conn.write(frame)!
	if written != frame.len {
		return error('short IPC write: wrote ${written} of ${frame.len} bytes')
	}
}

fn read_message(mut conn unix.StreamConn) !IpcMessage {
	header := read_exact(mut conn, ipc_header_size)!
	if header[..6].bytestr() != ipc_magic {
		return error('invalid IPC magic')
	}
	payload_len := binary.little_endian_u32(header[6..10])
	if payload_len > u32(ipc_max_payload) {
		return error('IPC payload exceeds ${ipc_max_payload} bytes')
	}
	message_type := binary.little_endian_u32(header[10..14])
	payload_bytes := read_exact(mut conn, int(payload_len))!
	return IpcMessage{
		message_type: message_type
		payload:      payload_bytes.bytestr()
	}
}

fn sway_socket_path() !string {
	path := os.getenv('SWAYSOCK')
	if path.len == 0 {
		return error('SWAYSOCK is not set')
	}
	return path
}

fn ipc_request(message_type u32, payload string) !IpcMessage {
	path := sway_socket_path()!
	mut conn := unix.connect_stream(path)!
	defer {
		conn.close() or {}
	}
	write_request(mut conn, message_type, payload)!
	return read_message(mut conn)!
}

fn focused_workspace_id() !i64 {
	message := ipc_request(ipc_get_workspaces, '')!
	if message.message_type != ipc_get_workspaces {
		return error('unexpected GET_WORKSPACES response type ${message.message_type}')
	}
	workspaces := json2.decode[[]Workspace](message.payload)!
	for workspace in workspaces {
		if workspace.focused {
			return workspace.id
		}
	}
	return error('no focused workspace')
}

fn get_tree() !Node {
	message := ipc_request(ipc_get_tree, '')!
	if message.message_type != ipc_get_tree {
		return error('unexpected GET_TREE response type ${message.message_type}')
	}
	return json2.decode[Node](message.payload)!
}

fn run_command(command string) ! {
	message := ipc_request(ipc_command, command)!
	if message.message_type != ipc_command {
		return error('unexpected command response type ${message.message_type}')
	}
	results := json2.decode[[]CommandResult](message.payload)!
	if results.len == 0 {
		return error('empty Sway command response')
	}
	for result in results {
		if !result.success {
			detail := if result.error != '' { result.error } else { message.payload }
			return error('Sway command failed: ${detail}')
		}
	}
}

fn find_workspace(node Node, workspace_id i64) ?Node {
	if node.type_ == 'workspace' && node.id == workspace_id {
		return node
	}
	for child in node.nodes {
		if result := find_workspace(child, workspace_id) {
			return result
		}
	}
	for child in node.floating_nodes {
		if result := find_workspace(child, workspace_id) {
			return result
		}
	}
	return none
}

fn collect_ids(node Node, mut ids map[i64]bool, focused_id i64) i64 {
	mut found_id := focused_id
	if node.id > 0 {
		ids[node.id] = true
	}
	if node.focused {
		found_id = node.id
	}
	for child in node.nodes {
		found_id = collect_ids(child, mut ids, found_id)
	}
	for child in node.floating_nodes {
		found_id = collect_ids(child, mut ids, found_id)
	}
	return found_id
}

fn toggle(paths RuntimePaths) ! {
	workspace_id := focused_workspace_id() or { return }
	path := state_file(paths, workspace_id)
	if !os.exists(path) {
		run_command('focus next')!
		return
	}
	root := get_tree()!
	workspace := find_workspace(root, workspace_id) or {
		run_command('focus next')!
		return
	}
	mut valid_ids := map[i64]bool{}
	current_id := collect_ids(workspace, mut valid_ids, i64(0))

	history := read_history(paths, workspace_id)
	mut cleaned := []i64{}
	mut target := i64(0)
	for id in history {
		if !valid_ids[id] {
			continue
		}
		cleaned << id
		if target == 0 && id != current_id {
			target = id
		}
	}
	if cleaned != history {
		write_history_entries(paths, workspace_id, cleaned) or {
			log_line(paths, 'error', 'state_cleanup_failed',
				'workspace=${workspace_id} error="${err.msg()}"')
		}
	}
	if target > 0 {
		run_command('[con_id=${target}] focus')!
	} else {
		run_command('focus next')!
	}
}

fn track_subscription(paths RuntimePaths) ! {
	path := sway_socket_path()!
	mut conn := unix.connect_stream(path)!
	defer {
		conn.close() or {}
	}
	write_request(mut conn, ipc_subscribe, '["window"]')!
	response := read_message(mut conn)!
	if response.message_type != ipc_subscribe {
		return error('unexpected subscription response type ${response.message_type}')
	}
	subscription := json2.decode[SubscriptionResult](response.payload)!
	if !subscription.success {
		return error('subscription rejected: ${response.payload}')
	}
	log_line(paths, 'info', 'subscribed', '')
	for {
		message := read_message(mut conn)!
		if message.message_type != ipc_event_window {
			continue
		}
		event := json2.decode[WindowEvent](message.payload) or {
			log_line(paths, 'warn', 'event_decode_failed', 'error="${err.msg()}"')
			continue
		}
		if event.change != 'focus' || event.container.id <= 0 {
			continue
		}
		workspace_id := focused_workspace_id() or {
			log_line(paths, 'warn', 'workspace_lookup_failed', 'error="${err.msg()}"')
			continue
		}
		record_focus(paths, workspace_id, event.container.id) or {
			log_line(paths, 'error', 'state_write_failed',
				'workspace=${workspace_id} error="${err.msg()}"')
		}
	}
}

fn track(paths RuntimePaths) ! {
	mut instance_lock := filelock.new(paths.lock)
	if !instance_lock.try_acquire() {
		log_line(paths, 'info', 'duplicate_tracker_rejected', 'pid=${os.getpid()}')
		return
	}
	defer {
		instance_lock.release()
	}
	log_line(paths, 'info', 'start', 'pid=${os.getpid()}')
	mut delay_ms := reconnect_initial_ms
	for {
		track_subscription(paths) or {
			log_line(paths, 'warn', 'ipc_disconnected', 'error="${err.msg()}" retry_ms=${delay_ms}')
			time.sleep(delay_ms * time.millisecond)
			delay_ms *= 2
			if delay_ms > reconnect_max_ms {
				delay_ms = reconnect_max_ms
			}
			continue
		}
		delay_ms = reconnect_initial_ms
	}
}

fn usage(program string) {
	eprintln('Usage: ${program} {track|toggle}')
}

fn main() {
	paths := runtime_paths() or {
		eprintln('mru-window: ${err}')
		exit(1)
	}
	if os.args.len != 2 {
		usage(os.args[0])
		exit(2)
	}
	match os.args[1] {
		'track' {
			track(paths) or {
				log_line(paths, 'error', 'tracker_failed', 'error="${err.msg()}"')
				eprintln('mru-window: ${err}')
				exit(1)
			}
		}
		'toggle' {
			toggle(paths) or {
				log_line(paths, 'error', 'toggle_failed', 'error="${err.msg()}"')
				eprintln('mru-window: ${err}')
				exit(1)
			}
		}
		else {
			usage(os.args[0])
			exit(2)
		}
	}
}
