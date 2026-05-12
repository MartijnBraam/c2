flange_distance=19.25;

include<../../lib/components.scad>;
include<common.scad>;


module mount_mft(hole=25, height=7) {
    // z=0 of this module is the flange

    inset=4;
    screw_r=1.7/2;
    rectangle_length=48;
    pin_height=2;

    translate([0, 0, -height-pin_height])
    union() {
        // Indicator pin
        if (false) {
        rotate([0, 0, 161])
        translate([47/2, 0, height])
            cylinder(r=1.4/2, h=pin_height, $fn=40);
        }

        difference(){
            union() {
                cylinder(r=54/2, h=height, $fn=180);
                translate([0, 0, 3])
                    fillet(54/2, 4, $fn=90);
            }

            translate([0, 0, -1])
            cylinder(r=hole/2, h=height, $fn=180);

            // Inset area
            translate([0, 0, height-inset-0.05])
                cylinder(r=42/2, h=inset+0.1, $fn=180);

            // Locking pin
            rotate([0, 0, 0])
            translate([48/2, 0, height-5])
                cylinder(r=5/2, h=height, $fn=40);
            translate([48/2, 0, -4])
                cylinder(r=1.5/2, h=height, $fn=40);

            rotate([0, 0, -90])
            translate([0, 3+(48/2), height-1])
                cube([5, 6, 2.1], center=true);
            rotate([0, 0, -90])
            translate([0, 3+(53/2), height-1])
                cube([8, 6, height*2], center=true);




            // Rectangular inset cutouts
            rotate([0, 0, 90])
            rotate([0, 0, -90])
            translate([0, rectangle_length/4, height-(inset/2)])
                cube([12, rectangle_length/2, inset+0.1], center=true);
            rotate([0, 0, -26.5])
            rotate([0, 0, -90])
            translate([0, rectangle_length/4, height-(inset/2)])
                cube([12, rectangle_length/2, inset+0.1], center=true);
            rotate([0, 0, 205])
            rotate([0, 0, -90])
            translate([0, rectangle_length/4, height-(inset/2)])
                cube([12, rectangle_length/2, inset+0.1], center=true);

            // Screws
            rotate([0, 0, 50])
            translate([48/2, 0, height-5])
                cylinder(r=screw_r, h=5+0.1, $fn=8);
            rotate([0, 0, 180-50])
            translate([48/2, 0, height-5])
                cylinder(r=screw_r, h=5+0.1, $fn=8);
            rotate([0, 0, -50])
            translate([48/2, 0, height-5])
                cylinder(r=screw_r, h=5+0.1, $fn=8);
            rotate([0, 0, -180+50])
            translate([48/2, 0, height-5])
                cylinder(r=screw_r, h=5+0.1, $fn=8);
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

cam4_mount(mft_pin=true) {
        translate([0, 0, 10])
            mount_mft(height=8);
}
