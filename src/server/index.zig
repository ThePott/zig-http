const std = @import("std");
const Socket = std.Io.net.Socket;
const Protocol = std.Io.net.Protocol;

pub const Server = struct {
    host: []const u8, // "127.0.0.1" , [4]u8을 안 쓰는 이유는 실제 ip를 만드는 Ip4Address.parseIp4 에서 받는 프로퍼티가 []const u8이어서
    port: u16, // TODO: why not const u16?, well it is because type of property of Ip4Address.parseIp4
    address: std.Io.net.IpAddress,
    io: std.Io,

    // io를 받는다. 왜 이거는 받아야 하지? 아직 모르겠다 -> 우선 받은 다음 self에 적용한다.
    // struct init returns self, throwable
    // host and port are defined here.
    // address is created by parseIp4
    // why throwable? parseIp4 might throw
    // init does not take self
    pub fn init(io: std.Io) !Server {
        const host: []const u8 = "127.0.0.1";
        const port: u16 = 3490;
        const address = try std.Io.net.IpAddress.parseIp4(host, port);
        return .{ .host = host, .port = port, .address = address, .io = io };
    }
    // this is method, so it takes self
    // debug print host and port as "server address:"
    // return listen result of address
    // mode: stream
    // protocol: tcp
    pub fn listen(self: Server) !std.Io.net.Server {
        std.debug.print("server address: {s}:{d}\n", .{ self.host, self.port });
        return try self.address.listen(self.io, .{
            .mode = Socket.Mode.stream,
            .protocol = Protocol.tcp,
        });
    }
};
