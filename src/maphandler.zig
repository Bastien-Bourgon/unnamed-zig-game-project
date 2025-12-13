const rl = @import("raylib");
const std = @import("std");

///pub fn drawMap(tiles: []const rl.Texture, tilemap: []i32, width: i32, height: i32) !void {
///    for (1..@intCast(width)) |i| {
///        for (1..@intCast(height)) |j| {
///            rl.drawTexture(tiles[@intCast(tilemap[@intCast((i * j) - 1)])], @intCast(i * 16), @intCast(j * 16), .white);
///        }
///    }
///}
pub fn drawMapfromMapString(tileset: []const rl.Texture, mapstring: []const u8) !void {
    var rows = std.mem.tokenizeAny(u8, mapstring, "|");
    var x: i32 = 0;
    var y: i32 = 0;
    //std.debug.print("{s}", .{rows.buffer});
    while (rows.next()) |column| {
        var tiles = std.mem.tokenizeAny(u8, column, ",");
        while (tiles.next()) |tile| {
            //std.debug.print("{s}", .{tile});
            try drawTile(tileset, try std.fmt.parseInt(i32, tile, 10), x, y);
            x = x + 1;
        }
        x = 0;
        y = y + 1;
    }
}

pub fn drawTile(tileset: []const rl.Texture, tile_id: i32, x: i32, y: i32) !void {
    rl.drawTexture(tileset[@intCast(tile_id)], x * 16, y * 16, .white);
}
