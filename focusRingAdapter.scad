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

GT2_PLD = 0.254;
GT2_h = 0.75;
GT2_H = 1.38;
GT2_width = 6;

module gt2_sprocket_arc(teeth, radius, slop_factor, center=true) {
    PLD = GT2_PLD * slop_factor;
    h = GT2_h * slop_factor;
    tooth_radius = 0.555 * slop_factor;
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
base_height = 1.2;

linear_extrude(base_height) {
    rotate([0, 0, -ring_angle/2]) {
        difference(){
            wedge(r=retaining_wall_outer_radius, angle=ring_angle, $fn=60);
            wedge(r=tooth_inner_radius + radius_bias, angle=ring_angle, $fn=60);
        }
    }
}

height = GT2_width + 0.2;
translate([0, 0, base_height - eps]) {
    linear_extrude(height) {
        intersection() {
            rotate([0, 0, -ring_angle/2]) {
                ring(ring_angle);
            }
            gt2_sprocket_arc(50, adapter_outer_radius, 1.4);
        }
    }
}

// Retaining wall:
retaining_wall_thickness = 1.5;
retaining_wall_inner_radius = adapter_outer_radius + GT2_H - GT2_PLD - GT2_h + 0.12;
retaining_wall_outer_radius = retaining_wall_inner_radius + retaining_wall_thickness;
overhang = 0.15;
overhang_height = 0.4;

linear_extrude(height + base_height) {
    rotate([0, 0, -ring_angle/2]) {
        difference(){
            wedge(r=retaining_wall_outer_radius, angle=ring_angle, $fn=60);
            wedge(r=retaining_wall_inner_radius, angle=ring_angle, $fn=60);
        }
    }
}

translate([0, 0, base_height + height -eps]) {
    rotate([0, 0, -ring_angle/2]) {
        intersection() {
            linear_extrude(overhang_height) {
                wedge(r=retaining_wall_outer_radius, angle=ring_angle, $fn=60);
            }
            rotate_extrude($fn=120) {
                translate([retaining_wall_inner_radius, 0, 0]) {
                    polygon([
                        [0, 0],
                        [retaining_wall_thickness + 5, 0],
                        [retaining_wall_thickness + 5, overhang_height],
                        [-overhang, overhang_height]
                    ]);
                }
            }
        }
    }
}
