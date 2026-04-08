// TODO: https://pedropark99.github.io/zig-book/Chapters/04-http-server.html#using-the-parse-request-function
const std = @import("std");
const Method = @import("./method/index.zig").Method;

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
    const line = try reader_interface.takeDelimiterInclusive('\n');
    @memcpy(buffer[start_index .. start_index + line.len], line[0..]);
    return line;
}

const Request = struct {
    method: Method,
    uri: []u8,
    version: []u8,
    pub fn init(
        method: Method,
        uri: []u8,
        version: []u8,
    ) Request {
        return .{ .method = method, .uri = uri, .version = version };
    }
};

pub fn parseRequest(text: []u8) !Request {
    const line_break_index = std.mem.indexOfScalar(u8, text, '\n');
    const iterator = std.mem.splitScalar(u8, text[0..line_break_index], ' ');

    const method = try Method.init(iterator.next().?);
    const uri = iterator.next().?;
    const version = iterator.next().?;

    const request = Request.init(method, uri, version);
    return request;
}
