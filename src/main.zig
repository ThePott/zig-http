const std = @import("std");
const zig_http = @import("zig_http");
const Server = @import("./server/index.zig").Server;
const request_module = @import("./request/index.zig");
const response_module = @import("./response/index.zig");
const Method = @import("./request/method/index.zig").Method;

// TODO:
// import response struct
// check method is get
// check uri is root
// call 200 or 404

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
    try request_module.readRequest(io, connection, &request_buffer);
    std.debug.print("...request_buffer...\n{s}\n", .{request_buffer});

    const request = try request_module.parseRequest(&request_buffer);
    std.debug.print("{any}\n", .{request});

    switch (request.method) {
        .get => {
            std.debug.print("this is get", .{});
            if (std.mem.eql(u8, request.uri, "/")) {
                std.debug.print("trying to 200\n", .{});
                try response_module.send200(io, connection);
            } else {
                std.debug.print("trying to 404\n", .{});
                try response_module.send404(io, connection);
            }
        },
    }
}

test "what does index of scalar return" {
    const sampleText = "first line\nsecond second line\nthird line";
    const line_break_index = std.mem.indexOfScalar(u8, sampleText, '\n').?;
    std.debug.print("line index: {any}\n", .{line_break_index});
    const iterator = std.mem.splitScalar(u8, sampleText, '\n');
    std.debug.print("iterator: {any}\n", .{iterator});
}
