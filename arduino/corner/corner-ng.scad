include <BOSL2/std.scad>
include <BOSL2/shapes2d.scad>
include <BOSL2/shapes3d.scad>

$fa = 2;
$fs = 0.8;
eps = 0.001;

main_depth = 20;
platter_diameter = 360;

diff()

  cuboid(
    size=[110, 75, main_depth],
    chamfer=3,
    edges=TOP,
    anchor=FRONT + LEFT + BOT
  )

    align(LEFT + FRONT + TOP, inside=true, shiftout=eps)
      right(35)
        back(60)
          cyl(
            h=main_depth + 10,
            d=platter_diameter,
            chamfer2=-8
          );
