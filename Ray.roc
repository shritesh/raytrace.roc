interface Ray
    exposes [Ray, at]
    imports [Vec.{ Vec }]

Ray : { origin : Vec, direction : Vec }

at : Ray, F64 -> Vec
at = \ray, t ->
    Vec.scale ray.direction t
    |> Vec.add ray.origin
