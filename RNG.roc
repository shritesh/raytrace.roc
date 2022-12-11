interface RNG
    exposes [RNG, Generator, default, andThen, real, between, vec, vecBetween, vecInUnitSphere, unitVec]
    imports [Vec.{ Vec }]

Generator a b c : RNG, a, (RNG, b -> c) -> c

# Simple linear congruential generator
RNG := U32

default : RNG
default = @RNG 0

andThen : Generator a b c, a, (d, b -> e) -> Generator d e c
andThen = \generator, init, fn ->
    \rng, newInit, newFn ->
        newRng, value <- generator rng init
        newFn newRng (fn newInit value)

u32 : Generator {} U32 *
u32 = \@RNG seed, {}, fn ->
    value =
        seed
        |> Num.mulWrap 1664525
        |> Num.addWrap 1013904223

    fn (@RNG value) value

real : Generator {} F64 *
real =
    {}, u32Value <- andThen u32 {}
    max = Num.toF64 Num.maxU32 |> Num.add 1

    Num.toF64 u32Value / max

between : Generator { min : F64, max : F64 } F64 *
between =
    { min, max }, realValue <- andThen real {}

    min + (max - min) * realValue

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
unitVec =
    {}, unitSphereVec <- andThen vecInUnitSphere {}
    Vec.unit unitSphereVec
