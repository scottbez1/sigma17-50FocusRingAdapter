eps=0.001;
focus_ring_teeth = 125;

tooth_inner_radius = 71.8/2;
tooth_outer_radius = 73/2;
radius_bias = 0.7;

tooth_inner_gap = 0.57;
tooth_inner_angle = 360*tooth_inner_gap/(2*PI*tooth_inner_radius);

echo(tooth_inner_angle=tooth_inner_angle);
adapter_outer_radius = tooth_outer_radius + radius_bias + 2.3;

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

module gt2_sprocket_arc(teeth, radius, center=true) {
    PLD = 0.254;
    h = 0.75;
    tooth_radius = 0.555;
    pitch = 2;
    pitch_arc_length = teeth * pitch;
    angle = 360 * pitch_arc_length / (2 * PI * radius);

    tooth_translation_radius = radius - PLD - h + tooth_radius;
    infill_radius = 0.15;
    a2 = 360 * (tooth_radius + infill_radius) / (2 * PI * tooth_translation_radius);

    final_rotation = center ? -angle/2 : 0;
    rotate([0, 0, final_rotation]) {
        difference() {
            union() {
                wedge(r=tooth_translation_radius, angle=angle, $fn=120);
                for (i=[0:teeth-1]) {
                    rotate([0, 0, (i + 0.5) * angle / teeth - a2]) {
                        translate([radius - PLD - h + tooth_radius, 0, 0]) {
                            circle(r=infill_radius, $fn=30);
                        }
                    }
                    rotate([0, 0, (i + 0.5) * angle / teeth + a2]) {
                        translate([radius - PLD - h + tooth_radius, 0, 0]) {
                            circle(r=infill_radius, $fn=30);
                        }
                    }
                    rotate([0, 0, i * angle / teeth]) {
                        wedge(r=tooth_translation_radius + infill_radius, angle=angle/teeth/2 - a2, $fn=5);
                    }
                    rotate([0, 0, (i+1) * angle / teeth - (angle/teeth/2 - a2)]) {
                        wedge(r=tooth_translation_radius + infill_radius, angle=angle/teeth/2 - a2, $fn=5);
                    }
                }
            }
            for (i=[0:teeth-1]) {
                rotate([0, 0, (i + 0.5) * angle / teeth]) {
                    translate([tooth_translation_radius, 0, 0]) {
                        circle(r=tooth_radius, $fn=60);
                    }
                }
            }
        }
    }
}


ring_teeth = 30;
ring_angle = 360 * ring_teeth / focus_ring_teeth;
linear_extrude(2.5) {
    intersection() {
        rotate([0, 0, -ring_angle/2]) {
            ring(ring_angle);
        }
        gt2_sprocket_arc(50, adapter_outer_radius);
    }
}
