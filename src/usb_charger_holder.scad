// USB charger holder: flat mounting plate with a recessed box (pocket)
// for a USB charger. Final version (v6), rewritten as parametric OpenSCAD
// from the original trimesh build script (build_v6.py). All sizes in mm.

/* [Plate] */
plate_w = 70;        // plate width (X)
plate_l = 88;        // plate length (Y)
plate_t = 4;         // plate thickness

/* [Box / pocket] */
in_w  = 32;          // inner pocket width (X)
in_l  = 50;          // inner pocket length (Y)
depth = 27;          // pocket depth, measured from the box floor up to the plate top
wall  = 4;           // box wall and floor thickness

/* [Cable slot] */
slot_w = 22;         // cable slot width (Y), cut through the floor and both long walls
slot_h = 5;          // slot height from the box bottom
slot_y = -9;         // slot centre offset along Y from the pocket centre

/* [Retaining grooves] */
groove = true;       // V-grooves in both long inner walls
groove_w = 6;        // groove width at the wall surface (Y)
groove_d = 3;        // groove depth into the wall (X)
groove_y = -9;       // groove centre offset along Y from the pocket centre

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
