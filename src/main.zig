const std = @import("std");
const z2d = @import("z2d");
const unnamed_zig_game_project = @import("unnamed_zig_game_project");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    std.debug.print("Initialising...\n", .{});
    try unnamed_zig_game_project.initRender();
}
