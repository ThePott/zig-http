const std = @import("std");

// io, connection, buffer 받는다. buffer는 slice다.
// buffer에 읽은 것들을 채워넣는다. (buffer는 slice이고 slice는 pointer이니 가능하다)
// make reader interface from connection and pass it to readLine,
pub fn readRequest(io: std.Io, connection: std.Io.net.Stream, buffer: []u8) !void {
    var reader_buffer: [1024]u8 = undefined;
    var reader = connection.reader(io, &reader_buffer);
    const reader_interface = &reader.interface;

    var start_index: usize = 0;
    for (0..5) |_| {
        const line = try readLine(reader_interface, buffer, start_index);
        start_index += line.len;
    }
}

fn readLine(reader_interface: *std.Io.Reader, buffer: []u8, start_index: usize) ![]const u8 {
    const line = try reader_interface.takeDelimiter('\n');
    @memcpy(buffer[start_index .. start_index + line.?.len], line.?[0..]);
    return line.?;
}
