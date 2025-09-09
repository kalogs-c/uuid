const std = @import("std");

pub const UUID = [16]u8;

pub const UUIDErrors = error{
    InvalidUUIDFormat,
};

const hexTable = "0123456789abcdef";

// Non '-' position on stringified uuid
const hexPositions = [16]u8{ 0, 2, 4, 6, 9, 11, 14, 16, 19, 21, 24, 26, 28, 30, 32, 34 };

const hexValuesTable = [256]u8{
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    0,   1,   2,   3,   4,   5,   6,   7,   8,   9,   255, 255, 255, 255, 255, 255,
    255, 10,  11,  12,  13,  14,  15,  255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 10,  11,  12,  13,  14,  15,  255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
};

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

pub fn parse(id: []const u8) !UUID {
    if (id.len != 36 or id[8] != '-' or id[13] != '-' or id[18] != '-' or id[23] != '-')
        return UUIDErrors.InvalidUUIDFormat;

    var uuid: UUID = undefined;
    inline for (hexPositions, 0..) |i, j| {
        const b1 = hexValuesTable[id[i]];
        const b2 = hexValuesTable[id[i + 1]];
        uuid[j] = (b1 << 4) | b2;

        if (b1 == 255 or b2 == 255)
            return UUIDErrors.InvalidUUIDFormat;
    }

    return uuid;
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

test "parse valid uuid string" {
    const s = "12345678-9abc-def0-1234-56789abcdef0";
    const uuid = try parse(s);

    try std.testing.expectEqual(@as(u8, 0x12), uuid[0]);
    try std.testing.expectEqual(@as(u8, 0x34), uuid[1]);
    try std.testing.expectEqual(@as(u8, 0xf0), uuid[7]);
    try std.testing.expectEqual(@as(u8, 0xf0), uuid[15]);
}

test "parse rejects wrong length" {
    const s = "1234"; // too short
    try std.testing.expectError(UUIDErrors.InvalidUUIDFormat, parse(s));
}

test "parse rejects missing dashes" {
    const s = "123456789abcdef0123456789abcdef0"; // 32 hex chars, no dashes
    try std.testing.expectError(UUIDErrors.InvalidUUIDFormat, parse(s));
}

test "parse rejects dashes in wrong place" {
    const s = "12345678-9abc-def0-12345-6789abcdef0"; // dash misplaced
    try std.testing.expectError(UUIDErrors.InvalidUUIDFormat, parse(s));
}

test "parse rejects invalid hex characters" {
    const s = "12345678-9abc-def0-1234-56789abcdeg0"; // 'g' not hex
    try std.testing.expectError(UUIDErrors.InvalidUUIDFormat, parse(s));
}

test "parse and toString round-trip" {
    const original: UUID = [_]u8{
        0x12, 0x34, 0x56, 0x78,
        0x9a, 0xbc, 0xde, 0xf0,
        0x12, 0x34, 0x56, 0x78,
        0x9a, 0xbc, 0xde, 0xf0,
    };

    const s = toString(original);
    const parsed = try parse(&s);

    try std.testing.expectEqualSlices(u8, &original, &parsed);
}
