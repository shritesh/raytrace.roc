interface Hittable
    exposes [Hittable, HitRecord, hit]
    imports [Ray.{ Ray }, Vec.{ Vec }]

HitRecord : { p : Vec, normal : Vec, t : F64, frontFace : Bool }

Hittable has
    hit : k, Ray, { min : F64, max : F64 } -> Result HitRecord [NoHit] | k has Hittable
