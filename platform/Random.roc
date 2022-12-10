interface Random
    exposes [f64, between]
    imports [Task.{ Task }, Effect]

f64 : Task F64 *
f64 = Effect.after Effect.randF64 Task.succeed

between : F64, F64 -> Task F64 *
between = \min, max ->
    value <- Task.map f64
    min + (max - min) * value
