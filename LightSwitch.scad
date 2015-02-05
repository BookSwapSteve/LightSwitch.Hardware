use <MCAD/boxes.scad>

// Overall size
height = 180;
width = 100;

// Same thing?
outerWallWidth = 5;
bezelSize = 5;

// How thick the front panel should be (where the solar panel isn't mounted)
frontPanelThickness = 3;
// The height of the front (top) panel
frontPanelHeight = 15;

// Solar Panel actual outside width is 137x81
solarPanelHeight = 137;
solarPanelWidth = 83;
solarPanelDepth = 3;

// Solar panel inner exposed user contact: 125x70
solarPanelDisplayHeight = 125;
solarPanelDisplayWidth = 70;

// Switch size (physical size of the light switch being covered)
switchHeight = 88;
switchWidth = 88;
switchDepth = 22;
// How much the switch body should overlap onto the base
switchOverlap = 5;

middleDepth = 10;

module GenericBase(xDistance, yDistance, zHeight) {
	//roundedBox([xDistance, yDistance, zHeight], 2, true);

	// Create a rectangluar base to work from that
	// is xDistance by yDistance and zHeight height.

	// This is effectivly a cube with rounded corners

	// extend the base out by 3.5 from holes by using minkowski
	// which gives rounded corners to the board in the process
	// matching the Gadgeteer design
	
	$fn=50;
	radius = bezelSize;

	translate([radius,radius,0]) {
		minkowski()
		{
			cube([xDistance-(radius*2), yDistance-(radius*2), zHeight]);
			cylinder(r=radius,h=zHeight);
		}
	}
}

module SeedStalkerCutout() {
	// Position so that it is in the middle of the width
	// even though that only leaves about 1mm bexel at that point.
	// and the full bexel height from the bottom.
	translate([(width - 93) /2,(height - bezelSize) -65,0])
		cube([93,65,30]);

	// TODO: Add mounting pins and spacer
	// Add battery mount.
}

// Build up an inner wall on the base to mate with the top/middle.
module InnerWall() {
	innerWallOutsideWidth = width- (2*bezelSize);
	innerWallOutsideHeight = height-(2*bezelSize);
	wallThickness=1;

	translate([bezelSize, bezelSize, 0])  {
		difference() {
			union() 
			{
				// An inner area. remove 0.1mm to allow for a smooth fit
				GenericBase(innerWallOutsideWidth-0.1, innerWallOutsideHeight-0.1, 3);
			}		
			union() 
			{
				// Cut out the bulk of the inside of the box.
				translate([wallThickness, wallThickness, 1])  {
					GenericBase(innerWallOutsideWidth- (wallThickness*2), 
									innerWallOutsideHeight- (wallThickness*2), 
									15);
				}
			}
		}
	}
}

module SwitchCutout() {

	// Cutout smaller than the actual switch to allow for the overlap all around
	cutoutWidth = switchWidth - (switchOverlap*2);
	cutoutHeight = switchHeight - (switchOverlap*2);	

	// Padding either side of the cutout.
	paddingWidth = (width - cutoutWidth) / 2;
	paddingHeight = 15; // Fixed padding from top.

	// Switch cutout.
	// Cut out a area less wide than the switch so it sits on it 
	// keeping the box against the wall
	// -1 z to ensure it goes all the way through
	translate([paddingWidth, paddingHeight, -1]) {
				cube([cutoutWidth, cutoutHeight, 4]);
	}

	// Switch body
	// Create a block to show how the switch body sits
	// in the base.
	switchOuterPaddingWidth = (width - switchWidth) /2;
	switchOuterPaddingHeight = paddingHeight - switchOverlap;

	translate([switchOuterPaddingWidth , switchOuterPaddingHeight,1]) {
		color( [1, 0, 0, 0.90] ) {
				cube([switchWidth, switchHeight, switchDepth]);
		}
	}
}

module LightSwitchBase() {
	innerCutoutOffset = bezelSize + 2; // Wall thickness
	baseThickness = 1;

