const std = @import("std");
const zig_http = @import("zig_http");
const Server = @import("./server/index.zig").Server;
const readRequest = @import("./request/index.zig").readRequest;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const server = try Server.init(io);
    var listening = try server.listen();
    // NOTE: 연결 하나 만듦. 여기에 연결 요청 들어오면 연결하고 프로그램 종료됨. 현실이라면 이걸 while loop으로 돌려서 그 다음 연결을 열겠지
    // 연결이 들어오기 전까진 accept()가 실행되지 않고 멈춰있음. 연결이 들어오면 호출되고 connection이 만들어짐
    const connection = try listening.accept(io);
    defer connection.close(io);

    var request_buffer: [1024]u8 = undefined;
    @memset(&request_buffer, 0);
    try readRequest(io, connection, &request_buffer);

    std.debug.print("{s}\n", .{request_buffer});
}

// test "loop for 5 or 6 times" {
//     for (0..5) |index| {
//         std.debug.print("exclude 5?: {d}\n", .{index});
//     }
// }

test "what does index of scalar return" {
    // TODO: how do I convert string(pointer by itself) to slice?
    const sampleText = "first line\nsecond second line\nthird line";
    const line_break_index = std.mem.indexOfScalar(u8, sampleText, '\n');
    std.debug.print("line index: {any}\n", .{line_break_index});
    const iterator = std.mem.splitScalar(u8, sampleText, '\n');
    std.debug.print("iterator: {any}\n", .{iterator});
}
