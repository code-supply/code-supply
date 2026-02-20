include <BOSL2/std.scad>
include <BOSL2/shapes2d.scad>
include <BOSL2/shapes3d.scad>

$fa = 0.5;
$fs = 0.2;

eps = 0.001;

box_diameter = 20;
box_height = 10;

// base();
lid();

module lid() {
  intersection() {
    whole();
    up(box_diameter / 2 + eps)
      cuboid(box_diameter + eps);
  }
}

module base() {
  difference() {
    whole();
    up(box_diameter / 2 - eps)
      cuboid(box_diameter + eps);
  }
}

module whole() {
  diff(keep="lip")

    cuboid(
      size=[box_diameter, box_diameter, box_height]
    ) {
      align(BOTTOM + CENTER, inside=true, shiftout=eps)
        cuboid(size=[14, 14.5, 5]) {
          tag("lip")
            align(LEFT + FRONT + TOP, inside=true, shiftout=eps)
              color("red")
                rect_tube(size=[14, 14.5], wall=1, h=0.5);

          align(TOP, shiftout=eps)
            cyl(
              h=box_height,
              r=3.5
            );
        }
    }
}
