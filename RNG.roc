interface RNG
    exposes [RNG, init, real, between, vec, vecBetween]
    imports [Vec.{ Vec }]

# Simple linear congruential generator
RNG := U32

init : RNG
init = @RNG 0

u32 : RNG, (RNG, U32 -> a) -> a
u32 = \@RNG seed, fn ->
    value =
        seed
        |> Num.mulWrap 1664525
        |> Num.addWrap 1013904223

    fn (@RNG value) value

real : RNG, (RNG, F64 -> a) -> a
real = \rng, fn ->
    newRng, u32Value <- u32 rng
    max = Num.toF64 Num.maxU32 |> Num.add 1
    value = Num.toF64 u32Value / max

    fn newRng value

between : RNG, { min : F64, max : F64 }, (RNG, F64 -> a) -> a
between = \rng, { min, max }, fn ->
    newRng, realValue <- real rng

    value = min + (max - min) * realValue

    fn newRng value

vec : RNG, (RNG, Vec -> a) -> a
vec = \rng, fn ->
    xRng, x <- real rng
    yRng, y <- real xRng
    zRng, z <- real yRng

    value = { x, y, z }

    fn zRng value

vecBetween : RNG, { min : F64, max : F64 }, (RNG, Vec -> a) -> a
vecBetween = \rng, range, fn ->
    xRng, x <- between rng range
    yRng, y <- between xRng range
    zRng, z <- between yRng range

    value = { x, y, z }

    fn zRng value
