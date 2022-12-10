interface Sphere
    exposes [Sphere, hit, make]
    imports [Vec.{ Vec }, Ray.{ Ray }, Hittable.{ Hittable, HitRecord }]

Sphere := { center : Vec, radius : F64 } has [Hittable { hit }]

make : Vec, F64 -> Sphere
make = \center, radius ->
    @Sphere { center, radius }

# The first book only deals with spheres so a `Hittable` ability is overkill
# Will revisit if I do the later books
hit : Sphere, Ray, { min : F64, max : F64 } -> Result HitRecord [NoHit]
hit = \@Sphere { center, radius }, ray, { min, max } ->
    oc = Vec.sub ray.origin center
    a = Vec.lengthSquared ray.direction
    halfB = Vec.dot oc ray.direction
    c = Vec.lengthSquared oc - radius * radius
    discriminant = halfB * halfB - a * c

    if discriminant < 0 then
        Err NoHit
    else
        sqrtd = Num.sqrt discriminant

        negativeRoot = (-halfB - sqrtd) / a
        positiveRoot = (-halfB + sqrtd) / a

        root =
            if negativeRoot >= min && negativeRoot <= max then
                Ok negativeRoot
            else if positiveRoot >= min && positiveRoot <= max then
                Ok positiveRoot
            else
                Err NoHit

        t <- Result.map root

        p = Ray.at ray t

        outwardNormal =
            Vec.sub p center
            |> Vec.shrink radius

        frontFace = Vec.dot ray.direction outwardNormal < 0

        normal =
            if frontFace then
                outwardNormal
            else
                Vec.neg outwardNormal

        { t, p, normal, frontFace }
