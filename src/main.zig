const std = @import("std");
const rl = @import("raylib");
const entity = @import("entity.zig");
const mem = @import("std").mem;
const unnamed_zig_game_project = @import("unnamed_zig_game_project");
const map = @import("maphandler.zig");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    std.debug.print("Initialising...\n", .{});
    try render();
}

const screenWidth = 1280;
const screenHeight = 720;
const mapWidth = 128;
const mapHeight = 128;

const mapstring = "4,4,4,4,4,4,4,4,4,4|1,1,1,1,1,1,1,1,1,1|1,1,1,1,1,1,1,1,1,1|1,1,1,1,1,1,1,1,1,1|4,4,4,4,4,4,4,4,4,4";

var player_speed: f32 = 2.0;

pub fn render() !void {
    rl.initAudioDevice(); // Initialize audio device
    rl.initWindow(screenWidth, screenHeight, "Project Dreamwave");
    defer rl.closeWindow(); // Close window and OpenGL context
    rl.setTargetFPS(60);
    var camera = rl.Camera2D{
        .target = .init(0, 0),
        .offset = .init(screenWidth / 2, screenHeight / 2),
        .rotation = 0,
        .zoom = 1,
    };

    //Texture initialisation

    //Tiles
    const grass = try rl.Texture.init("img/tiles/grass.png");
    const stone = try rl.Texture.init("img/tiles/stone.png");
    const sand = try rl.Texture.init("img/tiles/sand.png");
    const water = try rl.Texture.init("img/tiles/water.png");
    const tiled_stone = try rl.Texture.init("img/tiles/tiled_stone.png");
    const coal_ore = try rl.Texture.init("img/tiles/coal_ore.png");
    const iron_ore = try rl.Texture.init("img/tiles/iron_ore.png");
    const gold_ore = try rl.Texture.init("img/tiles/gold_ore.png");
    const diamond_ore = try rl.Texture.init("img/tiles/diamond_ore.png");
    const oak_log = try rl.Texture.init("img/tiles/oak_log.png");

    const tile_textures = [10]rl.Texture{ grass, stone, sand, water, tiled_stone, coal_ore, iron_ore, gold_ore, diamond_ore, oak_log };

    //Player
    const player_idle = try rl.Texture.init("img/player/player_idle.png");

    //Entities

    //Texture unloading
    defer rl.unloadTexture(stone);
    defer rl.unloadTexture(grass);
    defer rl.unloadTexture(sand);
    defer rl.unloadTexture(water);
    defer rl.unloadTexture(tiled_stone);
    defer rl.unloadTexture(coal_ore);
    defer rl.unloadTexture(iron_ore);
    defer rl.unloadTexture(gold_ore);
    defer rl.unloadTexture(diamond_ore);
    defer rl.unloadTexture(oak_log);

    //Player object declaration
    var playerPos = rl.Vector2.init(screenWidth / 2, screenHeight / 2);

    //Generating leveldata
    const levelData: map.MapData = try map.getLevelDataFromMapString(&tile_textures, mapstring);
    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------

        camera.target = .init(playerPos.x + 12, playerPos.y + 16);
        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        camera.begin();
        defer camera.end();

        try map.drawMapTiles(levelData.mapTiles);

        const playerHitbox = rl.Rectangle{ .x = playerPos.x, .y = playerPos.y, .height = 32.0, .width = 24.0 };
        const mapCollision = try map.checkCollisions(playerHitbox, levelData.collisionData, playerPos);

        if (mapCollision.collides) {
            playerPos = playerPos.moveTowards(mapCollision.collidedHitbox, mapCollision.distance);
        } else {
            if (rl.isKeyDown(.right)) {
                playerPos.x += player_speed;
            }
            if (rl.isKeyDown(.left)) {
                playerPos.x -= player_speed;
            }
            if (rl.isKeyDown(.up)) {
                playerPos.y -= player_speed;
            }
            if (rl.isKeyDown(.down)) {
                playerPos.y += player_speed;
            }
            if (rl.isKeyDown(.right_shift)) {
                player_speed = 4.0;
            } else {
                player_speed = 2.0;
            }
        }

        rl.drawTextureV(player_idle, playerPos, .white);

        //rl.drawText("Congrats! You created your first window!", 190, 200, 20, .light_gray);
        //----------------------------------------------------------------------------------
    }
}

pub fn drawMap(tiles: []const rl.Texture, tilemap: []i32, width: i32, height: i32) !void {
    for (1..@intCast(width)) |i| {
        for (1..@intCast(height)) |j| {
            rl.drawTexture(tiles[@intCast(tilemap[@intCast((i * j) - 1)])], @intCast(i * 16), @intCast(j * 16), .white);
        }
    }
}
