// Traditional Kuksa (Finnish/Sámi cup)
// - Flat top (z = 0) for support-free printing top-down
// - Flat bottom so the cup sits on a table
// - Solid, ergonomic handle (no finger holes)
//
// Print orientation: place the flat top (z = 0 face) on the build plate.
// The body extends into -z. Uncomment the mirror() at the bottom if your
// slicer prefers all-positive Z geometry.

$fn = 140;

// =========================
// Bowl
// =========================
bowl_top_dia      = 90;   // outer diameter at the rim (top)
bowl_belly_dia    = 94;   // outer diameter at the widest point of the belly
bowl_bottom_dia   = 60;   // outer diameter at the flat bottom pad
bowl_height       = 70;   // total cup height (rim down to flat bottom)
belly_pos         = 0.45; // 0..1 down the bowl, where the belly is widest
shoulder_pos      = 0.85; // 0..1 down the bowl, where it tucks in for the foot

wall_thickness    = 4.5;
bottom_thickness  = 6;

// =========================
// Handle (ergonomic, solid)
// =========================
handle_length     = 78;   // distance from bowl edge to far tip
handle_neck_w     = 28;   // width where it meets the bowl
handle_neck_t     = 14;   // thickness (top->bottom) at the neck
handle_grip_w     = 38;   // width at the fattest grip point
handle_grip_t     = 22;   // thickness at the fattest grip point
handle_tip_w      = 18;   // width at the tip
handle_tip_t      = 10;   // thickness at the tip
grip_pos          = 0.55; // 0..1 along handle: where the fattest grip sits

rim_chamfer       = 1.0;

// ---------- BOWL ----------
// Build outer body as several stacked, hulled segments so the silhouette
// can be non-convex (rim narrower than belly, belly wider than foot, etc.)

module disc(z, d) {
    translate([0, 0, z]) cylinder(h = 0.01, d = d);
}

module bowl_outer_solid() {
    z_top      = 0;
    z_belly    = -bowl_height * belly_pos;
    z_shoulder = -bowl_height * shoulder_pos;
    z_bottom   = -bowl_height;

    // Average diameters along the way for smooth transitions.
    // Each hull is between adjacent cross-sections, which is always convex.
    hull() { disc(z_top, bowl_top_dia);          disc(z_belly,    bowl_belly_dia);  }
    hull() { disc(z_belly, bowl_belly_dia);      disc(z_shoulder, bowl_belly_dia*0.92); }
    hull() { disc(z_shoulder, bowl_belly_dia*0.92); disc(z_bottom, bowl_bottom_dia); }
    // Ensure a proper closed flat bottom
    translate([0, 0, z_bottom])
        cylinder(h = 0.5, d = bowl_bottom_dia, center = false);
    translate([0, 0, z_bottom + 0.5 - 0.01])
        cylinder(h = 0.01, d = bowl_bottom_dia);
}

module bowl_cavity() {
    // Inner cavity: open at z = 0, follows the outer shape inset by wall_thickness.
    in_top    = bowl_top_dia    - 2 * wall_thickness;
    in_belly  = bowl_belly_dia  - 2 * wall_thickness;
    in_bottom = max(8, bowl_bottom_dia - 2 * wall_thickness);
    in_h      = bowl_height - bottom_thickness;

    z_top      = 0.5;                       // open above the rim plane
    z_belly    = -in_h * belly_pos;
    z_shoulder = -in_h * shoulder_pos;
    z_inbot    = -in_h;

    hull() { disc(z_top, in_top);         disc(z_belly,    in_belly); }
    hull() { disc(z_belly, in_belly);     disc(z_shoulder, in_belly*0.92); }
    hull() {
        disc(z_shoulder, in_belly*0.92);
        // Rounded inner bottom: a squashed sphere instead of a flat disc
        translate([0, 0, z_inbot + in_bottom*0.25])
            scale([1, 1, 0.6]) sphere(d = in_bottom);
    }
}

// ---------- HANDLE ----------
// Smooth lofted form. Each cross-section is a flat-topped half-ellipsoid
// so the handle's top stays coplanar with the rim at z = 0.

module handle_section(x, w, t) {
    // Half-ellipsoid: full ellipsoid minus the half above z=0.
    // Width w (Y), depth t (downward Z), short length in X for hulling.
    intersection() {
        translate([x, 0, 0])
            scale([0.6, w/2, t]) sphere(r = 1);
        // Clip cube: spans z in [-400, 0], plenty wide in x/y
        translate([-200, -200, -400])
            cube([400, 400, 400]);
    }
}

module handle_solid() {
    // Anchor the handle so it merges with the outer bowl wall, not the cavity.
    bowl_r = bowl_top_dia / 2;
    // Root sits on/just inside the outer wall. The cavity is inset by
    // wall_thickness, so any x > bowl_r - wall_thickness stays in solid material.
    x_root = bowl_r - wall_thickness * 0.5;
    x_neck = bowl_r + 8;                               // clearly outside bowl
    x_grip = bowl_r + handle_length * grip_pos;
    x_tip  = bowl_r + handle_length;

    // Chain of hulls between adjacent stations -> smooth, non-convex profile
    hull() {
        handle_section(x_root, handle_neck_w*0.9, handle_neck_t*0.9);
        handle_section(x_neck, handle_neck_w,     handle_neck_t);
    }
    hull() {
        handle_section(x_neck, handle_neck_w, handle_neck_t);
        handle_section((x_neck + x_grip)/2,
                       (handle_neck_w + handle_grip_w)/2,
                       (handle_neck_t + handle_grip_t)/2);
        handle_section(x_grip, handle_grip_w, handle_grip_t);
    }
    hull() {
        handle_section(x_grip, handle_grip_w, handle_grip_t);
        handle_section((x_grip + x_tip)/2,
                       (handle_grip_w + handle_tip_w)/2,
                       (handle_grip_t + handle_tip_t)/2);
        handle_section(x_tip,  handle_tip_w,  handle_tip_t);
    }
}

// ---------- ASSEMBLY ----------
module kuksa() {
    difference() {
        union() {
            bowl_outer_solid();
            handle_solid();
        }
        bowl_cavity();

        // Inside-rim chamfer so the lip isn't razor-sharp
        translate([0, 0, -rim_chamfer])
            difference() {
                cylinder(h = rim_chamfer + 0.02,
                         d1 = bowl_top_dia,
                         d2 = bowl_top_dia - 2*rim_chamfer);
                translate([0, 0, -0.01])
                    cylinder(h = rim_chamfer + 0.04,
                             d = bowl_top_dia - 2*wall_thickness);
            }

        // Safety: nothing above z = 0 (keeps the top perfectly flat)
        translate([0, 0, 0])
            linear_extrude(height = 80)
                square([500, 500], center = true);
    }
}

// ---------- RENDER ----------
// Flat top at z = 0, body grows downward into -z.
// Uncomment to flip if your slicer prefers +z geometry.
// mirror([0,0,1])
kuksa();
