app "Raytrace"
    packages { pf: "platform/main.roc" }
    imports [
        pf.Image,
        Camera.{ Camera },
        Vec.{ Vec, Color },
        RNG,
        Ray.{ Ray },
        Sphere.{ Sphere },
        HittableList.{ HittableList },
        Hittable.{ Hittable },
    ]
    provides [main] to pf

world = HittableList.fromList [
    Sphere.make { x: 0, y: 0, z: -1 } 0.5,
    Sphere.make { x: 0, y: -100.5, z: -1 } 100,
]

camera : Camera
camera = Camera.default

color : Ray, HittableList k -> Color | k has Hittable
color = \ray, hittableList ->
    when Hittable.hit hittableList ray { min: 0, max: Num.maxF64 } is
        Ok rec ->
            { x: 1, y: 1, z: 1 }
            |> Vec.add rec.normal
            |> Vec.shrink 2
            |> Vec.toColor

        Err _ ->
            unit = ray.direction |> Vec.unit
            t = 0.5 * (unit.y + 1)

            white = { x: 1, y: 1, z: 1 } |> Vec.scale (1 - t)
            blue = { x: 0.5, y: 0.7, z: 1.0 } |> Vec.scale t

            Vec.add white blue |> Vec.toColor

main =
    allPixels =
        j <- List.range { start: At 0, end: Before camera.imageHeight } |> List.reverse |> List.joinMap
        i <- List.range { start: At 0, end: Before camera.imageWidth } |> List.map
        { i, j }

    image =
        state, { i, j } <- List.walk allPixels { rng: RNG.init, colors: [] }
        uRng, uRand <- RNG.real state.rng
        vRng, vRand <- RNG.real uRng
        u = (Num.toFrac i + uRand) / Num.toFrac (camera.imageWidth - 1)
        v = (Num.toFrac j + vRand) / Num.toFrac (camera.imageHeight - 1)
        ray = Camera.ray camera u v

        c = color ray world

        { colors: List.append state.colors c, rng: vRng }

    body =
        image.colors
        |> List.map \c -> Vec.toPixel c 1
        |> Str.joinWith "\n"

    iw = Num.toStr camera.imageWidth
    ih = Num.toStr camera.imageHeight

    Image.write
        """
        P3
        \(iw) \(ih)
        256
        \(body)
        
        """
