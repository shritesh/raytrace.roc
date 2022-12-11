app "Raytrace"
    packages { pf: "platform/main.roc" }
    imports [
        pf.Image,
        Camera.{ Camera },
        Vec.{ Vec },
        Color.{ Color },
        RNG.{ RNG },
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

samples = 100
maxDepth = 50

color : Ray, HittableList k, Nat, RNG, (RNG, Color -> a) -> a | k has Hittable
color = \ray, hittableList, depth, rng, fn ->
    if depth == 0 then
        fn rng Color.zero
    else
        when Hittable.hit hittableList ray { min: 0.001, max: Num.maxF64 } is
            Ok rec ->
                newRng, unitVec <- RNG.unitVec rng {}

                target =
                    unitVec
                    |> Vec.add rec.normal
                    |> Vec.add rec.p

                origin = rec.p
                direction = Vec.sub target rec.p

                color { origin, direction } hittableList (depth - 1) newRng \nrng, c -> fn nrng (Color.shrink c 2)

            Err _ ->
                unit = ray.direction |> Vec.unit
                t = 0.5 * (unit.y + 1)

                white = { r: 1, g: 1, b: 1 } |> Color.scale (1 - t)
                blue = { r: 0.5, g: 0.7, b: 1.0 } |> Color.scale t

                fn rng (Color.add white blue)

main =
    allPixels =
        j <- List.range { start: At 0, end: Before camera.imageHeight } |> List.reverse |> List.joinMap
        i <- List.range { start: At 0, end: Before camera.imageWidth } |> List.map
        { i, j }

    image =
        state, { i, j } <- List.walk allPixels { rng: RNG.default, colors: [] }

        multiSampled =
            multisampleState, _ <- List.range { start: At 0, end: Length samples } |> List.walk { rng: state.rng, color: Color.zero }
            uRng, uRand <- RNG.real multisampleState.rng {}
            vRng, vRand <- RNG.real uRng {}
            u = (Num.toFrac i + uRand) / Num.toFrac (camera.imageWidth - 1)
            v = (Num.toFrac j + vRand) / Num.toFrac (camera.imageHeight - 1)
            ray = Camera.ray camera u v

            newRng, c <- color ray world maxDepth vRng

            { rng: newRng, color: Color.add multisampleState.color c }

        { colors: List.append state.colors multiSampled.color, rng: multiSampled.rng }

    body =
        image.colors
        |> List.map \c -> Color.toPixel c samples
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
