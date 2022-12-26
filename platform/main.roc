platform "host"
    requires { State } { main : {
        init : Canvas -> State,
        update : State -> State,
        render : State -> RGB,
    } }
    exposes [Canvas, RGB]
    packages {}
    imports []
    provides [mainForHost]

Canvas : { width : U32, height : U32, i : U32, j : U32 }

RGB : { r : U8, g : U8, b : U8 }

mainForHost : { init : (Canvas -> State) as Init, update : (State -> State) as Update, render : (State -> RGB) as Render }
mainForHost = main
