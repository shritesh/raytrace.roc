interface HitRecord
    exposes [HitRecord]
    imports [Vec.{ Vec }]

HitRecord : { p : Vec, normal : Vec, t : F64, frontFace : Bool }
