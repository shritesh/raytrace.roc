interface Math
    exposes [pi, degToRad, clamp, min, max]
    imports []

pi : F64
pi = 3.1415926535897932385

degToRad : F64 -> F64
degToRad = \deg ->
    deg * pi / 180

clamp : F64, { min : F64, max : F64 } -> F64
clamp = \x, range ->
    if x < range.min then
        range.min
    else if x > range.max then
        range.max
    else
        x

min : F64, F64 -> F64
min = \a, b ->
    if a < b then
        a
    else
        b

max : F64, F64 -> F64
max = \a, b ->
    if a > b then
        a
    else
        b
