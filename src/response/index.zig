// TODO: create send200, send404 function
// both takes io, connection
// returns void
// create fixed response message for each
// 1st line: http version, status message
// 2nd line: content-length
// 3rd line: connection closed
// 4th line: empty
// 5th line: html
// create stream writer
// put message in writer

const std = @import("std");

pub fn send200(io: std.Io, connection: std.Io.net.Stream) !void {
    const content = "<html><body><h1>this is good</h1></body></html>";
    const message = ("HTTP1.1 OK" ++ "\nContent-Length: 47" ++ "\nConnection: Closed" ++ "\n" ++ "\n" ++ content);
    var connection_writer = connection.writer(io, &.{});
    _ = try connection_writer.interface.write(message); // TODO: usize 리턴하는데 이게 무슨 뜻인지 모르겠다
    std.debug.print("---- this is 200\n", .{});
}
pub fn send404(io: std.Io, connection: std.Io.net.Stream) !void {
    const content = "<html><body><h1>this is NOT FOUND</h1></body></html>";
    const message = ("HTTP1.1 Not Found" ++ "\nContent-Length: 52" ++ "\nConnection: Closed" ++ "\n" ++ "\n" ++ content);
    var connection_writer = connection.writer(io, &.{});
    _ = try connection_writer.interface.write(message); // TODO= usize 리턴하는데 이게 무슨 뜻인지 모르겠다
    std.debug.print("---- this is 404\n", .{});
}
