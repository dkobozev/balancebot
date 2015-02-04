resolution = 100;

aa_batteries_block_x = 63.6;
aa_batteries_block_y = 58;
aa_batteries_block_z = 16.2;

aa_batteries_block_thick = 2;

aa_battery_r = 7;
aa_battery_h = 50;

aa_batteries_block_hole_r = 1.25;
aa_batteries_block_hole_x = 57.5;
aa_batteries_block_hole_z = 100;


module aa_batteries_4() {
    spacing = aa_battery_r + 0.5;
    rotate([90, 0, 0]) {
        translate([spacing, 0, 0])
            cylinder (r = aa_battery_r, h = aa_battery_h, center = true, $fn = resolution);
        translate([spacing*3, 0, 0])
            cylinder (r = aa_battery_r, h = aa_battery_h, center = true, $fn = resolution);
        translate([-spacing, 0, 0])
            cylinder (r = aa_battery_r, h = aa_battery_h, center = true, $fn = resolution);
        translate([-spacing*3, 0, 0])
            cylinder (r = aa_battery_r, h = aa_battery_h, center = true, $fn = resolution);
    }
}

module aa_battery_block_holes() {
    translate([aa_batteries_block_hole_x/2, 0, 0])
        cylinder(r = aa_batteries_block_hole_r, h = aa_batteries_block_hole_z, center = true, $fn = resolution);
    translate([-aa_batteries_block_hole_x/2, 0, 0])
        cylinder(r = aa_batteries_block_hole_r, h = aa_batteries_block_hole_z, center = true, $fn = resolution);
}

module aa_battery_block_body() {
    difference() {
        cube ([aa_batteries_block_x, aa_batteries_block_y, aa_batteries_block_z], center = true);
        translate([0, 0, aa_batteries_block_thick])
            cube ([aa_batteries_block_x - aa_batteries_block_thick*2,
                   aa_batteries_block_y - aa_batteries_block_thick*2,
                   aa_batteries_block_z],
                   center = true);
        aa_battery_block_holes();
    }
}

module aa_battery_block() {
    color([0.2, 0.2, 0.2])
    aa_battery_block_body();
    color([231/255, 144/255, 51/255])
    aa_batteries_4();
}

//aa_battery_block();
