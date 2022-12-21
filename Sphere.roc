interface Sphere
    exposes [Sphere, make, hit]
    imports [Vec.{ Vec }, Ray.{ Ray }, Material.{ Material }, HitRecord.{ HitRecord }]

Sphere : { center : Vec, radius : F64, material : Material }

make : Vec, F64, Material -> Sphere
make = \center, radius, material ->
    {center, radius, material}

hit : Sphere, Ray, { min : F64, max : F64 } -> Result { rec : HitRecord, mat : Material } [NoHit]
hit = \{ center, radius, material }, ray, { min, max } ->
    oc = Vec.sub ray.origin center
    a = Vec.lengthSquared ray.direction
    halfB = Vec.dot oc ray.direction
    c = Vec.lengthSquared oc - (radius * radius)
    discriminant = halfB * halfB - a * c

    if discriminant <= 0 then
        Err NoHit
    else
        sqrtd = Num.sqrt discriminant

        negativeRoot = (-halfB - sqrtd) / a
        positiveRoot = (-halfB + sqrtd) / a

        root = if negativeRoot > min && negativeRoot < max then 
                Ok negativeRoot 
            else if positiveRoot > min && positiveRoot < max then 
                Ok positiveRoot 
            else 
                Err NoHit
        
        t <- Result.map root

        p = Ray.at ray t
        outwardNormal = Vec.sub p center |> Vec.shrink radius

        rec = HitRecord.make {p, t, ray, outwardNormal }

        {rec, mat: material}
        

