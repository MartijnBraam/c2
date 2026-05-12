
inner_width=90;
inner_height=90;
inner_length=145;

bevel=5;
bar=6;
barw=4;
thick=8;

width=inner_width+(2*(thick));
height=inner_height+(2*(thick));
length=inner_length+(2*(thick));

screw_offset=3.4;

include<components.scad>;

module panel(w,h) {
    difference() {
        translate([0.1, 0.1, 0])
        shell([w-0.2, h-0.2, thick-barw], 1.5, center=false);
        
        translate([screw_offset, screw_offset, 0])
            screwhole(2.5, 4.5, 8, 2);
        
        translate([screw_offset, h-screw_offset, 0])
            screwhole(2.5, 4.5, 8, 2);
        translate([w-screw_offset, screw_offset, 0])
            screwhole(2.5, 4.5, 8, 2);
        
        translate([w-screw_offset, h-screw_offset, 0])
            screwhole(2.5, 4.5, 8, 2);
    }
}

module cam4_mountbody() {
        size=62;
        hole=size-4;
        screw_spacing=52;
        margin=0.3;
        
    
        linear_extrude(3) {
            rsquare2([size+margin*2, size+margin*2], 5);
        }
        
        translate([screw_spacing/2,screw_spacing/2, 2.99])
        rotate([180, 0, 0])
            insert(2.5, 4, 8);
        translate([-screw_spacing/2,screw_spacing/2, 2.99])
        rotate([180, 0, 0])
            insert(2.5, 4, 8);
        translate([screw_spacing/2,-screw_spacing/2, 2.99])
        rotate([180, 0, 0])
            insert(2.5, 4, 8);
        translate([-screw_spacing/2,-screw_spacing/2, 2.99])
        rotate([180, 0, 0])
            insert(2.5, 4, 8);

        
        difference() {
            linear_extrude(20) {
                rsquare2([hole, hole], 5);
            }
            
            translate([hole/2-1, hole/2-1, 0])
                cylinder(r=7, h=20);
            translate([-hole/2+1, hole/2-1, 0])
                cylinder(r=7, h=20);
            translate([hole/2-1, -hole/2+1, 0])
                cylinder(r=7, h=20);
            translate([-hole/2+1, -hole/2+1, 0])
                cylinder(r=7, h=20);
        }
}

module cam4_mountbody_add() {
        size=62;
        hole=size-4;
        screw_spacing=52;
        margin=0.3;
        
        union() {
            translate([hole/2-1, hole/2-1, 0])
                cylinder(r=7, h=7);
            translate([-hole/2+1, hole/2-1, 0])
                cylinder(r=7, h=7);
            translate([hole/2-1, -hole/2+1, 0])
                cylinder(r=7, h=7);
            translate([-hole/2+1, -hole/2+1, 0])
                cylinder(r=7, h=7);
        }
}

module panel_sensor() {
    difference() {
        union() {
        panel(90, 90);
        translate([45, 45, thick-barw])
            rotate([180, 0, 0])
        cam4_mountbody_add();

        }
        translate([45, 45, thick-barw])
        rotate([180, 0, 0])
            #cam4_mountbody();
    }
}

module displaymount(r) {
    difference() {
        rotate([0, 0, r])
        union() {
            color("#ccc")
            cylinder(h=3, r=5, $fn=90);
            
            color("#ccc")
            translate([0, -5, 0])
                cube([10, 10, 3]);
            
            color("#ccc")
            translate([-5, -10, 0])
                cube([10, 10, 3]);

            color("#aaa")
            translate([-5, -10, 0])
                cube([10, 4.5, 15]);
            
            color("#aaa")
            translate([5.5, -5, 0])
                cube([4.5, 10, 15]);

        }
        screwhole(2.5, 2.5, 8);
    }
}

module panel_display() {
    display_width=121;
    display_height=77.6;
    size_x=145;
    size_z=90;
    
    difference() {
        panel(145, 90);
        
        translate([size_x/2,size_z/2, -5])
        rotate([0, 0, 0])
            ccube([display_width, display_height, 10]);
        
        // Display touch flex cutout
        cutout_z=2;
        translate([size_x/2+34, 3.3,3])
            rotate([-90, 0, 0])
            #cube([10, 10-1, 3], center=false);
        

    }
    difference() {
        translate([0, 0, -13])
        rotate([-90, 0, 0])
        union() {
            translate([(size_x/2)-(display_width/2)+4, 0, 11.5])
            rotate([90, 0, 0])
                displaymount(270);
            translate([(size_x/2)+(display_width/2)-4, 0, 11.5])
            rotate([90, 0, 0])
                displaymount(0);
            translate([(size_x/2)-(display_width/2)+4, 0, 79.5])
            rotate([90, 0, 0])
                displaymount(180);
            translate([(size_x/2)+(display_width/2)-4, 0, 79.5])
            rotate([90, 0, 0])
                displaymount(90);
            
            if ($preview && false) {
                translate([size_x/2, -15.7, 47.4])
                    rotate([90, 0,0])
                    color("#333")
                    import("5INCH-DSI-LCD-C.stl");
            }
        }
        
        translate([0, 84, -15])
            cube([size_x, 10, 15]);
    }
}

module bmd_micro_converter() {
    cube([46, 60, 25]);
    
    translate([14, 0, 12.5])
    rotate([90, 0, 0])
    cylinder(r=13/2, h=20, $fn=50);
    
    translate([14+18, 0, 12.5])
    rotate([90, 0, 0])
    cylinder(r=13/2, h=20, $fn=50);

}

module neutrik_d() {
    rotate([90, 0, 0])
    cylinder(r=24/2, h=20, $fn=50);
    
    translate([19/2, 0, -24/2])
    rotate([90, 0, 0])
        cylinder(r=3.5/2, h=20, $fn=50);

    translate([-19/2, 0, 24/2])
    rotate([90, 0, 0])
        cylinder(r=3.5/2, h=20, $fn=50);
    
    translate([0, -10, 0])
    cube([26, 1, 31], center=true);
}

module panel_rear_io() {
    difference() {
        panel(90, 90);
                
        translate([10, 90-33, 0])
        rotate([-90, 0, 0])
            #bmd_micro_converter();
        
        translate([90-(26/2)-5.8, 90-(31/2)-6, 0])
        rotate([-90, 0, 0])
            #neutrik_d();


        translate([90-(26/2)-5.8, 30, 0])
        rotate([-90, 0, 0])
            #neutrik_d();

        translate([(26/2)+5.8, 30, 0])
        rotate([-90, 0, 0])
            #neutrik_d();

        translate([45, 30, 0])
        rotate([-90, 0, 0])
            #neutrik_d();

    }
}

module panel_cheese() {
    difference() {
        panel(145, 90);
        
    translate([145/2, 90/2, 4.05])
        insert(0, 7.15, 8);
    
    translate([145/4, 90/2, 4.05])
        insert(0, 7.15, 8);

    translate([145/4*3, 90/2, 4.05])
        insert(0, 7.15, 8);
        
    translate([145/4*3, 90/4, 4.05])
        insert(0, 4, 8);

    translate([145/4*3, 90/4*3, 4.05])
        insert(0, 4, 8);

    translate([145/4, 90/4, 4.05])
        insert(0, 4, 8);

    translate([145/4, 90/4*3, 4.05])
        insert(0, 4, 8);


    translate([145/2, 90/4, 4.05])
        insert(0, 4, 8);

    translate([145/2, 90/4*3, 4.05])
        insert(0, 4, 8);

    }
}

//panel_rear_io();
panel_cheese();