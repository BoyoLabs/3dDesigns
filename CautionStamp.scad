// --- Boyo Labs CautionStamp ---
// --- User Defined Dimensions (mm) ---
stamp_width = 76.2;       // Exactly 3 inches
stamp_height = 55;        // Increased height to prevent vertical overlap
base_thickness = 12;      // Reinforced for heavy press pressure
text_relief = 3;          // Depth of the imprint
corner_radius = 5;        // Smooth corners for vinyl safety
font_type = "Liberation Sans:style=Bold";

// --- Rendering Settings ---
$fn = 64; 

// --- Construction ---
mirror([1, 0, 0]) { // Mirrored for correct stamping orientation
    union() {
        // 1. Reinforced Base Plate
        linear_extrude(height = base_thickness) {
            offset(r = corner_radius) {
                square([stamp_width - (corner_radius*2), stamp_height - (corner_radius*2)], center = true);
            }
        }

        // 2. The Text Imprint (Sizes and positions adjusted to stop overlapping)
        translate([0, 0, base_thickness]) {
            linear_extrude(height = text_relief) {
                // "CAUTION" - Size reduced from 11.5 to 9.5 to fit inside border
                translate([0, 13, 0])
                    text("CAUTION", size = 9.5, font = font_type, halign = "center", valign = "center", spacing = 1.15);
                
                // "DO NOT SIT"
                translate([0, -2, 0])
                    text("DO NOT SIT", size = 6.0, font = font_type, halign = "center", valign = "center", spacing = 1.05);
                
                // "ON SEAT BACK"
                translate([0, -14, 0])
                    text("ON SEAT BACK", size = 6.0, font = font_type, halign = "center", valign = "center", spacing = 1.05);
            }
        }
        
        // 3. Structural Border (Positioned to avoid text collision)
        translate([0, 0, base_thickness]) {
            linear_extrude(height = text_relief) {
                difference() {
                    // Outer frame - scaled to stay within the 3 inch width
                    offset(r = -2)
                        square([stamp_width, stamp_height], center = true);
                    // Inner cutout - creates a 2mm thick border line
                    offset(r = -4)
                        square([stamp_width, stamp_height], center = true);
                }
            }
        }
    }
}
