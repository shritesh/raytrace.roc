interface Material
    exposes [Material, scatter]
    imports [Color.{ Color }, RNG.{ RNG }, Vec, Ray.{ Ray }, HitRecord.{ HitRecord }, Math]

ScatterRecord : { attenuation : Color, scattered : Ray }

Material : [Lambertian Color, Metal Color F64, Dielectric F64]

scatter : Material, Ray, HitRecord, RNG, (RNG, Result ScatterRecord [NoHit] -> a) -> a
scatter = \material, ray, rec, rng, fn ->
    when material is
        Lambertian albedo -> lambertian albedo rec rng fn
        Metal albedo fuzz -> metal albedo fuzz ray rec rng fn
        Dielectric ir -> dielectric ir ray rec rng fn

lambertian = \albedo, rec, rng, fn ->
    newRng, unitVec <- RNG.unitVec rng

    scatterDirection = Vec.add rec.normal unitVec

    direction = if Vec.nearZero scatterDirection then rec.normal else scatterDirection
    scattered = { origin: rec.p, direction }

    fn newRng (Ok { attenuation: albedo, scattered })

metal = \albedo, fuzz, ray, rec, rng, fn ->
    newRng, unitSphere <- RNG.vecInUnitSphere rng
    reflected = Vec.unit ray.direction |> Vec.reflect rec.normal

    scattered = { origin: rec.p, direction: Vec.scale unitSphere fuzz |> Vec.add reflected }

    if Vec.dot scattered.direction rec.normal > 0 then
        fn newRng (Ok { attenuation: albedo, scattered })
    else
        fn newRng (Err NoHit)

dielectric = \ir, ray, rec, rng, fn ->
    refractionRatio = if rec.frontFace then 1 / ir else ir

    unitDirection = Vec.unit ray.direction

    cosTheta = Vec.neg unitDirection |> Vec.dot rec.normal |> Math.min 1
    sinTheta = Num.sqrt (1 - cosTheta * cosTheta)

    cannotRefract = refractionRatio * sinTheta > 1

    newRng, real <- RNG.real rng 

    direction = if cannotRefract || reflectance cosTheta refractionRatio > real  then
            Vec.reflect unitDirection rec.normal
        else
            Vec.refract unitDirection rec.normal refractionRatio

    scattered = { origin: rec.p, direction}

    fn newRng (Ok { attenuation: Color.one, scattered })

reflectance = \cosine, refIdx ->
    r = (1 - refIdx) / (1 + refIdx)
    r0 = r * r
    r0 + (1 - r0) * Num.pow (1 - cosine) 5
