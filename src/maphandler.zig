const rl = @import("raylib");
const std = @import("std");

//TODO: Generate tilemap from string on initialisation and pass that to the map drawing function so we don't have to
//      do string parsing shenanigans on every frame, also return collision data (just an area of coordinates of the tiles with collision)

pub const TILE_SIZE = 16;
pub const PUSHBACK_DISTANCE = 0.1;

pub const MapData = struct { mapTiles: std.ArrayList(Tile), collisionData: std.ArrayList(Tile) };

pub const Tile = struct {
    rect: rl.Rectangle,
    texture: rl.Texture,
};

pub fn getLevelDataFromMapString(tileset: []const rl.Texture, mapstring: []const u8) !MapData {
    var rows = std.mem.tokenizeAny(u8, mapstring, "|");
    var mapTiles = std.ArrayList(Tile).empty;
    var collisionData = std.ArrayList(Tile).empty;
    var general_purpose_allocator: std.heap.GeneralPurposeAllocator(.{}) = .init;
    const gpa = general_purpose_allocator.allocator();
    var x: i32 = 0;
    var y: i32 = 0;
    //std.debug.print("{s}", .{rows.buffer});
    while (rows.next()) |column| {
        var tiles = std.mem.tokenizeAny(u8, column, ",");
        while (tiles.next()) |tile| {
            //std.debug.print("{s}", .{tile});
            const tile_id: i32 = try std.fmt.parseInt(i32, tile, 10);
            try mapTiles.append(gpa, Tile{ .texture = tileset[@intCast(tile_id)], .rect = rl.Rectangle{ .x = @floatFromInt(x * 16), .y = @floatFromInt(y * 16), .height = 16.0, .width = 16.0 } });
            if (tile_id == 4) {
                try collisionData.append(gpa, Tile{ .texture = tileset[@intCast(tile_id)], .rect = rl.Rectangle{ .x = @floatFromInt(x * 16), .y = @floatFromInt(y * 16), .height = 16.0, .width = 16.0 } });
            }
            x = x + 1;
        }
        x = 0;
        y = y + 1;
    }
    const mapData = MapData{ .mapTiles = mapTiles, .collisionData = collisionData };
    return mapData;
}

pub fn drawMapTiles(mapTiles: std.ArrayList(Tile)) !void {
    for (mapTiles.items) |value| {
        const tile = value.texture;
        const rect = value.rect;
        try drawTile(tile, @intFromFloat(rect.x), @intFromFloat(rect.y));
    }
}

pub fn drawTile(tile: rl.Texture, x: i32, y: i32) !void {
    rl.drawTexture(tile, x, y, .white);
}

pub const MapCollision = struct {
    collides: bool,
    angle: f32,
    distance: f32,
    collidedHitbox: rl.Vector2,
};

pub fn checkCollisions(playerHitbox: rl.Rectangle, mapCollision: std.ArrayList(Tile), playerPos: rl.Vector2) !MapCollision {
    for (mapCollision.items) |value| {
        const hitbox = value.rect;
        const isPlayerCollidingTile = rl.checkCollisionRecs(playerHitbox, hitbox);
        if (isPlayerCollidingTile) {
            const collisionAngle = playerPos.angle(rl.Vector2{ .x = hitbox.x, .y = hitbox.y });
            std.debug.print("Player is touching tile at {},{} at angle {}\n", .{ hitbox.x / TILE_SIZE, hitbox.y / TILE_SIZE, collisionAngle });
            return MapCollision{ .collides = true, .angle = collisionAngle, .distance = -PUSHBACK_DISTANCE, .collidedHitbox = rl.Vector2{ .x = hitbox.x, .y = hitbox.y } };
        }
    }
    return MapCollision{ .collides = false, .angle = 0.0, .distance = 0.0, .collidedHitbox = rl.Vector2.zero() };
}
