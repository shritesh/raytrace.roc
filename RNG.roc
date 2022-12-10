interface RNG
    exposes [RNG, init, real, between, vec, vecBetween]
    imports [Vec.{ Vec }]

# Simple linear congruential generator
RNG := U32

init : RNG
init = @RNG 0

u32 : RNG -> { rng : RNG, value : U32 }
u32 = \@RNG seed ->
    value = seed |> Num.mulWrap 1664525 |> Num.addWrap 1013904223

    { rng: @RNG value, value }

real : RNG -> { rng : RNG, value : F64 }
real = \rng ->
    { rng: newRng, value: uValue } = u32 rng

    max = Num.toF64 Num.maxU32 |> Num.add 1
    value = Num.toF64 uValue / max

    { rng: newRng, value }

between : RNG, { min : F64, max : F64 } -> { rng : RNG, value : F64 }
between = \rng, { min, max } ->
    state = real rng
    value = min + (max - min) * state.value

    { rng: state.rng, value }

vec : RNG -> { rng : RNG, value : Vec }
vec = \rng ->
    x = real rng
    y = real x.rng
    z = real y.rng

    { rng: z.rng, value: { x: x.value, y: y.value, z: z.value } }

vecBetween : RNG, { min : F64, max : F64 } -> { rng : RNG, value : Vec }
vecBetween = \rng, range ->
    x = between rng range
    y = between x.rng range
    z = between y.rng range

    { rng: z.rng, value: { x: x.value, y: y.value, z: z.value } }
