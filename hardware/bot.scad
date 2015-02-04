include <parameters.scad>;
include <servo.scad>;
include <arduino.scad>;
include <batteries.scad>;


bot_wheel_r = 33.25;
bot_wheel_h = 7.6;

bot_wheel_cutout_r = 30;
bot_wheel_cutout_h = 4;

bot_wheel_hub_r = 10;
bot_wheel_hub_h = 2;

bot_wheel_hole_r = 5.5;
bot_wheel_hole_h = bot_wheel_h;
bot_wheel_hole_x = 17.8;

bot_platform_x = 85;
bot_platform_y = 110;
bot_platform_z = 3;

bot_base_side_x = bot_platform_z;
bot_base_side_y = bot_platform_y;
bot_base_side_z = servo_y + 5;
bot_base_servo_z = 3; // spacing between the platform and the servos
bot_base_pcb_z = 5; // spacing between the pcb board and the base

bot_rod_r = 1.95;
bot_rod_h = 304.8;
bot_rod_x = 10; // offset relative to the edge of the platform
bot_rod_y = 10; // offset relative to the edge of the platform
bot_rod_z = 150; // offset relative to the center of the rod

bot_platform_corner_d = 16;
bot_platform_corner_z = 7;

bot_battery_platform_z = 150;
bot_battery_platform_batteries_z = 0;
bot_battery_platform_w_r = 4.5; // wire hole radius
bot_battery_platform_w_z = 100;
bot_battery_platform_w_x = 15;
bot_battery_platform_w_y = aa_batteries_block_x/2 + bot_battery_platform_w_r*2;

bot_gyro_platform_z = 75;
bot_gyro_x = -20;
bot_gyro_y = 0;
bot_gyro_z = 5;
bot_accelerometer_x = 20;
bot_accelerometer_y = 0;
bot_accelerometer_z = 12;

bot_gyro_platform_screw_r = 0.6;
bot_gyro_platform_tie_r = 2; // cable tie hole r
bot_gyro_platform_tie_x = 8;
bot_gyro_platform_tie_y = 25;
bot_gyro_platform_tie_z = bot_platform_z * 2;

bot_gyro_platform_cable_r = 5;
bot_gyro_platform_cable_x = 0;
bot_gyro_platform_cable_y = 40;
bot_gyro_platform_cable_z = bot_platform_z * 2;

module wheel() {
    union() {
        difference() {
            cylinder (r = bot_wheel_r, h = bot_wheel_h, center = true, $fn = resolution);
            translate([0, 0, bot_wheel_h/2])
                cylinder (r = bot_wheel_cutout_r, h = bot_wheel_cutout_h, center = true, $fn = resolution);
            translate([0, 0, -bot_wheel_h/2])
                cylinder (r = bot_wheel_cutout_r, h = bot_wheel_cutout_h, center = true, $fn = resolution);

            // holes
            for (i = [0 : 40 : 360]) {
                rotate ([0, 0, i])
                scale([1, 0.7, 1])
                translate ([bot_wheel_hole_x, 0, 0])
                    cylinder (r = bot_wheel_hole_r, h = bot_wheel_hole_h, center = true, $fn = resolution);
            }
        }

        // hub
        translate([0, 0, bot_wheel_h/2 - bot_wheel_hub_h/2])
            cylinder (r = bot_wheel_hub_r, h = bot_wheel_hub_h, center = true, $fn = resolution);
        translate([0, 0, -bot_wheel_h/2 + bot_wheel_hub_h/2])
            cylinder (r = bot_wheel_hub_r, h = bot_wheel_hub_h, center = true, $fn = resolution);
    }
}

module wheel_assembly() {
    translate ([0, 0, bot_wheel_h/2 + servo_axis_spacing + servo_z1 - servo_z2 + servo_mount_thickness/2]) {
        union() {
            wheel();
            translate ([0, 0, -bot_wheel_h/2 - servo_z1/2 - servo_axis_spacing])
                servo();
        }
    }
}

module bot_platform() {
    cube ([bot_platform_x, bot_platform_y, bot_platform_z], center = true);

