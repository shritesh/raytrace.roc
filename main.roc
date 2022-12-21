app "Raytrace"
    packages { pf: "platform/main.roc" }
    imports [
        pf.Image,
        Camera.{ Camera },
        Vec.{ Vec },
        Color.{ Color },
        RNG.{ RNG },
        Ray.{ Ray },
        World.{ World },
        Material,
        Sphere,
    ]
    provides [main] to pf

camera : Camera
camera = Camera.default

samples = 10
maxDepth = 100

color : Ray, World, Nat, RNG, (RNG, Color -> a) -> a
color = \ray, world, depth, rng, fn ->
    if depth == 0 then
        fn rng Color.zero
    else
        when World.hit world ray { min: 0.001, max: Num.maxF64 } is
            Ok { rec, mat } ->
                newRng, scatter <- Material.scatter mat ray rec rng

                when scatter is
                    Ok { attenuation, scattered } ->
                        innerNewRng, newColor <- color scattered world (depth - 1) newRng

                        fn innerNewRng (Color.mul attenuation newColor)

                    Err NoHit ->
                        fn newRng Color.zero

            Err _ ->
                unit = ray.direction |> Vec.unit
                t = 0.5 * (unit.y + 1)

                white = { r: 1, g: 1, b: 1 } |> Color.scale (1 - t)
                blue = { r: 0.5, g: 0.7, b: 1.0 } |> Color.scale t

                fn rng (Color.add white blue)

main =
    ground = Lambertian { r: 0.8, g: 0.8, b: 0 }
    center = Lambertian { r: 0.1, g: 0.2, b: 0.5 }
    left = Dielectric 1.5
    right = Metal { r: 0.8, g: 0.6, b: 0.2 } 0.0

    world = [
        Sphere.make { x: 0, y: -100.5, z: -1 } 100 ground,
        Sphere.make { x: 0, y: 0, z: -1 } 0.5 center,
        Sphere.make { x: -1, y: 0, z: -1 } 0.5 left,
        Sphere.make { x: -1, y: 0, z: -1 } -0.4 left,
        Sphere.make { x: 1, y: 0, z: -1 } 0.5 right,
    ]

    allPixels =
        j <- List.range { start: At 0, end: Before camera.imageHeight } |> List.reverse |> List.joinMap
        i <- List.range { start: At 0, end: Before camera.imageWidth } |> List.map
        { i, j }

    image =
        state, { i, j } <- List.walk allPixels { rng: RNG.init, colors: [] }

        multiSampled =
            multisampleState, _ <- List.range { start: At 0, end: Length samples } |> List.walk { rng: state.rng, color: Color.zero }
            uRng, uRand <- RNG.real multisampleState.rng
            vRng, vRand <- RNG.real uRng
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
