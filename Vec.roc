interface Vec
    exposes [
        Vec,
        neg,
        add,
        sub,
        mul,
        div,
        scale,
        shrink,
        dot,
        cross,
        unit,
        length,
        lengthSquared,
        Color,
        toColor,
        toPixel,
    ]
    imports [Math]

Vec : { x : F64, y : F64, z : F64 }
Color : { r : F64, g : F64, b : F64 }

neg : Vec -> Vec
neg = \v -> {
    x: -v.x,
    y: -v.y,
    z: -v.z,
}

add : Vec, Vec -> Vec
add = \a, b -> {
    x: a.x + b.x,
    y: a.y + b.y,
    z: a.z + b.z,
}

sub : Vec, Vec -> Vec
sub = \a, b -> {
    x: a.x - b.x,
    y: a.y - b.y,
    z: a.z - b.z,
}

mul : Vec, Vec -> Vec
mul = \a, b -> {
    x: a.x * b.x,
    y: a.y * b.y,
    z: a.z * b.z,
}

div : Vec, Vec -> Vec
div = \a, b -> {
    x: a.x / b.x,
    y: a.y / b.y,
    z: a.z / b.z,
}

scale : Vec, F64 -> Vec
scale = \v, t -> {
    x: v.x * t,
    y: v.y * t,
    z: v.z * t,
}

shrink : Vec, F64 -> Vec
shrink = \v, t ->
    scale v (1 / t)

dot : Vec, Vec -> F64
dot = \u, v ->
    u.x * v.x + u.y * v.y + u.z * v.z

cross : Vec, Vec -> Vec
cross = \u, v -> {
    x: u.y * v.z - u.z * v.y,
    y: u.z * v.x - u.x * v.z,
    z: u.x * v.y - u.y * v.x,
}

unit : Vec -> Vec
unit = \v ->
    shrink v (length v)

length : Vec -> F64
length = \v ->
    lengthSquared v |> Num.sqrt

lengthSquared : Vec -> F64
lengthSquared = \v ->
    v.x * v.x + v.y * v.y + v.z * v.z

toColor : Vec -> Color
toColor = \v -> {
    r: v.x,
    g: v.y,
    b: v.z,
}

toPixel : Color, Num * -> Str
toPixel = \{ r, g, b }, samples ->
    sc = 1 / Num.toFrac samples

    ir = 256 * Math.clamp (r * sc) { min: 0, max: 0.999 } |> Num.floor |> Num.toStr
    ig = 256 * Math.clamp (g * sc) { min: 0, max: 0.999 } |> Num.floor |> Num.toStr
    ib = 256 * Math.clamp (b * sc) { min: 0, max: 0.999 } |> Num.floor |> Num.toStr

    "\(ir) \(ig) \(ib)"
