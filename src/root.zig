pub const UUID = @import("uuid.zig").UUID;
pub const UUIDErrors = @import("uuid.zig").UUIDErrors;

pub const UUIDv4 = @import("version4.zig").UUID;
pub const UUIDToString = @import("uuid.zig").toString;
pub const parseUUID = @import("uuid.zig").parse;

test {
    _ = @import("uuid.zig");
    _ = @import("version4.zig");
}
