include <BOSL2/std.scad>
include <BOSL2/shapes2d.scad>
include <BOSL2/shapes3d.scad>

$fa = 0.5;
$fs = 0.2;

base_depth = 210;
lower_brace_length = 150;
lower_brace_depth_height = lower_brace_length / sqrt(2);

upper_brace_side = 209;
shelf_angle = 30;
brace_angle = 90 - shelf_angle;
brace_other_angle = (180 - brace_angle) / 2;

upper_brace_hypotenuse = 2 * upper_brace_side * sin(brace_angle / 2);

backward_lean = 8;
rise = 260;
bracket_width = 25;
bracket_height = 10;
shelf_depth = 220;
lip_height = 18;
chamfer = 3;

cuboid(size=[bracket_width, base_depth, bracket_height], chamfer=chamfer, edges=FRONT) {
  align(BACK + TOP)
    down(bracket_height / 2)
      fwd(bracket_height)
        rotate([-backward_lean, 0, 0])
          cuboid(size=[bracket_width, bracket_height, rise]) {
            align(FRONT + TOP)
              back(bracket_height)
                rotate([shelf_angle, 0, 0])
                  cuboid(size=[bracket_width, shelf_depth, bracket_height]) {
                    align(FRONT + TOP)
                      back(bracket_height)
                        cuboid(size=[bracket_width, bracket_height, lip_height], chamfer=chamfer, edges=TOP);
                  }
            ;

            align(FRONT + TOP)
              down(upper_brace_side + bracket_height / 2)
                rotate([-(90 - brace_other_angle), 0, 0])
                  cuboid(size=[bracket_width, upper_brace_hypotenuse, bracket_height]);
          }
  ;

  align(BACK + TOP)
    fwd(lower_brace_depth_height)
      down(bracket_height)
        fwd(bracket_height / 2)
          rotate([45 - backward_lean, 0, 0])
            cuboid(size=[bracket_width, lower_brace_length, bracket_height]);

  align(BACK + TOP)
    fwd(lower_brace_depth_height - 20)
      cuboid(size=[bracket_width, bracket_height, 210]);
}
