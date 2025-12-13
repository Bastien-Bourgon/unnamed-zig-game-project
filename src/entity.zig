pub const Position = struct { x: i32, y: i32 };

pub const Transform = struct {
    position: Position,
    rotation: i32,
};

pub const Entity = struct { transform: Transform, name: []const u8, health: u32, canCollide: bool };