    // corners
    translate([0, 0, -bot_platform_z/2 - bot_platform_corner_z/2]) {
        translate([bot_platform_x/2 - bot_platform_corner_d/2, bot_platform_y/2 - bot_platform_corner_d/2, 0]) {
            cube ([bot_platform_corner_d, bot_platform_corner_d, bot_platform_corner_z], center = true);
        }
        translate([bot_platform_x/2 - bot_platform_corner_d/2, -bot_platform_y/2 + bot_platform_corner_d/2, 0]) {
            cube ([bot_platform_corner_d, bot_platform_corner_d, bot_platform_corner_z], center = true);
        }
        translate([-bot_platform_x/2 + bot_platform_corner_d/2, bot_platform_y/2 - bot_platform_corner_d/2, 0]) {
            cube ([bot_platform_corner_d, bot_platform_corner_d, bot_platform_corner_z], center = true);
        }
        translate([-bot_platform_x/2 + bot_platform_corner_d/2, -bot_platform_y/2 + bot_platform_corner_d/2, 0]) {
            cube ([bot_platform_corner_d, bot_platform_corner_d, bot_platform_corner_z], center = true);
        }
    }
}

module bot_rods() {
    translate ([bot_platform_x/2 - bot_rod_x, bot_platform_y/2 - bot_rod_y, 0])
        cylinder (r = bot_rod_r, h = bot_rod_h, center = true, $fn = resolution);
    translate ([bot_platform_x/2 - bot_rod_x, -bot_platform_y/2 + bot_rod_y, 0])
        cylinder (r = bot_rod_r, h = bot_rod_h, center = true, $fn = resolution);
    translate ([-bot_platform_x/2 + bot_rod_x, bot_platform_y/2 - bot_rod_y, 0])
        cylinder (r = bot_rod_r, h = bot_rod_h, center = true, $fn = resolution);
    translate ([-bot_platform_x/2 + bot_rod_x, -bot_platform_y/2 + bot_rod_y, 0])
        cylinder (r = bot_rod_r, h = bot_rod_h, center = true, $fn = resolution);
}

module bot_base_side() {
    cube ([bot_base_side_x, bot_base_side_y, bot_base_side_z], center = true);
}

module bot_base_slope() {
    cut_w = bot_platform_x + 1;
    translate([-cut_w/2, bot_platform_y/2, bot_platform_z/2])
    rotate([-120, 0, 0])
        cube ([cut_w, bot_base_side_y, bot_base_side_z]);
}

module bot_base() {

    difference() {
        translate ([0, 0, servo_y/2 + bot_platform_z/2 + bot_base_servo_z])
            difference() {
                union() {
                    bot_platform();

                    // sides
                    translate([-bot_platform_x/2 + bot_base_side_x/2, 0, -bot_base_side_z/2 - bot_platform_z/2])
                        bot_base_side();
                    translate([bot_platform_x/2 - bot_base_side_x/2, 0, -bot_base_side_z/2 - bot_platform_z/2])
                        bot_base_side();
                }

                bot_base_slope();
                mirror([0, 1, 0])
                    bot_base_slope();

                // cut holes for the rods
                bot_rods();

                // cut holes for the pcb
                rotate([0, 0, 90])
                translate([-arduino_x/2, arduino_y/2, servo_y/2 + bot_platform_z + bot_base_servo_z + bot_base_pcb_z])
                    arduino_pcb_holes();
            }

        // cut holes for the servos
        translate([-bot_platform_x/2 - .1, 0, 0])
        rotate ([90, 0, -90]) {
            servo();
            translate([-servo_axis_offset_x, 0, 0])
                servo_mounting_holes();
        }
        // all the way through
        translate([-bot_platform_x/2 - .1, 0, -servo_y/2])
        rotate ([90, 0, -90])
            servo();

        translate([bot_platform_x/2 + .1, 0, 0])
        rotate ([90, 0, 90]) {
            servo();
            translate([-servo_axis_offset_x, 0, 0])
                servo_mounting_holes();
        }
        translate([bot_platform_x/2 + .1, 0, -servo_y/2])
        rotate ([90, 0, 90])
            servo();
    }

    // wheel assemblies
    translate([-bot_platform_x/2, 0, 0])
    rotate ([90, 0, -90])
        wheel_assembly();

    translate([bot_platform_x/2, 0, 0])
    rotate ([90, 0, 90])
        wheel_assembly();
}

module bot_battery_platform(batteries = 1) {
    translate([0, 0, bot_battery_platform_z]) {
        difference() {
            bot_platform();
            bot_rods();
            translate([0, 0, aa_batteries_block_z/2 + bot_battery_platform_batteries_z])
            rotate([0, 0, 90])
                aa_battery_block_holes();

            // cut wire hole
            translate([-bot_battery_platform_w_x, bot_battery_platform_w_y, 0])
                cylinder(r = bot_battery_platform_w_r, h = bot_battery_platform_w_z, center = true, $fn = resolution);
        }

        if (batteries) {
            translate([0, 0, aa_batteries_block_z/2 + bot_battery_platform_batteries_z])
            rotate([0, 0, 90])
                aa_battery_block();
        }
    }
}

