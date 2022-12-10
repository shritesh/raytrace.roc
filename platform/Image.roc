interface Image
    exposes [write]
    imports [pf.Effect, Task.{ Task }]

# TODO: make this better
write : Str -> Task {} *
write = \str -> Effect.map (Effect.writeImage str) (\_ -> Ok {})
