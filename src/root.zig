const uuid = @import("uuid.zig");
const v4 = @import("version4.zig");

pub export fn UUIDv4() uuid.UUID {
    return v4.UUID();
}
