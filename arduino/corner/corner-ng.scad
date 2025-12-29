include <BOSL2/std.scad>
include <BOSL2/shapes2d.scad>
include <BOSL2/shapes3d.scad>

$fa = 2;
$fs = 0.8;
eps = 0.001;

board_depth = 10;
platter_diameter = 360;

arduino_length = 37;
arduino_width = 18.2;
arduino_depth = 2.75;
arduino_padding = 0.5;

button_hole_spacing = 2.54;
button_leg_diameter = 1.25;
button_distance = 13;

plug_width = 12.4;
plug_length = 40;

arduino_socket_width = 9.5;

diff(keep="lip")

  cuboid(
    size=[110, 75, board_depth],
    edges=TOP,
    anchor=FRONT + LEFT + BOT
  ) {
    align(LEFT + FRONT + TOP, inside=true, shiftout=eps)
      back(60) right(35)
          platter();

    align(LEFT + FRONT + TOP, inside=true, shiftout=eps)
      back(35) right(25)
          arduino();

    back(20) right(15)
        align(LEFT + FRONT + TOP, inside=true, shiftout=eps)
          cuboid(size=[14, 14.5, 5], spin=45)
            tag("lip")
              align(LEFT + FRONT + TOP, inside=true)
                color("red")
                  rect_tube(size=[14, 14.5], wall=1, h=0.5);

    align(LEFT + FRONT + TOP, inside=true, shiftout=eps)
      back(12.5) right(35)
          button_leg_holes()
            align(RIGHT) right(button_distance)
                button_leg_holes()
                  align(RIGHT) right(button_distance)
                      button_leg_holes()
                        align(RIGHT) right(button_distance)
                            button_leg_holes();
    ;
  }

module arduino() {
  cuboid(
    size=[arduino_width + arduino_padding, arduino_length + arduino_padding, arduino_depth],
    spin=45
  ) {
    back(plug_length)
      align(FRONT + TOP, inside=true, shiftout=eps)
        cuboid(
          size=[plug_width + arduino_padding, plug_length, arduino_depth],
          anchor=FRONT + LEFT + BOT
        );

    back(3) up(1)
        align(BACK + TOP, inside=true, shiftout=eps)
          cuboid(
            size=[arduino_socket_width + arduino_padding, 6, arduino_depth],
            anchor=FRONT + LEFT + BOT,
            rounding=0.5
          );
  }
}

module platter() {
  cyl(
    h=board_depth + 10,
    d=platter_diameter,
    chamfer2=-4
  );
}

module button_leg_holes() {
  button_leg_hole() {
    right(button_hole_spacing)
      align(RIGHT)
        button_leg_hole();

    fwd(button_hole_spacing)
      align(FRONT)
        button_leg_hole();

    right(button_hole_spacing) fwd(button_hole_spacing)
        align(FRONT + RIGHT)
          button_leg_hole();

    children();
  }
}

module button_leg_hole() {
  cuboid(size=[button_leg_diameter, button_leg_diameter, 5]) children();
}
