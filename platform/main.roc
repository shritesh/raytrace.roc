platform "host"
    requires {} { render : U32, U32 -> Str }
    exposes []
    packages {}
    imports []
    provides [renderForHost]

renderForHost : U64 -> Str
renderForHost = \num ->
    i = num |> Num.shiftRightBy 32 |> Num.toU32
    j = num |> Num.shiftLeftBy 32 |> Num.shiftRightBy 32 |> Num.toU32

    render i j
