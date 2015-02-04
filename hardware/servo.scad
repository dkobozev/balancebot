include <parameters.scad>;

servo_z1 = 36.1;
servo_z2 = 26.6;
servo_x1 = 55.5;
servo_x2 = 40.5;
servo_y  = 20;

servo_mount_thickness     = 2.5;
servo_axis_offset_x       = 9.85;
servo_axis_h              = 6;
servo_axis_spacing        = 2;
servo_mount_hole_r        = 2.25;
servo_mount_hole_offset_x = 25.25;
servo_mount_hole_offset_y = 5;


module servo_mounting_holes_pair() {
    translate([0, servo_mount_hole_offset_y, 0])
        cylinder (r = servo_mount_hole_r, h = servo_z1, center = true, $fn = resolution);
    translate([0, -servo_mount_hole_offset_y, 0])
        cylinder (r = servo_mount_hole_r, h = servo_z1, center = true, $fn = resolution);
}

module servo_mounting_holes() {
    translate([servo_mount_hole_offset_x, 0, 0])
        servo_mounting_holes_pair();
    translate([-servo_mount_hole_offset_x, 0, 0])
        servo_mounting_holes_pair();
}

module servo_body() {
    union() {
        color([0.2, 0.2, 0.2])
        cube ([servo_x2, servo_y, servo_z1], center = true);
        translate([0, 0, servo_z2 - servo_z1/2])
            cube ([servo_x1, servo_y, servo_mount_thickness], center = true);

        // axis
        translate([servo_axis_offset_x, 0, servo_z1/2 + servo_axis_h/2])
            cylinder (r = servo_mount_hole_r, h = servo_axis_h, center = true, $fn = resolution);
    }
}

module servo() {
    translate([-servo_axis_offset_x, 0, 0]) {
        difference() {
            servo_body();
            servo_mounting_holes();
        }
    }
}

//servo();
