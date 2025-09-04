const uuid = @import("uuid.zig");
const v4 = @import("version4.zig");

pub fn UUIDv4() uuid.UUID {
    return v4.UUID();
}

pub fn UUIDToString(id: uuid.UUID) [36]u8 {
    return uuid.toString(id);
}
