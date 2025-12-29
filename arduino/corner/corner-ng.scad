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

plug_width = 12.4;
plug_length = 40;

arduino_socket_width = 9.5;

diff()

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
