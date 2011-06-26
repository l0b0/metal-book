// Configuration (all sizes in millimeters)
metal_thickness = 2;
magnet_thickness = 1;

// A5 paper default
paper_width = 148;
paper_height = 210;
paper_sheet_thickness = 0.1;
paper_sheets = ceil(365 / 2); // One page per day default

paper_hole_positions = [0, 80];
paper_hole_center = 40; // max(paper_hole_positions) / 2
paper_hole_radius = 3;

facets = 40; // Number of facets in circular objects
explode = false; // Set to true to see parts separately
// Configuration end

// Calculate Cn size based on arithmetic progression
// https://secure.wikimedia.org/wikipedia/en/wiki/ISO_216
outer_width = paper_width * pow(2, 1.0 / 8);
outer_height = paper_height * pow(2, 1.0 / 8);

paper_thickness = paper_sheets * paper_sheet_thickness;

back_thickness = 2 * metal_thickness + paper_thickness;

margin_width = (outer_width - paper_width) / 2;
margin_height = (outer_height - paper_height) / 2;

overhang_width = margin_width * 2;

// There's no need for left margin on the back and front
back_width = outer_width - margin_width / 2;

// The front is to the right of the overhang from the back
front_width = back_width - overhang_width;

magnet_margin = overhang_width / 4;
magnet_width = overhang_width - 2 * magnet_margin;
magnet_height = outer_height - 2 * magnet_margin;

hinge_height = outer_height / 10;
hinge_radius = metal_thickness / 2;

// Some useful information for constructing by hand
echo (str(
	"Book outer dimensions: ",
	"width=", outer_width, ", ",
	"height=", outer_height, ", ",
	"thickness=", back_thickness + 2*magnet_thickness,
	" (not counting hinges)"));

echo (str(
	"Center length of the back plate sections: ",
	back_width + metal_thickness / 2, ", ",
	back_thickness - metal_thickness, ", ",
	overhang_width + metal_thickness / 2));
echo (str(
	"Total length of the back plate sections: ",
	back_width + metal_thickness / 2 +
	back_thickness - metal_thickness +
	overhang_width + metal_thickness / 2));

echo (str(
	"Width of the front plate: ",
	front_width));

echo (str(
	"Center length of the clasp sections: ",
	back_thickness + magnet_thickness - metal_thickness / 2, ", ",
	overhang_width - metal_thickness / 2));

echo (str(
	"Total length of the clasp sections: ",
	back_thickness + magnet_thickness - metal_thickness / 2 +
	overhang_width - metal_thickness / 2));

module paper() {
	difference() {
		translate([metal_thickness, margin_height, metal_thickness]) {
			cube(size = [paper_width, paper_height, paper_thickness]);
		}
		binding_holes();
	}
}

module back_cover() {
	translate([metal_thickness, 0, 0]) {
		cube(size = [back_width, outer_height, metal_thickness]);
	}
}

module back_side() {
	cube(size = [metal_thickness, outer_height, back_thickness]);
}

module back_overhang() {
	translate([metal_thickness, 0, paper_thickness + metal_thickness]) {
		cube(size = [overhang_width, outer_height, metal_thickness]);
	}
}

module binding_hole() {
	cylinder(h = back_thickness, r=paper_hole_radius, $fn=facets);
}

module binding_holes() {
	translate([metal_thickness + overhang_width / 2, outer_height / 2 - paper_hole_center, 0]) {
		for (position = paper_hole_positions) {
			translate([0, position, 0]) {
				binding_hole();
			}
		}
	}
}

module back() {
	difference() {
		union() {
			back_cover();
			back_side();
			back_overhang();
		}
		binding_holes();
	}
}

module hinge() {
	rotate([90, 0, 0]) {
		cylinder(h = hinge_height, r=hinge_radius, $fn=facets);
	}
}
module top_hinge() {
	translate([0, 2*hinge_height, 0]) {
		hinge();
	}
}
module bottom_hinge() {
	translate([0, outer_height - hinge_height, 0]) {
		hinge();
	}
}

module hinges() {
	top_hinge();
	bottom_hinge();
}

module front_hinges() {
	translate([metal_thickness + overhang_width, 0, paper_thickness + 2 * metal_thickness + hinge_radius]) {
		hinges();
	}
}

module front() {
	translate([metal_thickness + overhang_width, 0, paper_thickness + metal_thickness]) {
		cube(size = [front_width, outer_height, metal_thickness]);
	}
}

module clasp_hinges() {
	translate([metal_thickness + back_width + hinge_radius, 0, metal_thickness - hinge_radius]) {
		hinges();
	}
}

module clasp_side() {
	translate([metal_thickness + back_width, 0, metal_thickness]) {
		cube(size = [metal_thickness, outer_height, back_thickness + magnet_thickness]);
	}
}

module clasp_overhang() {
	translate([metal_thickness + back_width - overhang_width, 0, paper_thickness + 2 * metal_thickness + magnet_thickness]) {
		cube(size = [overhang_width, outer_height, metal_thickness]);
	}
}

module clasp_magnet() {
	translate([metal_thickness + back_width - overhang_width + magnet_margin, magnet_margin, paper_thickness + 2 * metal_thickness]) {
		cube(size = [magnet_width, magnet_height, magnet_thickness]);
	}
}

module clasp() {
	union() {
		clasp_side();
		clasp_overhang();
		clasp_magnet();
	}
}

module book(explosion) {
	translate([0, 0, 0 * explosion]) {
		# paper();
	}
	translate([0, 0, 1 * explosion]) {
		back();
	}
	translate([0, 0, 2 * explosion]) {
		front_hinges();
	}
	translate([0, 0, 3 * explosion]) {
		front();
	}
	translate([0, 0, 4 * explosion]) {
		clasp_hinges();
	}
	translate([0, 0, 5 * explosion]) {
		clasp();
	}
}

if (explode)
	// Must be bigger than the biggest distance in imploded modus to be absolutely sure that it won't still clash
	assign(explosion=1.1 * (back_thickness + 2 * hinge_radius)) book(explosion);
else
	book();
