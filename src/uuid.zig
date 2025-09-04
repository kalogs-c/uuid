const std = @import("std");

pub const UUID = [16]u8;

const hexTable = "0123456789abcdef";

// Non '-' position on stringified uuid
const hexPositions = [16]u8{ 0, 2, 4, 6, 9, 11, 14, 16, 19, 21, 24, 26, 28, 30, 32, 34 };

pub fn toString(uuid: UUID) [36]u8 {
    var uuidStr: [36]u8 = undefined;
    uuidStr[8] = '-';
    uuidStr[13] = '-';
    uuidStr[18] = '-';
    uuidStr[23] = '-';

    inline for (hexPositions, 0..) |i, j| {
        uuidStr[i] = hexTable[uuid[j] >> 4];
        uuidStr[i + 1] = hexTable[uuid[j] & 0x0F];
    }

    return uuidStr;
}

test "toString has length 36" {
    const uuid: UUID = [_]u8{0} ** 16; // all zeroes
    const s = toString(uuid);
    try std.testing.expectEqual(36, s.len);
}

test "toString has dashes at correct positions" {
    const uuid: UUID = [_]u8{0xaa} ** 16;
    const s = toString(uuid);
    try std.testing.expectEqual('-', s[8]);
    try std.testing.expectEqual('-', s[13]);
    try std.testing.expectEqual('-', s[18]);
    try std.testing.expectEqual('-', s[23]);
}

test "toString hex digits are lowercase" {
    const uuid: UUID = [_]u8{0xff} ** 16; // should produce all "ff"
    const s = toString(uuid);

    for (s) |c| {
        if (c == '-') continue;

        const charAllowed = (c >= '0' and c <= '9') or (c >= 'a' and c <= 'f');
        try std.testing.expect(charAllowed);
    }
}

test "toString encodes correctly for known uuid" {
    const uuid: UUID = [_]u8{
        0x12, 0x34, 0x56, 0x78,
        0x9a, 0xbc, 0xde, 0xf0,
        0x12, 0x34, 0x56, 0x78,
        0x9a, 0xbc, 0xde, 0xf0,
    };
    const s = toString(uuid);
    try std.testing.expectEqualStrings("12345678-9abc-def0-1234-56789abcdef0", &s);
}
