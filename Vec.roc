interface Vec
    exposes [
        Vec,
        zero,
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
    ]
    imports []

Vec : { x : F64, y : F64, z : F64 }

zero : Vec
zero = { x: 0, y: 0, z: 0 }

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
