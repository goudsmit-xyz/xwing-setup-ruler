length = 250;
width = 15;
thickness = 3;

notchDepth = 0.3;
notchWidth = 1;

railWidth = width/2;
railLength = 50;

slotMargin = 0.6;

labelMargin = 3;

magnetThickness = 0.4;
magnetRadius = 10/2;

recessHeight = magnetThickness + 0.15; // room for glue
recessRadius = magnetRadius + 0.05;

range = 100; // helper constant for calculations involving range

rotate([0,0,45])    // to accomodate easy STL import with square buildplates 

union() {           // combine the rulers moved sideways
    
    translate([-width,0,0])  // move sideways (to the left)
        // flip upside down and shift back so no/less supports needed
        translate([0,0,thickness])
        rotate([0,180,0])
            topRuler();
    
    translate([width,0,0]) // move sideways (to the right)
        bottomRuler();
}

// The rail of the bottom ruler that slides into the top ruler
module rail() {
    difference() {
        translate([0, railLength,0])
        rotate([90,0,0])
        linear_extrude(railLength)
        polygon([
            [-(railWidth/2 + 1), thickness/2],
            [ (railWidth/2 + 1), thickness/2],
            [ (railWidth/2), 0],
            [-(railWidth/2), 0]
        ]);
        
        textDepth = 0.5;
        translate([0,railLength/2,thickness/2 - textDepth])
        linear_extrude(textDepth)
        rotate([0,0,270])
        text("goudsmit.xyz", size = 5, valign = "center", halign = "center", font = "Liberation Sans:style=Bold");
    }
}

// I couldn't find a 3D extrusion method, so using a second module
// I guess I could extrude a reg triangle instead and chop if off at thickness/2
// that way it could be scaled pre-chop and the side angle would be the same
// the base of the triangle would be the widest width
module railSlot() {
    translate([0, railLength,0])
    rotate([90,0,0])
    linear_extrude(railLength)
        polygon([
            [-(railWidth/2 + 1 + slotMargin/2), thickness/2],
            [ (railWidth/2 + 1 + slotMargin/2), thickness/2],
            [ (railWidth/2 + slotMargin/2), 0],
            [-(railWidth/2 + slotMargin/2), 0]
        ]);
}

// Textual label indicating range
module rangeLabel(label, atRange) {
    translate([width/2,(atRange*range)+labelMargin,thickness-notchDepth])
        linear_extrude(notchDepth)
        text(text = label, halign = "center"); 
}

// Notch for measuring of actual range
module notch(atRange) {
    translate([0,(atRange*range) - notchWidth/2,thickness-notchDepth])
        cube([width,notchWidth,notchDepth]);
}

// Slot at the bottom of a ruler for cross-connecting the other
module bottomCrossSlot(y) {
    translate([0,y-slotMargin/2,0])
        union() {
            cube([width,width+slotMargin,thickness/2]);
            translate([width/2, width/2,thickness/2])
                cylinder(recessHeight*2, recessRadius, recessRadius, center = true); // make pretty
        }
}

// The entire top ruler (to range 2.5)
module topRuler() {

    translate([-width/2,-length/2]) // center on middle of ruler    
    difference() {
        cube([15,length,thickness]);  // full range 3 ruler
        
        // slot for extending ruler
        translate([width/2,length-railLength,0])
            railSlot();
        
        // slot for crossing rulers outside range 1 (ship placements)
        bottomCrossSlot(range);
        
        // slot for crossing rulers inside range 2 (obstacles)
        bottomCrossSlot(range*2 - width);  
        
        // range 1
        notch(1);
        rangeLabel("1", 1);
        
        // range 2
        notch(2);
        rangeLabel("2", 2);
       
    }

}

// The entire lower ruler (4.5 extension)
module bottomRuler() { 
    translate([-width/2,-length/2,0]) // center on middle line 
    union() {
    
        // strip for inserting when extending
        translate([width/2,0,0])
            rail();
 
        // start the actual ruler part at the end of the rail
        translate([0,railLength,0])
        difference() {
            // solid range 2 part for extending
            cube([width,length-railLength,thickness]);  
            
            // slot for crossing rulers
            // TODO: modularize?
            translate([0,(range*2)-railLength-width-slotMargin/2, thickness/2])
                union() {
                    cube([width,width+slotMargin, thickness/2]);
                    translate([width/2, width/2,0])
                        cylinder(recessHeight*2, recessRadius, recessRadius, center = true);
                }
            
            // range 3 (this ruler effectively starts at 2.5)
            notch(0.5);
            rangeLabel("3", 0.5);
           
            // range 4 (no notch; aligns with the crossing ruler slot)
            rangeLabel("4", 1.5);
    
        }
    }
}



