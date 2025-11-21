const std = @import("std");
const rl = @import("raylib");
const fastnoise = @import("fastnoise.zig");
const mem = @import("std").mem;
const unnamed_zig_game_project = @import("unnamed_zig_game_project");
const perlin = @import("perlin3d.zig");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    std.debug.print("Initialising...\n", .{});
    try render();
    noise.seed = rl.getRandomValue(0, 999);
}

const PERLIN_SCALE = 0.0015;
const PERLIN_OCTAVES = 4;
const PERLIN_FALLOFF = 0.5;

const screenWidth = 1280;
const screenHeight = 720;
const mapWidth = 128;
const mapHeight = 128;

var player_speed: f32 = 2.0;

var noise = fastnoise.Noise(f32){
    .seed = 0,
    .noise_type = .simplex_smooth,
    .frequency = 0.005,
    .gain = 0.40,
    .fractal_type = .fbm,
    .lacunarity = 0.40,
    .octaves = 4,
    .weighted_strength = -0.5,
    .cellular_distance = .euclidean,
    .cellular_return = .distance2,
    .cellular_jitter_mod = 1.0,
};

pub fn render() !void {
    rl.initAudioDevice(); // Initialize audio device
    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
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

    //Player object declaration
    var playerPos = rl.Vector2.init(screenWidth / 2, screenHeight / 2);

    //Tilemap generation
    var tilemap: [mapWidth * mapHeight]i32 = @splat(0);
    //for (0..tilemap.len) |i| {
    //    tilemap[@intCast(i)] = @intFromFloat(std.math.round(perlin.noise1(@floatFromInt(i)) * tile_textures.len));
    //    std.debug.print("{d}\n", .{std.math.round(perlin.noise1(@floatFromInt(i)) * tile_textures.len)});
    //}
    for (1..mapWidth) |i| {
        for (1..mapHeight) |j| {
            const noise_value: f32 = (noise.genNoise2D(@as(f32, @floatFromInt(i)), @as(f32, @floatFromInt(j))) + 1.0) / 2;
            var tile_id: i32 = @intFromFloat(std.math.floor(noise_value * 4));
            std.debug.print("{}\n", .{noise_value});
            switch (tile_id) {
                0 => {
                    const RNG = rl.getRandomValue(0, 1000);
                    if (RNG <= 5) {
                        tile_id = 9;
                    } else {
                        tile_id = 0;
                    }
                },
                1 => {
                    const RNG = rl.getRandomValue(0, 1000);
                    if (RNG <= 1) {
                        tile_id = 8;
                    } else if (RNG <= 5) {
                        tile_id = 7;
                    } else if (RNG <= 15) {
                        tile_id = 6;
                    } else if (RNG <= 30) {
                        tile_id = 5;
                    } else {
                        tile_id = 1;
                    }
                },
                2 => {},
                3 => {},
                else => tile_id = 0,
            }
            tilemap[@intCast((i * j) - 1)] = tile_id;
            //std.debug.print("X:{} Y:{} ID:{}\n", .{ i, j, tile_id });
        }
    }

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
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

        camera.target = .init(playerPos.x + 12, playerPos.y + 16);
        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        camera.begin();
        defer camera.end();

        try drawMap(&tile_textures, &tilemap, mapWidth, mapHeight);

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
