interface Camera
    exposes [Camera, make, ray]
    imports [Vec.{ Vec }, Ray.{ Ray }, RNG.{ RNG }, Math]

Camera : {
    origin : Vec,
    lowerLeftCorner : Vec,
    horizontal : Vec,
    vertical : Vec,
    u : Vec,
    v : Vec,
    w : Vec,
    lensRadius : F64,
}

make : { lookFrom : Vec, lookAt : Vec, up : Vec, fov : F64, aspectRatio : F64, aperture : F64, focusDist : F64 } -> Camera
make = \{ lookFrom, lookAt, up, fov, aspectRatio, aperture, focusDist } ->
    theta = Math.degToRad fov
    h = Num.tan (theta / 2)
    viewportHeight = 2 * h
    viewportWidth = aspectRatio * viewportHeight

    w = Vec.sub lookFrom lookAt |> Vec.unit
    u = Vec.cross up w |> Vec.unit
    v = Vec.cross w u

    origin = lookFrom
    horizontal = Vec.scale u (viewportWidth * focusDist)
    vertical = Vec.scale v (viewportHeight * focusDist)

    lowerLeftCorner =
        origin
        |> Vec.sub (Vec.shrink horizontal 2)
        |> Vec.sub (Vec.shrink vertical 2)
        |> Vec.sub (Vec.scale w focusDist)

    lensRadius = aperture / 2

    {
        origin,
        lowerLeftCorner,
        horizontal,
        vertical,
        u,
        v,
        w,
        lensRadius,
    }

ray : Camera, F64, F64, RNG, (RNG, Ray -> a) -> a
ray = \{ u, v, lowerLeftCorner, lensRadius, horizontal, vertical, origin }, s, t, rng, fn ->
    newRng, unitDisk <- RNG.vecInUnitDisk rng
    rd = Vec.scale unitDisk lensRadius

    offset = Vec.add (Vec.scale u rd.x) (Vec.scale v rd.y)

    direction =
        lowerLeftCorner
        |> Vec.add (Vec.scale horizontal s)
        |> Vec.add (Vec.scale vertical t)
        |> Vec.sub origin
        |> Vec.sub offset

    fn newRng { origin: Vec.add origin offset, direction }
