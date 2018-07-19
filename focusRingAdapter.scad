eps=0.001;
focus_ring_teeth = 125;

tooth_inner_radius = 71.8/2;
tooth_outer_radius = 73/2;
radius_bias = 0.7;

tooth_inner_gap = 0.57;
tooth_inner_angle = 360*tooth_inner_gap/(2*PI*tooth_inner_radius);

echo(tooth_inner_angle=tooth_inner_angle);
adapter_outer_radius = tooth_outer_radius + radius_bias + 2;

module wedge(r, angle, $fn) {
    coords = concat([[0, 0]], [ for (i=[0:$fn]) [r*cos(i*angle/$fn), r*sin(i*angle/$fn)]], [[0, 0]]);
    polygon(coords, convexity=10);
}


module ring(angle) {
    intersection() {
        union() {
            difference() {
                wedge(r=adapter_outer_radius, angle=angle, $fn=120);
                circle(r=tooth_outer_radius + radius_bias, angle=angle, $fn=120);
            }

            // teeth
            difference() {
                for (i=[0:(focus_ring_teeth*angle/360)]) {
                    rotate([0, 0, i*360/focus_ring_teeth]) {
                        wedge(tooth_outer_radius + radius_bias + eps, tooth_inner_angle, 10);
                    }
                }
                circle(r=tooth_inner_radius + radius_bias, $fn=120);
            }
        }
        wedge(r=adapter_outer_radius, angle=angle, $fn=120);
    }
}

linear_extrude(2) {
    ring(90);
}
