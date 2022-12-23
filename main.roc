app "Raytrace"
    packages { pf: "platform/main.roc" }
    imports [
        Camera.{ Camera },
        Vec.{ Vec },
        Color.{ Color },
        RNG.{ RNG },
        Ray.{ Ray },
        World.{ World },
        Material,
        Sphere,
    ]
    provides [render] to pf

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

scene =
    spheres =
        state, a <- List.range { start: At -11, end: Before 11 } |> List.walk { acc: [], rng: RNG.init }
        innerState, b <- List.range { start: At -11, end: Before 11 } |> List.walk state

        chooseRng, choose <- RNG.real innerState.rng
        xRng, x <- RNG.real chooseRng
        zRng, z <- RNG.real xRng

        center = { x: a + 0.9 * x, y: 0.2, z: b + 0.9 * z }
        size = Vec.sub center { x: 4, y: 0.2, z: 0 } |> Vec.length

        if size > 0.9 then
            if choose < 0.8 then
                # diffuse
                colorRng1, color1 <- RNG.color zRng
                colorRng2, color2 <- RNG.color colorRng1
                albedo = Color.mul color1 color2

                sphere = Sphere.make center 0.2 (Lambertian albedo)

                { acc: List.append innerState.acc sphere, rng: colorRng2 }
            else if choose < 0.95 then
                # metal
                albedoRng, albedo <- RNG.color zRng
                fuzzRng, fuzz <- RNG.between albedoRng { min: 0, max: 0.5 }

                sphere = Sphere.make center 0.2 (Metal albedo fuzz)

                { acc: List.append innerState.acc sphere, rng: fuzzRng }
            else
                # glass
                sphere = Sphere.make center 0.2 (Dielectric 1.5)

                { acc: List.append innerState.acc sphere, rng: zRng }
        else
            { innerState & rng: zRng }

    world = List.join [
        [Sphere.make { x: 0, y: -1000, z: 0 } 1000 (Lambertian { r: 0.5, g: 0.5, b: 0.5 })],
        spheres.acc,
        [
            Sphere.make { x: 0, y: 1, z: 0 } 1 (Dielectric 1.5),
            Sphere.make { x: -4, y: 1, z: 0 } 1 (Lambertian { r: 0.4, g: 0.2, b: 0.1 }),
            Sphere.make { x: 4, y: 1, z: 0 } 1 (Metal { r: 0.7, g: 0.6, b: 0.5 } 0),
        ],
    ]

    { rng: spheres.rng, world }

render = \i, j ->
    imageWidth = 1200
    imageHeight = 800
    samples = 500

    camera = Camera.make {
        lookFrom: { x: 13, y: 2, z: 3 },
        lookAt: { x: 0, y: 0, z: 0 },
        up: { x: 0, y: 1, z: 0 },
        fov: 20,
        aspectRatio: Num.toFrac imageWidth / Num.toFrac imageHeight,
        aperture: 0.1,
        focusDist: 10,
    }

    { rng, world } = scene
    # TODO: move everything up to this point to an "init" function
    final =
        state, _ <- List.range { start: At 0, end: Length samples } |> List.walk { rng, color: Color.zero }
        uRng, uRand <- RNG.real state.rng
        vRng, vRand <- RNG.real uRng
        u = (Num.toFrac i + uRand) / Num.toFrac (imageWidth - 1)
        v = (Num.toFrac j + vRand) / Num.toFrac (imageHeight - 1)

        cameraRng, ray <- Camera.ray camera u v vRng
        colorRng, c <- color ray world 50 cameraRng

        { rng: colorRng, color: Color.add state.color c }

    Color.toPixel final.color samples
