const faces = [_][3]usize{
    //     0-8      9-17
    //    / /      /  /
    //   / /      /  /
    //  1 7---6  10 16--15
    //  2---3 |  11--12  |
    //      4-5      13-14
    //
    // 18---20---29  30---32---41
    // |   /|    |   |   /|    |
    // |  / |    |   |  / |    |
    // | /  |    |   | /  |    |
    // 19   21   28  31   33   40
    //     /    /        /    /
    //    /    /        /    /
    //   /    /        /    /
    // 22   27   25  34   39   37
    // |    |   /|   |    |   /|
    // |    |  / |   |    |  / |
    // |    | /  |   |    | /  |
    // 23---26---24  35---38---36

    // 4 back
    .{ 9, 16, 10 },
    .{ 9, 17, 16 },
    .{ 10, 15, 11 },
    .{ 11, 15, 12 },
    .{ 15, 13, 12 },
    .{ 15, 14, 13 },

    // 2 back
    .{ 30, 32, 31 },
    .{ 32, 41, 33 },
    .{ 41, 40, 33 },
    .{ 33, 40, 39 },
    .{ 33, 39, 34 },
    .{ 34, 39, 35 },
    .{ 39, 38, 35 },
    .{ 38, 37, 36 },

    // 4 sides
    .{ 0, 8, 9 },
    .{ 9, 8, 17 },
    .{ 1, 0, 9 },
    .{ 1, 9, 10 },
    .{ 8, 7, 17 },
    .{ 7, 16, 17 },
    .{ 2, 1, 10 },
    .{ 2, 10, 11 },
    .{ 2, 12, 3 },
    .{ 2, 11, 12 },
    .{ 3, 13, 4 },
    .{ 3, 12, 13 },
    .{ 4, 14, 5 },
    .{ 4, 13, 14 },
    .{ 5, 14, 15 },
    .{ 15, 6, 5 },
    .{ 7, 6, 15 },
    .{ 15, 16, 7 },

    // 2 sides
    .{ 29, 28, 40 },
    .{ 40, 41, 29 },
    .{ 27, 26, 38 },
    .{ 38, 39, 27 },
    .{ 28, 27, 39 },
    .{ 39, 40, 28 },
    .{ 25, 24, 36 },
    .{ 36, 37, 25 },
    .{ 20, 19, 31 },
    .{ 31, 32, 20 },
    .{ 19, 18, 30 },
    .{ 30, 31, 19 },
    .{ 21, 20, 33 },
    .{ 32, 33, 20 },
    .{ 22, 21, 34 },
    .{ 33, 34, 21 },
    .{ 23, 22, 35 },
    .{ 34, 35, 22 },
    .{ 26, 25, 38 },
    .{ 37, 38, 25 },
    .{ 24, 23, 35 },
    .{ 35, 36, 24 },
    .{ 18, 29, 41 },
    .{ 41, 30, 18 },

    // 4 front
    .{ 0, 1, 7 },
    .{ 7, 8, 0 },
    .{ 1, 2, 6 },
    .{ 6, 2, 3 },
    .{ 6, 3, 4 },
    .{ 4, 5, 6 },

    // 2 front
    .{ 18, 19, 20 },
    .{ 20, 21, 29 },
    .{ 29, 21, 28 },
    .{ 21, 22, 27 },
    .{ 21, 27, 28 },
    .{ 22, 23, 27 },
    .{ 23, 26, 27 },
    .{ 26, 24, 25 },
};

const vertices = [_][3]f32{
    .{ -4, -10, -2 },
    .{ -14, 0, -2 },
    .{ -14, 5, -2 },
    .{ -4, 5, -2 },
    .{ -4, 10, -2 },
    .{ 1, 10, -2 },
    .{ 1, 0, -2 },
    .{ -9, 0, -2 },
    .{ 1, -10, -2 },
    .{ -4, -10, 2 },
    .{ -14, 0, 2 },
    .{ -14, 5, 2 },
    .{ -4, 5, 2 },
    .{ -4, 10, 2 },
    .{ 1, 10, 2 },
    .{ 1, 0, 2 },
    .{ -9, 0, 2 },
    .{ 1, -10, 2 },
    .{ 4, -10, -2 },
    .{ 4, -5, -2 },
    .{ 9, -10, -2 },
    .{ 9, -5, -2 },
    .{ 4, 0, -2 },
    .{ 4, 5, -2 },
    .{ 14, 5, -2 },
    .{ 14, 0, -2 },
    .{ 9, 5, -2 },
    .{ 9, 0, -2 },
    .{ 14, -5, -2 },
    .{ 14, -10, -2 },
    .{ 4, -10, 2 },
    .{ 4, -5, 2 },
    .{ 9, -10, 2 },
    .{ 9, -5, 2 },
    .{ 4, 0, 2 },
    .{ 4, 5, 2 },
    .{ 14, 5, 2 },
    .{ 14, 0, 2 },
    .{ 9, 5, 2 },
    .{ 9, 0, 2 },
    .{ 14, -5, 2 },
    .{ 14, -10, 2 },
};

