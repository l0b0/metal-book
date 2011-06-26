// CONFIGURATION
// All sizes in millimeters

metal_thickness = 2;

magnet_z_size = 1;

// ISO 216 A5 paper default
paper_x_size = 148;
paper_y_size = 210;
paper_z_size = 0.1;
paper_sheet_count = ceil(365 / 2); // One page per day default

 // ISO 838 defaults (all positions/margins from center of hole)
filing_hole_y_positions = [0, 80];
filing_hole_y_center = 40; // Should be max(filing_hole_y_positions) / 2
filing_hole_radius = 3;
filing_hole_spine_margin = 12;
filing_hole_paper_margin = 10.5; // From hole to edge of overhang

facets = 40; // Granularity of circular objects
explode = false; // Set to true to see parts separately, and to get a manifold model

// CONFIGURATION END

// CALCULATIONS

// Calculate Cn size based on arithmetic progression
// https://secure.wikimedia.org/wikipedia/en/wiki/ISO_216
// Not completely accurate, but it's also parametric
outer_x_size = paper_x_size * pow(2, 1.0 / 8);
outer_y_size = paper_y_size * pow(2, 1.0 / 8);

text_block_x_size = paper_x_size;
text_block_y_size = paper_y_size;
text_block_z_size = paper_sheet_count * paper_z_size;
text_block_x_margin = (outer_x_size - paper_x_size) / 2; // Only applicable towards the clasp
text_block_y_margin = (outer_y_size - paper_y_size) / 2;
text_block_z_margin = 0; // Not applicable unless you want to add other things with the paper

spine_x_size = metal_thickness;
spine_y_size = outer_y_size;
spine_z_size = 2 * metal_thickness + text_block_z_size + text_block_z_margin;

text_block_x_position = spine_x_size;
text_block_y_position = text_block_y_margin; // Centers it

back_x_size = text_block_x_size + text_block_x_margin;
back_y_size = outer_y_size;
back_z_size = metal_thickness;
back_x_position = spine_x_size;
back_y_position = 0;
back_z_position = 0;

text_block_z_position = back_z_size;

overhang_x_size = filing_hole_spine_margin + filing_hole_paper_margin;
overhang_y_size = outer_y_size;
overhang_z_size = metal_thickness;
overhang_x_position = spine_x_size;
overhang_y_position = 0;
overhang_z_position = metal_thickness + text_block_z_size; // Make room for the back cover + paper

front_x_size = back_x_size - overhang_x_size;
front_y_size = outer_y_size;
front_z_size = metal_thickness;
front_x_position = overhang_x_position + overhang_x_size;
front_y_position = 0;
front_z_position = overhang_z_position;

clasp_fore_x_size = metal_thickness;
clasp_fore_y_size = outer_y_size;
clasp_fore_z_size = spine_z_size + magnet_z_size;
clasp_fore_x_position = back_x_position + back_x_size;
clasp_fore_y_position = 0;
clasp_fore_z_position = back_z_size;

clasp_front_x_size = overhang_x_size;
clasp_front_y_size = outer_y_size;
clasp_front_z_size = metal_thickness;
clasp_front_x_position = back_x_position + back_x_size - clasp_front_x_size;
clasp_front_y_position = 0;
clasp_front_z_position = front_z_position + front_z_size + magnet_z_size;

magnet_margin = clasp_front_x_size / 4;
magnet_x_size = clasp_front_x_size - 2 * magnet_margin;
magnet_y_size = outer_y_size - 2 * magnet_margin;
magnet_x_position = clasp_front_x_position + magnet_margin;
magnet_y_position = magnet_margin;
magnet_z_position = clasp_front_z_position - magnet_z_size;

hinge_y_size = outer_y_size / 10; // Completely arbitrary
hinge_radius = metal_thickness / 2; // To fit with the clasp
hinge_y_positions = [2 * hinge_y_size, outer_y_size - hinge_y_size];
front_hinge_x_position = overhang_x_position + overhang_x_size;
front_hinge_y_position = 0;
front_hinge_z_position = overhang_z_position + overhang_z_size + hinge_radius;
clasp_hinge_x_position = metal_thickness + back_x_size + hinge_radius;
clasp_hinge_y_position = 0;
clasp_hinge_z_position = metal_thickness - hinge_radius;

filing_hole_z_size = spine_z_size;
filing_holes_x_position = metal_thickness + overhang_x_size / 2;
filing_holes_y_position = outer_y_size / 2 - filing_hole_y_center;
filing_holes_z_position = 0;

// CALCULATIONS END

// MODULES
module filing_hole() {
	cylinder(h = filing_hole_z_size, r = filing_hole_radius, $fn=facets);
}

module filing_holes() {
	translate([filing_holes_x_position, filing_holes_y_position, filing_holes_z_position]) {
		for (filing_hole_y_position = filing_hole_y_positions) {
			translate([0, filing_hole_y_position, 0]) {
				filing_hole();
			}
		}
	}
}

module text_block() {
	difference() {
		translate([text_block_x_position, text_block_y_position, text_block_z_position]) {
			cube(size = [text_block_x_size, text_block_y_size, text_block_z_size]);
		}
		filing_holes();
	}
}

