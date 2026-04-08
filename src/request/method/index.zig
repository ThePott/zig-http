const std = @import("std");
const StaticStringMap = std.StaticStringMap; // type을 받고 type을 뱉는 타입 팩토리 함수여서 파스칼 케이스

// textToMethod
// init in method throwable
// checkIsSupported in method

const StringToMethod = StaticStringMap(Method).initComptime(.{.{ "GET", Method.get }});

pub const Method = enum {
    get,

    pub fn init(text: []const u8) !Method {
        const method = StringToMethod.get(text);
        return method.?;
    }
    pub fn checkIsSupported(text: []const u8) bool {
        const method = StringToMethod.get(text);
        if (method) |_| {
            return true;
        }
        return false;
    }
};
