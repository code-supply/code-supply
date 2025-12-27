include <BOSL2/std.scad>
include <BOSL2/shapes2d.scad>
include <BOSL2/shapes3d.scad>

$fa = 0.5;
$fs = 0.2;

eps = 0.001;

box_diameter = 20;
box_height = 10;

switch_socket_diameter = 6.5;
switch_socket_depth = 2.5;

shaft_socket_diameter = 10;
shaft_socket_height = box_height - switch_socket_depth;
shaft_bottom_gap = 0.5;
track_height = 7;
runner_height = track_height - 2;
runner_thickness = 0.6;

support_thickness = 0.2;

shaft_diameter = shaft_socket_diameter - 1.25;

diff(keep="shaft")
  cyl(d=box_diameter, h=box_height, anchor=BOTTOM)

    align(BOTTOM, inside=true, shiftout=eps)
      cuboid(size=[switch_socket_diameter, switch_socket_diameter, switch_socket_depth])
        align(TOP, overlap=eps)
          cyl(d=shaft_socket_diameter, h=box_height + 0.1)
            align(BOTTOM, inside=true) {
              cuboid(size=[shaft_socket_diameter + 2, 1, track_height]);
              cuboid(size=[1, shaft_socket_diameter + 2, track_height]);
              up(shaft_bottom_gap)
                shaft();
            }

module shaft() {
  tag("shaft")
    cyl(d=shaft_diameter, h=shaft_socket_height - shaft_bottom_gap)
      align(BOTTOM, inside=true)
        cuboid(size=[shaft_socket_diameter + 1, runner_thickness, runner_height])
          align(BOTTOM, inside=true)
            cuboid(size=[runner_thickness, shaft_socket_diameter + 1, runner_height])
              align(BOTTOM)
                down(0.4)
                  cuboid(size=[support_thickness, shaft_socket_diameter + 1, support_thickness]);
}
