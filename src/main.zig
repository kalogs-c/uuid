const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    const id = uuid.UUIDv4();
    std.debug.print("Generate UUIDs like these: {s} \n", .{uuid.UUIDToString(id)});
}
