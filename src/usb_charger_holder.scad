// USB charger holder: flat mounting plate with a recessed box (pocket)
// for a USB charger. v6 (test-printed, Anker Zolo 70W A121C) rewritten as
// parametric OpenSCAD, plus an Apple A1357 variant. All sizes in mm.
//
// Orientation (same for every variant): the charger stands in the pocket
// with its prong face DOWN on the box floor and its USB face UP, flush with
// the plate top. The prongs go through the floor slot into the socket/plug
// behind, the USB ports are reachable from the plate surface.
// Pocket = charger body + clearance; depth = body height along the
// prong->USB axis + clearance, so the USB face ends level with the plate.

/* [Variant] */
charger = "anker_zolo_70w";   // [anker_zolo_70w, apple_a1357]

/* [Apple A1357 (EU, USB-A) - measured by caliper, prongs excluded] */
apple_w = 46;  apple_l = 46;  apple_h = 28.5;  apple_clear = 0.5;

A = charger == "apple_a1357";

/* [Plate] */
plate_w = A ? 88 : 70;   // Apple: square plate so the screw holes clear the wider box
plate_l = 88;
plate_t = 4;

/* [Box / pocket] */
// Anker: the v6 pocket as printed (32 x 50, depth 27) - unchanged.
in_w  = A ? apple_w + 2*apple_clear : 32;
in_l  = A ? apple_l + 2*apple_clear : 50;
depth = A ? apple_h + apple_clear   : 27;
wall  = 4;

/* [Cable / prong slot] */
// EU prongs: 2 x ~4.8 mm at 19 mm spacing -> 22 mm wide slot fits both.
// A1357 prongs are centred on its 46x46 face, Anker's are off-centre (-9).
slot_w = 22;
slot_h = 5;
slot_y = A ? 0 : -9;

/* [Retaining grooves] */
// Anker v6 has V-grooves matching ribs on its side; the A1357 is a plain
// cube, so grooves are off for Apple.
groove = A ? false : true;
groove_w = 6;
groove_d = 3;
groove_y = -9;

/* [Screw holes] */
screw_d = 4.5;       // through-hole diameter
csk_d   = 9;         // countersink diameter (90°), opens on the box side of the plate
hole_inset = 7.5;    // hole centre distance from plate edges

$fn = 96;

total_h = depth + wall;
out_w = in_w + 2*wall;
out_l = in_l + 2*wall;
bx = (plate_w - out_w)/2;   // box outer origin
by = (plate_l - out_l)/2;
cx = plate_w/2; cy = plate_l/2;

module v_groove(xwall, s) {   // s = -1 left wall, +1 right wall
  translate([0, cy + groove_y, wall])
    linear_extrude(total_h)
      polygon([[xwall - 0.5*s, -groove_w/2 - 0.5], [xwall - 0.5*s, groove_w/2 + 0.5],
               [xwall, groove_w/2], [xwall + groove_d*s, 0], [xwall, -groove_w/2]]);
}

difference() {
  union() {
    translate([0, 0, total_h - plate_t]) cube([plate_w, plate_l, plate_t]);
    translate([bx, by, 0]) cube([out_w, out_l, total_h]);
  }
  // pocket
  translate([bx + wall, by + wall, wall]) cube([in_w, in_l, total_h]);
  // cable slot through floor and long walls
  translate([bx - 1, cy + slot_y - slot_w/2, -1]) cube([out_w + 2, slot_w, slot_h + 1]);
  // grooves
  if (groove) { v_groove(bx + wall, -1); v_groove(bx + wall + in_w, 1); }
  // countersunk screw holes
  for (x = [hole_inset, plate_w - hole_inset], y = [hole_inset, plate_l - hole_inset])
    translate([x, y, 0]) {
      translate([0, 0, total_h - plate_t - 1]) cylinder(d = screw_d, h = plate_t + 2);
      translate([0, 0, total_h - plate_t - 0.5]) cylinder(d1 = csk_d + 1, d2 = 0, h = (csk_d + 1)/2);
    }
}