	difference() {
		union() 
		{
			// Outer base
			GenericBase(width, height, baseThickness);
		
			InnerWall();
		}		
		union() 
		{
			// Cut out the bulk of the inside of the box.
			// Outerwall padding = 5
			// Move in 5, down 5 and up 2 to provide an 
			// outline of 5x5 with 2 base.
			//translate([innerCutoutOffset, innerCutoutOffset, baseThickness])
			//	#GenericBase(width - (innerCutoutOffset * 2), 
			//						height - (innerCutoutOffset *2), 
			//						15);

			// Not used as base is 1mm thick only anyway
			// Seating area for switch to sit on
			// Create a bezeled area for the lightsitch to sit in
			// pad by 1mm as the switch is padded by 2mm.
			//translate([outerWallWidth,outerWallWidth,1])
			//	cube([switchWidth+2, switchRealHeight,1]);

			#SwitchCutout();

			//translate([0,0,2])
				//SeedStalkerCutout();
		}
	}
}

// Maybe not used...
module lightSwitchMiddle() {
	difference() {
		union() 
		{
			//cube([width,height,middleDepth]);
			GenericBase(width, height, middleDepth);
		}	
		union() 
		{
			// Cut out the bulk of the inside of the box.
			// Outerwall padding = 5
			// Move in 5, down 5 and up 1 to provide an 
			// outline of 5x5 with 1 base.
			translate([outerWallWidth, outerWallWidth,0])
				#GenericBase(width-(outerWallWidth*2), 
								height-(outerWallWidth*2), 
								middleDepth+1);
			
		}
	}
}

// Hollow out the bulk of the body.
module HollowOutBody() {

	// Move in by [bezelSize]
	translate([bezelSize,bezelSize, frontPanelThickness]) {
		GenericBase(width-(bezelSize*2), height-(bezelSize*2), frontPanelHeight +1);
	}
}

module SolarPanelCutout() {
	// Cutout for the solar panel
	// Move in, down
	// to make a window in the panel for the solar
	// panel.

	// Compute how much padding either side of the panel there
	// needs to be for it to be centered.
	paddingWidth = (width - solarPanelDisplayWidth) / 2;
	paddingTop = 10;

	// center the panel in the x.
	// leave small space at the top to make it nice with a fat bottom.
	translate([paddingWidth, paddingTop, 0]) {
		GenericBase(solarPanelDisplayWidth, solarPanelDisplayHeight, 4);
	}

	// Move up 1mm to provide a bezel for the panel
	// leave about 2mm bezel at the top as well
	translate([(width - solarPanelWidth)/2, paddingTop-2 ,1])
		cube([solarPanelWidth, solarPanelHeight,10]);

	// Replaced by HollowOutBody
	// Move up mm and cut out the rest of the area 
	// so that the solar panel has a small frame to sit in
	//translate([5,5,solarPanelDepth + 1])
	//	cube([width-10, height-10,10]);
}

module ElectronicsCutout() {
}

module LightswitchTop() {

	difference() {
		union() 
		{
			GenericBase(width, height, frontPanelHeight);
		}	

		union() 
		{
			#HollowOutBody();
			#SolarPanelCutout();
			#ElectronicsCutout();

			//translate([0,0,2])
			//	SeedStalkerCutout();
		}

	}
}

module GiveItEars() {
earSize = 20;

	translate([0,0,0]) 
		cylinder(r=earSize,h=2);

	translate([width,0,0])
		cylinder(r=earSize,h=2);

	translate([width,height,0])
		cylinder(r=earSize,h=2);

	translate([0,height,0])
		cylinder(r=earSize,h=2);
}


//LightSwitchBase();

LightswitchTop();

GiveItEars();

//translate([-(width+10),-(height +10),0])
//	lightSwitchMiddle();

rotate([0, 180,0]) {
	// Z-32 to get them on top of each other.
	translate([-width,0,-34]) {
//		LightswitchTop();
	}
}