interface World
    exposes [hit, World]
    imports [HitRecord.{ HitRecord }, Ray.{ Ray }, Sphere.{ Sphere }]

World : List Sphere

hit : World, Ray, { min : F64, max : F64 } -> Result HitRecord [NoHit]
hit = \world, ray, { min, max } ->
    final =
        state, sphere <- List.walk world { closestSoFar: max, rec: Err NoHit }

        when Sphere.hit sphere ray { min, max: state.closestSoFar } is
            Ok rec -> { closestSoFar: rec.t, rec: Ok rec }
            Err _ -> state

    final.rec
