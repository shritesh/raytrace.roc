interface Vec
    exposes [
        Vec,
        zero,
        one,
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
        nearZero,
        reflect,
        refract,
    ]
    imports [Math]

Vec : { x : F64, y : F64, z : F64 }

zero : Vec
zero = { x: 0, y: 0, z: 0 }

one : Vec
one = { x: 1, y: 1, z: 1 }

neg : Vec -> Vec
neg = \{ x, y, z } -> {
    x: -x,
    y: -y,
    z: -z,
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
scale = \{ x, y, z }, t -> {
    x: x * t,
    y: y * t,
    z: z * t,
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
lengthSquared = \{ x, y, z } ->
    x * x + y * y + z * z

nearZero : Vec -> Bool
nearZero = \{ x, y, z } ->
    s = 1e-8

    Num.abs x < s && Num.abs y < s && Num.abs z < s

reflect : Vec, Vec -> Vec
reflect = \v, n ->
    Vec.sub v (Vec.scale n (2 * Vec.dot v n))

refract : Vec, Vec, F64 -> Vec
refract = \uv, n, etaiOverEtat ->
    cosTheta = neg uv |> dot n |> Math.min 1
    rOutPerp = scale n cosTheta |> add uv |> scale etaiOverEtat
    s = Num.abs (1 - lengthSquared rOutPerp) |> Num.sqrt
    rOutParallel = neg n |> scale s

    add rOutPerp rOutParallel
