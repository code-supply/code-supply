include <BOSL2/std.scad>
include <BOSL2/shapes2d.scad>
include <BOSL2/shapes3d.scad>

$fa = 2;
$fs = 0.8;

platter_diameter = 343;

adapter_diameter = 39;
adapter_first_depth = 6;
adapter_max_depth = 10;
adapter_offset_x = 29;
adapter_offset_y = 30;

button_leg_diameter = 1;
button_distance = 13;

encoder_cutout_width = 14.5;
encoder_cutout_length = 14;
encoder_cutout_depth = 5;
encoder_cutout_lip_depth = 0.5;
encoder_pin_width = 1;
encoder_pin_depth = 0.5;
encoder_switch_pin_distance = 5;

hole_spacing = 2.54;

main_depth = 10;

plug_width = 12.4;
plug_length = 40;

board_length = 37;
board_width = 18.2;
board_padding = 0.5;

module board() {
  translate([36.5, 47.5, 1.5])
    rotate(a=90, v=[0, 0, 1])
      import("/home/andrew/Downloads/Pro Micro usb C.stl", convexity=10);
}

// board();

module board_cutout() {
  translate([2, 0, 0])
    cuboid(
      size=[board_length + board_padding, board_width + board_padding, 5],
      anchor=FRONT + LEFT + BOT
    );

  translate([0, 9.5, 2.75])
    rotate(a=90, v=[0, 1, 0])
      linear_extrude(3)
        rect(
          [3.5, 10],
          rounding=1,
          anchor=[0, 0]
        );

  translate([0, ( (board_width + board_padding) / 2) - ( (plug_width + board_padding) / 2), 0])
    rotate(a=90, v=[0, 0, 1])
      cuboid(
        size=[plug_width + board_padding, plug_length, 5],
        anchor=FRONT + LEFT + BOT
      );
}

module encoder_cutout() {
  difference() {
    cuboid(
      size=[encoder_cutout_width, encoder_cutout_length, encoder_cutout_depth],
      anchor=FRONT + LEFT + BOT
    );

    translate([0, 0, encoder_cutout_depth - encoder_cutout_lip_depth])
      cuboid(
        size=[encoder_cutout_width, 1, encoder_cutout_lip_depth],
        anchor=FRONT + LEFT + BOT
      );

    translate([0, encoder_cutout_length - 1, encoder_cutout_depth - encoder_cutout_lip_depth])
      cuboid(
        size=[encoder_cutout_width, 1, encoder_cutout_lip_depth],
        anchor=FRONT + LEFT + BOT
      );
  }
}

module button_holes() {
  cuboid(
    size=[button_leg_diameter, button_leg_diameter, 5]
  );

  translate([hole_spacing * 2, 0, 0])
    cuboid(
      size=[button_leg_diameter, button_leg_diameter, 5]
    );

  translate([0, hole_spacing * 3, 0]) {
    cuboid(
      size=[button_leg_diameter, button_leg_diameter, 5]
    );

    translate([hole_spacing * 2, 0, 0])
      cuboid(
        size=[button_leg_diameter, button_leg_diameter, 5]
      );
  }
}

difference() {
  cuboid(
    size=[150, 130, main_depth],
    rounding=4,
    edges=TOP + LEFT + FRONT,
    anchor=FRONT + LEFT + BOT
  );

  rotate(a=-45, v=[0, 0, 1])
    translate([-30, 47, 2])
      board_cutout();

  translate([15, 23, 0.01])
    rotate(a=-45, v=[0, 0, 1])
      encoder_cutout();

  for (distance = [0:button_distance:button_distance * 3]) {
    translate([40 + distance, 7.5, 3])
      button_holes();
  }

  translate([167, 173, -9])
    cyl(
      l=main_depth + 10,
      r1=platter_diameter / 2,
      r2=platter_diameter / 2,
      center=false,
      rounding2=-8
    );

  // cut in half for assembly
  translate([0, 0, 5])
    cuboid(
      size=[150, 130, main_depth],
      anchor=FRONT + LEFT + BOT
    );
}

difference() {
  translate([adapter_offset_x, adapter_offset_y, -adapter_max_depth])
    cyl(l=adapter_max_depth, r1=adapter_diameter / 2, r2=adapter_diameter / 2, center=false);

  translate([adapter_offset_x - (adapter_diameter / 2) + 13, 0, -adapter_first_depth])
    cuboid(size=[110, 120, 20], anchor=FRONT + LEFT + TOP);

  translate([adapter_offset_x - (adapter_diameter / 2) + 13, 0, -adapter_first_depth])
    rotate(a=45, v=[0, 1, 0])
      cuboid(size=[110, 120, 20], anchor=FRONT + LEFT + TOP);
}
