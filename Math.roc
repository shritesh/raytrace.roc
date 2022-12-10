interface Math
    exposes [pi, degToRad, clamp]
    imports []

pi : F64
pi = 3.1415926535897932385

degToRad : F64 -> F64
degToRad = \deg ->
    deg * pi / 180

clamp : F64, { min : F64, max : F64 } -> F64
clamp = \x, { min, max } ->
    if x < min then
        min
    else if x > max then
        max
    else
        x
