include <BOSL2/std.scad>
include <BOSL2/shapes3d.scad>

$fa = 1;
$fs = 0.4;

platter_diameter = 335;

adapter_diameter = 38.9;
adapter_first_depth = 7.5;
adapter_max_depth = 11.5;
adapter_recess_width = 11.7;
adapter_offset = 32.8;

difference() {
  cuboid(size=[110, 120, 10], chamfer=1, anchor=FRONT + LEFT + BOT);

  translate([175, 175, -1])
    cyl(
      l=20,
      r1=platter_diameter / 2,
      r2=platter_diameter / 2,
      center=false
    );
}

difference() {
  translate([adapter_offset, adapter_offset, -adapter_max_depth])
    cyl(l=adapter_max_depth, r1=adapter_diameter / 2, r2=adapter_diameter / 2, center=false);

  translate([adapter_offset - (adapter_diameter / 2) + 16.25, 0, -adapter_first_depth])
    cuboid(size=[110, 120, 20], anchor=FRONT + LEFT + TOP);

  translate([adapter_offset - (adapter_diameter / 2) + 16.25, 0, -adapter_first_depth])
    rotate(a=45, v=[0, 1, 0])
      cuboid(size=[110, 120, 20], anchor=FRONT + LEFT + TOP);
}