module hinge() {
	rotate([90, 0, 0]) {
		cylinder(h = hinge_y_size, r = hinge_radius, $fn = facets);
	}
}
module hinges() {
	for (hinge_y_position = hinge_y_positions) {
		translate([0, hinge_y_position, 0]) {
			hinge();
		}
	}
}

module back() {
	translate([back_x_position, back_y_position, back_z_position]) {
		cube(size = [back_x_size, back_y_size, back_z_size]);
	}
}

module spine() {
	cube(size = [spine_x_size, spine_y_size, spine_z_size]);
}

module overhang() {
	translate([overhang_x_position, overhang_y_position, overhang_z_position]) {
		cube(size = [overhang_x_size, overhang_y_size, overhang_z_size]);
	}
}

module back_spine_overhang() {
	difference() {
		union() {
			back();
			spine();
			overhang();
		}
		filing_holes();
	}
}

module front_hinges() {
	translate([front_hinge_x_position, front_hinge_y_position, front_hinge_z_position]) {
		hinges();
	}
}

module front() {
	translate([front_x_position, front_y_position, front_z_position]) {
		cube(size = [front_x_size, front_y_size, front_z_size]);
	}
}

module clasp_hinges() {
	translate([clasp_hinge_x_position, clasp_hinge_y_position, clasp_hinge_z_position]) {
		hinges();
	}
}

module clasp_fore() {
	translate([clasp_fore_x_position, clasp_fore_y_position, clasp_fore_z_position]) {
		cube(size = [clasp_fore_x_size, clasp_fore_y_size, clasp_fore_z_size]);
	}
}

module clasp_front() {
	translate([clasp_front_x_position, clasp_front_y_position, clasp_front_z_position]) {
		cube(size = [clasp_front_x_size, clasp_front_y_size, clasp_front_z_size]);
	}
}

module clasp_magnet() {
	translate([magnet_x_position, magnet_y_position, magnet_z_position]) {
		cube(size = [magnet_x_size, magnet_y_size, magnet_z_size]);
	}
}

module clasp() {
	union() {
		clasp_fore();
		clasp_front();
	}
}

module book(explosion) {
	translate([0, 0, 0 * explosion]) {
		# text_block();
	}
	translate([0, 0, 1 * explosion]) {
		back_spine_overhang();
	}
	translate([0, 0, 2 * explosion]) {
		# front_hinges();
	}
	translate([0, 0, 3 * explosion]) {
		front();
	}
	translate([0, 0, 4 * explosion]) {
		# clasp_hinges();
	}
	translate([0, 0, 5 * explosion]) {
		clasp_magnet();
	}
	translate([0, 0, 6 * explosion]) {
		clasp();
	}
}

// MODULE END

// DOCUMENTATION

echo (str(
	"Book: ",
	"width=", clasp_fore_x_position + clasp_fore_x_size, ", ",
	"height=", outer_y_size, ", ",
	"thickness=", clasp_front_z_position + clasp_front_z_size,
	" (not counting hinges)"));

echo (str(
	"Metal: ",
	"length=", back_x_size + spine_z_size + overhang_x_size + clasp_fore_z_size + clasp_front_x_size, " (total for all parts), ",
	"width=", outer_y_size, " (i.e., book height), ",
	"thickness=", metal_thickness));

echo (str(
	"Filing holes: ",
	"Y positions=", filing_hole_y_positions, ", ",
	"Y center=", filing_hole_y_center, ", ",
	"radius=", filing_hole_radius, ", ",
	"from back edge to bottom holes=", back_x_position + back_x_size - spine_x_size - filing_hole_spine_margin, ", ",
	"from spine to top holes=", filing_hole_spine_margin, ", ",
	"from overhang edge to top holes=", filing_hole_paper_margin));

echo (str(
	"Paper / text block: ",
	"width=", text_block_x_size, ", ",
	"height=", text_block_y_size, ", ",
	"sheets=", paper_sheet_count, ", ",
	"sheet thickness=", paper_z_size, ", ",
	"text block thickness=", text_block_z_size));

echo (str(
	"Back, spine, overhang: ",
	"length=", back_x_size + spine_z_size + overhang_x_size), " (before bending)");

echo (str(
	"Front plate: ",
	"length=", front_x_size));

echo (str(
	"Clasp: ",
	"length=", clasp_fore_z_size + clasp_front_x_size, " (before bending)"));

echo (str(
	"Magnet: ",
	"width=", magnet_x_size, ", ",
	"height=", magnet_y_size, ", ",
	"thickness=", magnet_z_size));

for (filing_hole_y_position = filing_hole_y_positions) {
	echo (str(
		"Filing hole center distance from bottom: ",
		filing_holes_y_position + filing_hole_y_position + filing_hole_radius));
}

echo (str(
	"Other configuration: ",
	"facets=", facets, ", ",
	"explode=", explode
	));

// DOCUMENTATION END

if (explode)
	// Must be bigger than the biggest distance in imploded modus to be absolutely sure that it won't still clash
	assign(explosion=1.1 * (spine_z_size + 2 * hinge_radius)) book(explosion);
else
	book();
