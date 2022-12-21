interface HitRecord
    exposes [HitRecord, make]
    imports [Vec.{ Vec }, Ray.{ Ray }]

HitRecord : { p : Vec, normal : Vec, t : F64, frontFace : Bool }

make : { p : Vec, t : F64, ray : Ray, outwardNormal : Vec } -> HitRecord
make = \{ p, t, ray, outwardNormal } ->
    frontFace = Vec.dot ray.direction outwardNormal < 0
    normal = if frontFace then outwardNormal else Vec.neg outwardNormal

    { p, normal, t, frontFace }
