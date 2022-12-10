interface Camera
    exposes [Camera, default, ray]
    imports [Vec.{ Vec }, Ray.{ Ray }]

Camera : {
    origin : Vec,
    horizontal : Vec,
    vertical : Vec,
    lowerLeftCorner : Vec,
    imageWidth : Nat,
    imageHeight : Nat,
}

default : Camera
default =
    aspectRatio = 16 / 9

    imageWidth = 400
    imageHeight = imageWidth / aspectRatio |> Num.floor

    viewportHeight = 2
    viewportWidth = aspectRatio * viewportHeight
    focalLength = 1

    origin = { x: 0, y: 0, z: 0 }
    horizontal = { x: viewportWidth, y: 0, z: 0 }
    vertical = { x: 0, y: viewportHeight, z: 0 }
    lowerLeftCorner =
        origin
        |> Vec.sub (Vec.shrink horizontal 2)
        |> Vec.sub (Vec.shrink vertical 2)
        |> Vec.sub { x: 0, y: 0, z: focalLength }

    {
        imageWidth,
        imageHeight,
        origin,
        horizontal,
        vertical,
        lowerLeftCorner,
    }

ray : Camera, F64, F64 -> Ray
ray = \{ origin, horizontal, vertical, lowerLeftCorner }, u, v ->
    direction =
        lowerLeftCorner
        |> Vec.add (Vec.scale horizontal u)
        |> Vec.add (Vec.scale vertical v)
        |> Vec.sub origin

    { origin, direction }
