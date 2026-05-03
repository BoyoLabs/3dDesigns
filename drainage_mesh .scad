// Plant Drainage Mesh
// A circular mesh disc to prevent soil from falling through pot drainage holes
//by Boyo Labs

// ===== PARAMETERS =====
diameter      = 50.8;   // 2 inches in mm
thickness     = 3.175;  // 0.125 inches in mm
hole_size     = 3.0;    // size of each hexagonal hole (mm across flats)
wall_thickness = 0.8;   // thickness of mesh walls between holes
rim_width     = 1.5;    // solid rim around the edge for strength

$fn = 64;

// ===== DERIVED VALUES =====
radius        = diameter / 2;
inner_radius  = radius - rim_width;
hex_spacing   = hole_size + wall_thickness;
hex_radius    = hole_size / 2;  // radius across flats

// Calculate how many hexagons we need to cover the disc
// Using a generous range to ensure full coverage
hex_count = ceil(diameter / hex_spacing) + 2;

// ===== MODULE: Single hexagonal hole =====
module hex_hole() {
    rotate([0, 0, 30])
        cylinder(h = thickness + 2,
                 r = hex_radius / cos(30),
                 $fn = 6,
                 center = true);
}

// ===== MODULE: Grid of hex holes =====
module hex_grid() {
    for (row = [-hex_count : hex_count]) {
        // Offset every other row for honeycomb pattern
        x_offset = (row % 2 == 0) ? 0 : hex_spacing / 2;
        y_pos = row * hex_spacing * sin(60);

        for (col = [-hex_count : hex_count]) {
            x_pos = col * hex_spacing + x_offset;

            // Only place hex if its center is within inner radius
            if (sqrt(x_pos*x_pos + y_pos*y_pos) < inner_radius - hex_radius) {
                translate([x_pos, y_pos, 0])
                    hex_hole();
            }
        }
    }
}

// ===== MAIN ASSEMBLY =====
difference() {
    // Solid disc
    cylinder(h = thickness, r = radius, center = false);

    // Subtract hex holes
    translate([0, 0, thickness / 2])
        hex_grid();
}
