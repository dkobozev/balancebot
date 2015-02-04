include <parameters.scad>;

arduino_x = 68.6;
arduino_y = 53.3;
arduino_z = 1.7;

arduino_usb_x = 16.2;
arduino_usb_y = 12.0;
arduino_usb_z = 10.5;
arduino_usb_offset_x = 1.9;
arduino_usb_offset_y = 9.2;

arduino_hole_r = 1.6;
arduino_hole1_x = 15.3;
arduino_hole1_y = 2.5;
arduino_hole2_x = arduino_hole1_x + 50.8;
arduino_hole2_y = arduino_hole1_y + 15.2;
arduino_hole3_x = arduino_hole2_x;
arduino_hole3_y = arduino_hole2_y + 27.9;
arduino_hole4_x = arduino_hole1_x - 1.3;
arduino_hole4_y = arduino_hole3_y + 5.1;

arduino_headers_z = 8.6;

gyro_x = 19;
gyro_y = 30.5;
gyro_z = 1.5;
gyro_hole_r = 1;
gyro_hole_x = 12.5;
gyro_hole_y = 25;
gyro_hole_z = 100;

accelerometer_x = 26.5;
accelerometer_y = 46.6;
accelerometer_z = 1.6;

accelerometer_hole1_x = 17.7;
accelerometer_hole1_y = 28 - accelerometer_y/2;
accelerometer_hole1_r = 1.25;
accelerometer_hole2_x = 0;
accelerometer_hole2_y = 30 - accelerometer_y/2;
accelerometer_hole2_r = 2.4;
accelerometer_hole_z = 100;

accelerometer_connector_x = 3.3;
accelerometer_connector_y = 13;
accelerometer_connector_z = 6;
accelerometer_connector_offset_x = accelerometer_x/2 - 7 + accelerometer_connector_x/2;
accelerometer_connector_offset_y = -accelerometer_y/2 + accelerometer_connector_y/2;

accelerometer_joy_x = 18.5;
accelerometer_joy_y = 18.5;
accelerometer_joy_z = 17;
accelerometer_joy_offset_x = (accelerometer_joy_x - 14)/2;
accelerometer_joy_offset_y = accelerometer_y/2 - 12.5;

module arduino_pcb() {
    union () {
        translate([0, -arduino_y, 0])
            color([50/255, 100/255, 112/255])
            cube ([arduino_x, arduino_y, arduino_z]);
        translate([arduino_usb_offset_x, -arduino_usb_offset_y - arduino_usb_y/2, arduino_usb_z/2 + arduino_z])
            color([191/255, 191/255, 191/255])
            cube ([arduino_usb_x, arduino_usb_y, arduino_usb_z], center = true);
    }
}

module arduino_pcb_holes(hole_r = arduino_hole_r) {
    translate([arduino_hole1_x, -arduino_hole1_y, 0])
        cylinder (r = hole_r, h = 100, center = true, $fn = resolution);
    translate([arduino_hole2_x, -arduino_hole2_y, 0])
        cylinder (r = hole_r, h = 100, center = true, $fn = resolution);
    translate([arduino_hole3_x, -arduino_hole3_y, 0])
        cylinder (r = hole_r, h = 100, center = true, $fn = resolution);
    translate([arduino_hole4_x, -arduino_hole4_y, 0])
        cylinder (r = hole_r, h = 100, center = true, $fn = resolution);
}

module arduino() {
    difference() {
        arduino_pcb();
        arduino_pcb_holes();
    }
}

module gyro_pcb() {
    color([50/255, 100/255, 112/255])
    cube([gyro_x, gyro_y, gyro_z], center = true);
}

module gyro_holes(hole_r = gyro_hole_r, z = gyro_hole_z) {
    translate([gyro_hole_x/2, gyro_hole_y/2, 0])
        cylinder (r = hole_r, h = z, center = true, $fn = resolution);
    translate([gyro_hole_x/2, -gyro_hole_y/2, 0])
        cylinder (r = hole_r, h = z, center = true, $fn = resolution);
    translate([-gyro_hole_x/2, gyro_hole_y/2, 0])
        cylinder (r = hole_r, h = z, center = true, $fn = resolution);
    translate([-gyro_hole_x/2, -gyro_hole_y/2, 0])
        cylinder (r = hole_r, h = z, center = true, $fn = resolution);
}

module gyro() {
    difference() {
        gyro_pcb();
        gyro_holes();
    }
}

module accelerometer_pcb() {
    color([50/255, 100/255, 112/255])
    cube ([accelerometer_x, accelerometer_y, accelerometer_z], center = true);
}

module accelerometer_holes(hole1_r = accelerometer_hole1_r,
                           hole2_r = accelerometer_hole2_r,
                           z       = accelerometer_hole_z) {
    translate([accelerometer_hole1_x/2, -accelerometer_hole1_y, 0])
        cylinder (r = hole1_r, h = z, center = true, $fn = resolution);
    translate([-accelerometer_hole1_x/2, -accelerometer_hole1_y, 0])
        cylinder (r = hole1_r, h = z, center = true, $fn = resolution);
    translate([accelerometer_hole2_x, -accelerometer_hole2_y, 0])
        cylinder (r = hole2_r, h = z, center = true, $fn = resolution);
}

module accelerometer_connector() {
    translate([accelerometer_connector_offset_x,
               accelerometer_connector_offset_y,
               -accelerometer_z/2 - accelerometer_connector_z/2])
        color([200/255, 200/255, 200/255])
        cube ([accelerometer_connector_x, accelerometer_connector_y, accelerometer_connector_z], center = true);
}

module accelerometer_joy() {
    translate([accelerometer_joy_offset_x, accelerometer_joy_offset_y, accelerometer_z/2 + accelerometer_joy_z/2])
        color([191/255, 191/255, 191/255])
        cube ([accelerometer_joy_x, accelerometer_joy_y, accelerometer_joy_z], center = true);
}

module accelerometer() {
    union() {
        difference() {
            accelerometer_pcb();
            accelerometer_holes();
        }
        accelerometer_connector();
        accelerometer_joy();
    }
}


//arduino();
//gyro();
//accelerometer();
