flange_distance=19.25;

include<../../lib/components.scad>;
include<common.scad>;

include<../../vendor/threadlib/threadlib.scad>;


module mount_c(hole=25, height=7) {
    // z=0 of this module is the flange
    
    outer_r=30/2;

    translate([0, 0, -height])
    union() {
        difference(){
            union() {
                cylinder(h=height, r=outer_r, $fn=90);
                translate([0, 0, 0])
                    fillet(outer_r, height, $fn=90);
            }
            tap("32-UN-1", turns=10);
        }
    }
}

module fillet(r, size, $fn) {
    rotate_extrude(convexity = 10, $fn=$fn)
    translate([r, 0, 0])
        difference() {
            square(size);
            translate([size, size])
            circle(size, $fn=$fn);
        }
}

cam4_mount(hfn=60, hole=25) {
        translate([0, 0, 9])
            mount_c(height=6);
}
