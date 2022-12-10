interface HittableList
    exposes [HittableList, fromList]
    imports [Hittable.{ Hittable, HitRecord }, Ray.{ Ray }]

HittableList k := List k has [Hittable { hit }]

fromList : List k -> HittableList k | k has Hittable
fromList = \list ->
    @HittableList list

hit : HittableList k, Ray, { min : F64, max : F64 } -> Result HitRecord [NoHit] | k has Hittable
hit = \@HittableList list, ray, { min, max } ->
    final =
        state, object <- List.walk list { closestSoFar: max, rec: Err NoHit }

        when Hittable.hit object ray { min, max: state.closestSoFar } is
            Ok rec -> { closestSoFar: rec.t, rec: Ok rec }
            Err _ -> state

    final.rec
