# struct chaining을 중간에 끊으니 오류가 해결됐다. 왜?

- 발생 시각: 2026-04-08 20:00
- 문제: zig-book에서 stuct chaining을 한 줄에 몽땅 하면 될 거 같은데 굳이 두 줄로 나눴길래 난 한 줄에 합쳤는데 오류가
  발생함
- 해결 시각: 2026-04-09 00:21

## 배경

### 책에서의 코드

```zig
pub fn send200(io: std.Io, connection: std.Io.net.Stream) !void {
    const message = "..."
    var connection_writer = connection.writer(io, &.{});
    _ = try connection_writer.interface.write(message);
}
```

### 그냥 끝까지 체이닝하면 되는 거 아닌가?

#### 시도한 코드

```zig
pub fn send200(io: std.Io, connection: std.Io.net.Stream) !void {
    const message = "...";
    const connection_writer = connection.writer(io, &.{}).interface.write;
    _ = try connection_writer(message);
}
```

#### 오류 메시지

```
src/response/index.zig:18:69: error: no field named 'write' in struct 'Io.Writer'
    const connection_writer = connection.writer(io, &.{}).interface.write;
                                                                    ^~~~~
/usr/local/zig/lib/std/Io/Writer.zig:1:1: note: struct declared here
const Writer = @This();
```

- 해석: `write`이라는 필드가 없다 (prop이 없다)

#### 원인

- Zig에서는 메소드를 따로 복사할 수 없다. 무조건 ()으로 호출해야 한다.
- `interface.write`: interface struct에서 write이라는 property를 찾는다. (없음)
- `interface.write()`: interface struct에서 write이라는 method를 찾아서 호출한다. (있음)

### 그럼 메소드 직전까진 체이닝하면 되는 거 아닌가?

#### 시도한 코드

```zig
pub fn send200(io: std.Io, connection: std.Io.net.Stream) !void {
    const message = "...";
    const connection_writer = connection.writer(io, &.{}).interface;
    _ = try connection_writer.write (message);
}
```

#### 에러 메시지

```
Bus error at address 0x65764f6567617373
???:?:?: 0x65764f6567617373 in ??? (???)
/usr/local/zig/lib/std/Io/Writer.zig:539:26: 0x104490daf in write (zig_http)
    return w.vtable.drain(w, &.{bytes}, 1);
                         ^
/Users/haheungju/Desktop/SRC/DRAGON_WARRIOR/ZIG/zig-http/src/response/index.zig:19:36: 0x10459668f in send200 (zig_http)
    _ = try connection_writer.write(message);
```

- 해석: `drain`에서 문제가 생겼다

#### 소스 코드

```zig
pub const Writer = struct {
    io: Io,
    interface: Io.Writer,

    pub fn init(stream: Stream, io: Io, buffer: []u8) Writer {
        return .{
            .io = io,
            .stream = stream,
            .interface = .{
                .vtable = &.{
                    .drain = drain,
                    .sendFile = sendFile,
                },
                .buffer = buffer,
            },
        };
    }

    fn drain(io_w: *Io.Writer, data: []const []const u8, splat: usize) Io.Writer.Error!usize {
        const w: *Writer = @alignCast(@fieldParentPtr("interface", io_w));
        const io = w.io;
        const buffered = io_w.buffered();
        const handle = w.stream.socket.handle;
        const n = io.vtable.netWrite(io.userdata, handle, buffered, data, splat) catch |err| {
            w.err = err;
            return error.WriteFailed;
        };
        return io_w.consume(n);
    }
};
```

#### 해석

- drain은 struct의 포인터(\*Io.Writer)가 필요하다.
- 하지만 한 줄에 interface를 꺼내고 나면 struct의 stack이 정리된다
- 때문에 interface.write을 하려고 하면 drain이 죽은 pointer를 사용해서 문제가 된다

## 분석

### 해결책

- struct까지만 chaining하고 그 이후는 다음에 함