fn rotateY(v: [3]f32, angle: f32) [3]f32 {
    const cos_a = @cos(angle);
    const sin_a = @sin(angle);
    return .{
        v[0] * cos_a + v[2] * sin_a,
        v[1],
        -v[0] * sin_a + v[2] * cos_a,
    };
}

fn rotateX(v: [3]f32, angle: f32) [3]f32 {
    const cos_a = @cos(angle);
    const sin_a = @sin(angle);
    return .{
        v[0],
        v[1] * cos_a - v[2] * sin_a,
        v[1] * sin_a + v[2] * cos_a,
    };
}

fn rotateZ(v: [3]f32, angle: f32) [3]f32 {
    const cos_a = @cos(angle);
    const sin_a = @sin(angle);
    return .{
        v[0] * cos_a - v[1] * sin_a,
        v[0] * sin_a + v[1] * cos_a,
        v[2],
    };
}

const rotated_vertices: [42][3]f32 = blk: {
    const angle_x = 0.3;
    const angle_y = 0.3;
    const angle_z = 0.0;
    var out: [42][3]f32 = undefined;
    for (vertices, 0..) |v, i| {
        out[i] = rotateX(rotateY(rotateZ(v, angle_z), angle_y), angle_x);
    }
    break :blk out;
};

var zbuffer: [1280 * 800]u16 linksection(".bss") = undefined;

fn vec3_sub(a: [3]f32, b: [3]f32) [3]f32 {
    return .{ a[0] - b[0], a[1] - b[1], a[2] - b[2] };
}

fn vec3_add(a: [3]f32, b: [3]f32) [3]f32 {
    return .{ a[0] + b[0], a[1] + b[1], a[2] + b[2] };
}

fn vec3_scale(v: [3]f32, s: f32) [3]f32 {
    return .{ v[0] * s, v[1] * s, v[2] * s };
}

fn vec3_dot(a: [3]f32, b: [3]f32) f32 {
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
}

fn vec3_cross(a: [3]f32, b: [3]f32) [3]f32 {
    return .{
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
    };
}

fn vec3_normalize(v: [3]f32) [3]f32 {
    const inv_len = 1.0 / @sqrt(vec3_dot(v, v));
    return vec3_scale(v, inv_len);
}

fn project(v: [3]f32, d: f32, scale: f32, cx: f32, cy: f32) [2]f32 {
    const denom = v[2] + d;
    if (@abs(denom) < 0.0001) return .{ cx, cy };
    const factor = scale / denom;
    return .{ v[0] * factor + cx, v[1] * factor + cy };
}

