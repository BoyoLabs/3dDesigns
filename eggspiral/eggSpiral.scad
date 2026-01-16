// --- Parameters ---
egg_diameter = 45;      
clearance = 10;         
track_width = egg_diameter + clearance;
outer_wall_height = 25;  
inner_wall_height = 5;   
track_thickness = 3;
central_pillar_r = 20;  
spiral_pitch = 90;      
rotations = 3;          
segments = 80;          // Increased for smoother walls

// --- Calculations ---
total_steps = segments * rotations;
step_angle = 360 / segments;
step_height = spiral_pitch / segments;

module spiral_egg_dispenser_v3() {
    // 1. Central Support Pillar
    cylinder(h = spiral_pitch * rotations + 10, r = central_pillar_r, $fn = segments);

    // 2. The Spiral Track
    for (i = [0 : total_steps - 1]) {
        hull() {
            rotate([0, 0, i * step_angle])
            translate([0, 0, i * step_height])
            track_profile();

            rotate([0, 0, (i + 1) * step_angle])
            translate([0, 0, (i + 1) * step_height])
            track_profile();
        }
    }
    
    // 3. The End Stop (The "Brake")
    // This places a wall at the very end of the spiral path
    rotate([0, 0, 0]) // Positioned at the start/end of the rotation
    translate([central_pillar_r, -2, 0])
    cube([track_width + 3, 4, 30]);

    // 4. Wide Base Plate
    cylinder(h = 3, r = central_pillar_r + track_width + 10, $fn = segments);
}

module track_profile() {
    // The Track Floor (Tilted 5 degrees inward)
    rotate([5, 0, 0]) 
    translate([central_pillar_r, -0.5, 0])
    cube([track_width, 1, track_thickness]);

    // Outer Safety Wall
    translate([central_pillar_r + track_width, -0.5, 0])
    cube([3, 1, outer_wall_height]);
    
    // Inner Lip
    translate([central_pillar_r, -0.5, 0])
    cube([1, 1, inner_wall_height]);
}

// Render
spiral_egg_dispenser_v3();
