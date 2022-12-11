interface RNG
    exposes [RNG, Generator, default, real, between, vec, vecBetween, vecInUnitSphere, unitVec]
    imports [Vec.{ Vec }]

Generator a b c : RNG, a, (RNG, b -> c) -> c

# Simple linear congruential generator
RNG := U32

default : RNG
default = @RNG 0

u32 : Generator {} U32 *
u32 = \@RNG seed, {}, fn ->
    value =
        seed
        |> Num.mulWrap 1664525
        |> Num.addWrap 1013904223

    fn (@RNG value) value

real : Generator {} F64 *
real = \rng, {}, fn ->
    newRng, u32Value <- u32 rng {}
    max = Num.toF64 Num.maxU32 |> Num.add 1
    value = Num.toF64 u32Value / max

    fn newRng value

between : Generator { min : F64, max : F64 } F64 *
between = \rng, { min, max }, fn ->
    newRng, realValue <- real rng {}

    value = min + (max - min) * realValue

    fn newRng value

vec : Generator {} Vec *
vec = \rng, {}, fn ->
    xRng, x <- real rng {}
    yRng, y <- real xRng {}
    zRng, z <- real yRng {}

    value = { x, y, z }

    fn zRng value

vecBetween : Generator { min : F64, max : F64 } Vec *
vecBetween = \rng, range, fn ->
    xRng, x <- between rng range
    yRng, y <- between xRng range
    zRng, z <- between yRng range

    value = { x, y, z }

    fn zRng value

# TODO: Is this recursion okay?
# The compiler breaks if I change this to a Generator
vecInUnitSphere : RNG, {}, (RNG, Vec -> a) -> a
vecInUnitSphere = \rng, {}, fn ->
    newRng, candidate <- vecBetween rng { min: -1, max: 1 }

    if Vec.lengthSquared candidate >= 1 then
        vecInUnitSphere newRng {} fn
    else
        fn newRng candidate

unitVec : Generator {} Vec *
unitVec = \rng, {}, fn ->
    newRng, unitSphereVec <- vecInUnitSphere rng {}

    fn newRng (Vec.unit unitSphereVec)