fn drawTrianglePhong(
    ptr: [*]u32,
    width: u32,
    height: u32,
    p0: [2]f32,
    p1: [2]f32,
    p2: [2]f32,
    v0: [3]f32,
    v1: [3]f32,
    v2: [3]f32,
    normal: [3]f32,
    light_pos: [3]f32,
    camera: [3]f32,
) void {
    // Bounding box
    const min_x: i32 = @max(0, @as(i32, @intFromFloat(@min(p0[0], @min(p1[0], p2[0])))));
    const max_x: i32 = @min(@as(i32, @intCast(width)) - 1, @as(i32, @intFromFloat(@max(p0[0], @max(p1[0], p2[0])))));
    const min_y: i32 = @max(0, @as(i32, @intFromFloat(@min(p0[1], @min(p1[1], p2[1])))));
    const max_y: i32 = @min(@as(i32, @intCast(height)) - 1, @as(i32, @intFromFloat(@max(p0[1], @max(p1[1], p2[1])))));

    if (min_x > max_x or min_y > max_y) return;

    const denom = (p1[1] - p2[1]) * (p0[0] - p2[0]) + (p2[0] - p1[0]) * (p0[1] - p2[1]);
    if (@abs(denom) < 0.0001) return;
    const inv_denom = 1.0 / denom;

    const ambient: f32 = 0.15;

    const base_r: f32 = 1.0;
    const base_g: f32 = 0.8;
    const base_b: f32 = 0.1;

    var py: i32 = min_y;
    while (py <= max_y) : (py += 1) {
        var px: i32 = min_x;
        while (px <= max_x) : (px += 1) {
            const fpx: f32 = @floatFromInt(px);
            const fpy: f32 = @floatFromInt(py);

            const w0 = ((p1[1] - p2[1]) * (fpx - p2[0]) + (p2[0] - p1[0]) * (fpy - p2[1])) * inv_denom;
            const w1 = ((p2[1] - p0[1]) * (fpx - p2[0]) + (p0[0] - p2[0]) * (fpy - p2[1])) * inv_denom;
            const w2 = 1.0 - w0 - w1;

            if (w0 < 0.0 or w1 < 0.0 or w2 < 0.0) continue;

            const z = w0 * v0[2] + w1 * v1[2] + w2 * v2[2];
            const z_clamped = @max(-20.0, @min(20.0, z));
            const z_norm: u16 = @intFromFloat((z_clamped + 20.0) / 40.0 * 65535.0);
            const idx = @as(usize, @intCast(py)) * width + @as(usize, @intCast(px));
            if (z_norm >= zbuffer[idx]) continue;
            zbuffer[idx] = z_norm;

            const pos: [3]f32 = vec3_add(
                vec3_add(vec3_scale(v0, w0), vec3_scale(v1, w1)),
                vec3_scale(v2, w2),
            );

            const light_dir = vec3_normalize(vec3_sub(light_pos, pos));
            const view_dir = vec3_normalize(vec3_sub(camera, pos));
            const reflect_dir = vec3_sub(
                vec3_scale(normal, 2.0 * vec3_dot(normal, light_dir)),
                light_dir,
            );

            const diffuse = @max(0.0, vec3_dot(normal, light_dir));
            const spec_base = @max(0.0, vec3_dot(reflect_dir, view_dir));

            // spec^32 via repeated squaring
            var spec = spec_base * spec_base;
            spec = spec * spec;
            spec = spec * spec;
            spec = spec * spec;
            spec = spec * spec;

            const r: u32 = @intFromFloat(@min(1.0, base_r * (ambient + diffuse) + spec) * 255.0);
            const g: u32 = @intFromFloat(@min(1.0, base_g * (ambient + diffuse) + spec) * 255.0);
            const b: u32 = @intFromFloat(@min(1.0, base_b * (ambient + diffuse) + spec) * 255.0);

            ptr[@as(usize, @intCast(py)) * width + @as(usize, @intCast(px))] = (r << 16) | (g << 8) | b;
        }
    }
}

pub fn draw42(ptr: [*]u32, width: u32, height: u32) void {
    @memset(&zbuffer, 0xffff);
    const fw: f32 = @floatFromInt(width);
    const fh: f32 = @floatFromInt(height);

    const d: f32 = 50.0;
    const scale: f32 = fh * 1.2;
    const cx: f32 = fw / 2.0;
    const cy: f32 = fh / 2.0;

    const camera: [3]f32 = .{ 0.0, 0.0, 100.0 };
    const light_pos: [3]f32 = .{ 30.0, -30.0, 50.0 };

    for (faces) |face| {
        const v0 = rotated_vertices[face[0]];
        const v1 = rotated_vertices[face[1]];
        const v2 = rotated_vertices[face[2]];

        const p0 = project(v0, d, scale, cx, cy);
        const p1 = project(v1, d, scale, cx, cy);
        const p2 = project(v2, d, scale, cx, cy);

        const edge0 = vec3_sub(v1, v0);
        const edge1 = vec3_sub(v2, v0);
        const normal = vec3_normalize(vec3_cross(edge0, edge1));

        drawTrianglePhong(ptr, width, height, p0, p1, p2, v0, v1, v2, normal, light_pos, camera);
    }
}
