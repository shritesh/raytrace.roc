interface Color
    exposes [
        Color,
        zero,
        one,
        neg,
        add,
        sub,
        mul,
        div,
        scale,
        shrink,
        toPixel,
    ]
    imports [Math]

Color : { r : F64, g : F64, b : F64 }

zero : Color
zero = { r: 0, g: 0, b: 0 }

one : Color
one = { r: 1, g: 1, b: 1 }

neg : Color -> Color
neg = \c -> {
    r: -c.r,
    g: -c.g,
    b: -c.b,
}

add : Color, Color -> Color
add = \a, b -> {
    r: a.r + b.r,
    g: a.g + b.g,
    b: a.b + b.b,
}

sub : Color, Color -> Color
sub = \a, b -> {
    r: a.r - b.r,
    g: a.g - b.g,
    b: a.b - b.b,
}

mul : Color, Color -> Color
mul = \a, b -> {
    r: a.r * b.r,
    g: a.g * b.g,
    b: a.b * b.b,
}

div : Color, Color -> Color
div = \a, b -> {
    r: a.r / b.r,
    g: a.g / b.g,
    b: a.b / b.b,
}

scale : Color, F64 -> Color
scale = \c, t -> {
    r: c.r * t,
    g: c.g * t,
    b: c.b * t,
}

shrink : Color, F64 -> Color
shrink = \c, t ->
    scale c (1 / t)

toPixel : Color, Num * -> { r : U8, g : U8, b : U8 }
toPixel = \{ r, g, b }, samples ->
    if Num.isZero samples then
        { r: 0, g: 0, b: 0 }
    else
        sc = 1 / Num.toFrac samples

        sr = Num.sqrt (r * sc)
        sg = Num.sqrt (g * sc)
        sb = Num.sqrt (b * sc)

        ir = 256 * Math.clamp sr { min: 0, max: 0.999 } |> Num.floor |> Num.toU8
        ig = 256 * Math.clamp sg { min: 0, max: 0.999 } |> Num.floor |> Num.toU8
        ib = 256 * Math.clamp sb { min: 0, max: 0.999 } |> Num.floor |> Num.toU8

        { r: ir, g: ig, b: ib }