module bot_gyro_standoffs(x, y, z) {
    translate([gyro_hole_x/2, gyro_hole_y/2, 0])
        cube ([x, y, z], center = true);
    translate([gyro_hole_x/2, -gyro_hole_y/2, 0])
        cube ([x, y, z], center = true);
    translate([-gyro_hole_x/2, gyro_hole_y/2, 0])
        cube ([x, y, z], center = true);
    translate([-gyro_hole_x/2, -gyro_hole_y/2, 0])
        cube ([x, y, z], center = true);
}

module bot_accelerometer_standoffs(x1, y1, x2, y2, z) {
    translate([accelerometer_hole1_x/2, -accelerometer_hole1_y, 0])
        cube ([x1, y1, z], center = true);
    translate([-accelerometer_hole1_x/2, -accelerometer_hole1_y, 0])
        cube ([x1, y1, z], center = true);
    translate([accelerometer_hole2_x, -accelerometer_hole2_y, 0])
        cube ([x2, y2, z], center = true);
}

module bot_gyro_platform(pcbs = 1) {
    translate([0, 0, bot_gyro_platform_z]) {
        difference() {
            union() {
                rotate([180, 0, 0])
                    bot_platform();

                // standoffs
                translate([bot_gyro_x, bot_gyro_y, bot_gyro_z/2 - gyro_z/2])
                    bot_gyro_standoffs(gyro_hole_r*4, gyro_hole_r*4, bot_gyro_z);
                translate([bot_accelerometer_x, bot_accelerometer_y, bot_accelerometer_z/2 - accelerometer_z/2])
                    bot_accelerometer_standoffs(accelerometer_hole1_r*6, accelerometer_hole1_r*5, 0, 0, bot_accelerometer_z);
            }

            bot_rods();

            // standoff holes
            //translate([bot_gyro_x, bot_gyro_y, bot_gyro_z/2 - gyro_z/2])
            //    gyro_holes(bot_gyro_platform_screw_r, bot_gyro_z + gyro_z + bot_platform_z);
            //translate([bot_accelerometer_x, bot_accelerometer_y, bot_accelerometer_z/2 - accelerometer_z/2])
            //    accelerometer_holes(bot_gyro_platform_screw_r, 0, bot_accelerometer_z + accelerometer_z + bot_platform_z);

            // cable tie holes
            translate([bot_gyro_platform_tie_x, bot_gyro_platform_tie_y, 0])
                cylinder (r = bot_gyro_platform_tie_r, h = bot_gyro_platform_tie_z, center = true, $fn = resolution);
            translate([bot_gyro_platform_tie_x, -bot_gyro_platform_tie_y, 0])
                cylinder (r = bot_gyro_platform_tie_r, h = bot_gyro_platform_tie_z, center = true, $fn = resolution);
            translate([-bot_gyro_platform_tie_x, bot_gyro_platform_tie_y, 0])
                cylinder (r = bot_gyro_platform_tie_r, h = bot_gyro_platform_tie_z, center = true, $fn = resolution);
            translate([-bot_gyro_platform_tie_x, -bot_gyro_platform_tie_y, 0])
                cylinder (r = bot_gyro_platform_tie_r, h = bot_gyro_platform_tie_z, center = true, $fn = resolution);

            // cable holes
            translate([bot_gyro_platform_cable_x, bot_gyro_platform_cable_y, 0])
                cylinder (r = bot_gyro_platform_cable_r, h = bot_gyro_platform_cable_z, center = true, $fn = resolution);
            translate([bot_gyro_platform_cable_x, -bot_gyro_platform_cable_y, 0])
                cylinder (r = bot_gyro_platform_cable_r, h = bot_gyro_platform_cable_z, center = true, $fn = resolution);
        }

        if (pcbs) {
            translate([bot_gyro_x, bot_gyro_y, bot_gyro_z])
                gyro();
            translate([bot_accelerometer_x, bot_accelerometer_y, bot_accelerometer_z])
                accelerometer();
        }
    }
}

module bot() {
    bot_base();
    translate([0, 0, bot_rod_z])
        bot_rods();

    // arduino
    rotate([0, 0, 90])
    translate([-arduino_x/2, arduino_y/2, servo_y/2 + bot_platform_z + bot_base_servo_z + bot_base_pcb_z])
        arduino();

    bot_battery_platform();
    bot_gyro_platform();
}

//bot();
bot_gyro_platform(0);
