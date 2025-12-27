include <BOSL2/std.scad>
include <BOSL2/shapes2d.scad>
include <BOSL2/shapes3d.scad>

$fa = 2;
$fs = 0.8;

eps = 0.001;

box_diameter = 10;
box_height = box_diameter;
switch_socket_diameter = 8;
switch_socket_depth = 2.5;

shaft_socket_diameter = 4.5;
shaft_socket_height = box_height - switch_socket_depth;

shaft_diameter = shaft_socket_diameter - 1;

diff(keep="shaft")
  cuboid(size=box_diameter, anchor=BOTTOM)
    align(BOTTOM, inside=true, shiftout=eps)
      cuboid(size=[switch_socket_diameter, switch_socket_diameter, switch_socket_depth])
        align(TOP, overlap=eps)
          cyl(d=shaft_socket_diameter, h=box_height + 0.1)
            align(BOTTOM, inside=true) {
              cuboid(size=[shaft_socket_diameter + 2, 1, 5]);
              shaft();
            }

module shaft() {
  tag("shaft")
    cyl(d=shaft_diameter, h=shaft_socket_height)
      align(BOTTOM, inside=true)
        cuboid(size=[shaft_socket_diameter + 1, 0.5, 1]);
}
