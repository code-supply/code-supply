include <BOSL2/std.scad>
include <BOSL2/shapes3d.scad>

$fa = 1;
$fs = 0.4;

platter_diameter = 345;

adapter_diameter = 38.9;
adapter_first_depth = 5;
adapter_max_depth = 9;
adapter_offset_x = 32.8;
adapter_offset_y = 34.0;

difference() {
  cuboid(size=[110, 120, 0.4], chamfer=0, anchor=FRONT + LEFT + BOT);

  translate([175, 175, -1])
    cyl(
      l=20,
      r1=platter_diameter / 2,
      r2=platter_diameter / 2,
      center=false
    );
}

difference() {
  translate([adapter_offset_x, adapter_offset_y, -adapter_max_depth])
    cyl(l=adapter_max_depth, r1=adapter_diameter / 2, r2=adapter_diameter / 2, center=false);

  translate([adapter_offset_x - (adapter_diameter / 2) + 16.25, 0, -adapter_first_depth])
    cuboid(size=[110, 120, 20], anchor=FRONT + LEFT + TOP);

  translate([adapter_offset_x - (adapter_diameter / 2) + 16.25, 0, -adapter_first_depth])
    rotate(a=45, v=[0, 1, 0])
      cuboid(size=[110, 120, 20], anchor=FRONT + LEFT + TOP);
}
