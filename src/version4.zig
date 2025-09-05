const std = @import("std");
const random = std.crypto.random;
const core = @import("uuid.zig");

const poolSize = 16 * 16;
var poolPosition: u16 = poolSize;
var pool: [poolSize]u8 = undefined;

// race condition here :(
pub fn UUID() core.UUID {
    if (poolPosition == poolSize) {
        random.bytes(&pool);
        poolPosition = 0;
    }

    var uuid: core.UUID = undefined;
    @memcpy(uuid[0..16], pool[poolPosition..(poolPosition + 16)]);
    poolPosition += 16;

    uuid[6] = (uuid[6] & 0x0F) | 0x40; // Version 4
    uuid[8] = (uuid[8] & 0x3F) | 0x80; // Variant is 10

    return uuid;
}

test "uuid gen returns 16 bytes" {
    const uuid = UUID();
    try std.testing.expectEqual(16, uuid.len);
}

test "uuid has version 4 in byte 6" {
    const uuid = UUID();
    try std.testing.expectEqual(@as(u8, 0x4), uuid[6] >> 4);
}

test "uuid has RFC4122 variant in byte 8" {
    const uuid = UUID();
    try std.testing.expectEqual(@as(u8, 0b10), (uuid[8] >> 6) & 0b11);
}

test "multiple uuids are unique" {
    const first = UUID();
    const second = UUID();
    const equal = std.mem.eql(u8, &first, &second);
    try std.testing.expect(!equal);
}
