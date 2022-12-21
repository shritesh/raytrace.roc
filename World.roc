interface World
    exposes [World, hit]
    imports [Sphere.{ Sphere }, Ray.{ Ray }, HitRecord.{ HitRecord }, Material.{ Material }]

World : List Sphere

hit : World, Ray, { min : F64, max : F64 } -> Result { rec : HitRecord, mat : Material } [NoHit]
hit = \world, ray, { min, max } ->
    final =
        state, sphere <- List.walk world { closestSoFar: max, recAndMat: Err NoHit }

        when Sphere.hit sphere ray { min, max: state.closestSoFar } is
            Ok recAndMat ->
                { closestSoFar: recAndMat.rec.t, recAndMat: Ok recAndMat }

            Err _ ->
                state

    final.recAndMat
