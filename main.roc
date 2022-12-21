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
    aspectRatio = 16 / 9
    imageHeight = 400
    imageWidth = imageHeight * aspectRatio |> Num.floor

    ground = Lambertian { r: 0.8, g: 0.8, b: 0 }
    center = Lambertian { r: 0.1, g: 0.2, b: 0.5 }
    left = Dielectric 1.5
    right = Metal { r: 0.8, g: 0.6, b: 0.2 } 0.0

    world = [
        Sphere.make { x: 0, y: -100.5, z: -1 } 100 ground,
        Sphere.make { x: 0, y: 0, z: -1 } 0.5 center,
        Sphere.make { x: -1, y: 0, z: -1 } 0.5 left,
        Sphere.make { x: -1, y: 0, z: -1 } -0.45 left,
        Sphere.make { x: 1, y: 0, z: -1 } 0.5 right,
    ]

    lookFrom = { x: 3, y: 3, z: 2 }
    lookAt = { x: 0, y: 0, z: -1 }

    camera = Camera.make {
        lookFrom,
        lookAt,
        up: { x: 0, y: 1, z: 0 },
        fov: 20,
        aspectRatio,
        aperture: 2,
        focusDist: Vec.sub lookFrom lookAt |> Vec.length,
    }

    samples = 100
    maxDepth = 50

    allPixels =
        j <- List.range { start: At 0, end: Before imageHeight } |> List.reverse |> List.joinMap
        i <- List.range { start: At 0, end: Before imageWidth } |> List.map
        { i, j }

    image =
        state, { i, j } <- List.walk allPixels { rng: RNG.init, colors: [] }

        multiSampled =
            multisampleState, _ <- List.range { start: At 0, end: Length samples } |> List.walk { rng: state.rng, color: Color.zero }
            uRng, uRand <- RNG.real multisampleState.rng
            vRng, vRand <- RNG.real uRng
            u = (Num.toFrac i + uRand) / Num.toFrac (imageWidth - 1)
            v = (Num.toFrac j + vRand) / Num.toFrac (imageHeight - 1)

            newRng, ray <- Camera.ray camera u v vRng
            newerRng, c <- color ray world maxDepth newRng

            { rng: newerRng, color: Color.add multisampleState.color c }

        { colors: List.append state.colors multiSampled.color, rng: multiSampled.rng }

    body =
        image.colors
        |> List.map \c -> Color.toPixel c samples
        |> Str.joinWith "\n"

    iw = Num.toStr imageWidth
    ih = Num.toStr imageHeight

    Image.write
        """
        P3
        \(iw) \(ih)
        256
        \(body)
        
        """
