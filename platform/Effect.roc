hosted Effect
    exposes [Effect, after, map, always, forever, loop, writeLine, randF64]
    imports []
    generates Effect with [after, map, always, forever, loop]

writeLine : Str -> Effect {}

randF64 : Effect F64
