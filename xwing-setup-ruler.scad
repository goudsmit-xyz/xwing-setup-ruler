length = 250;
width = 15;
thickness = 3;

notchDepth = 0.3;
notchWidth = 1;

railWidth = width/2;
slotMargin = 0.6;
slotLength = 50;
labelMargin = 3;

magnetThickness = 0.5;
magnetRadius = 10/2;

range = 100;

rotate([0,0,45])    // to accomodate easy STL import with square buildplates 
union() {           // combine the rulers moved sideways
  translate([-width,0,0]) topRuler();
  translate([width,0,0]) bottomRuler();
}

module rail() {
    difference() {
        translate([0, slotLength,0])
        rotate([90,0,0])
        linear_extrude(slotLength)
        polygon([
            [-(railWidth/2 + 1), thickness/2],
            [ (railWidth/2 + 1), thickness/2],
            [ (railWidth/2), 0],
            [-(railWidth/2), 0]
        ]);
        
        textDepth = 0.5;
        translate([0,slotLength/2,thickness/2 - textDepth])
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
    translate([0, slotLength,0])
    rotate([90,0,0])
    linear_extrude(slotLength)
    polygon([
        [-(railWidth/2 + 1 + slotMargin/2), thickness/2],
        [ (railWidth/2 + 1 + slotMargin/2), thickness/2],
        [ (railWidth/2 + slotMargin/2), 0],
        [-(railWidth/2 + slotMargin/2), 0]
    ]);
}

// TODO:
// - change shape of extension rail so it stays put
// - maybe increase thickness?

module rangeLabel(label, atRange) {
    translate([width/2,(atRange*range)+labelMargin,thickness-notchDepth])
        linear_extrude(notchDepth)
        text(text = label, halign = "center"); 
}

module notch(atRange) {
    translate([0,(atRange*range) - notchWidth/2,thickness-notchDepth])
        cube([width,notchWidth,notchDepth]);
}

module bottomCrossSlot(y) {
    translate([0,y-slotMargin/2,0])
        union() {
            cube([width,width+slotMargin,thickness/2]);
            translate([width/2, width/2,thickness/2])
            cylinder(magnetThickness, magnetRadius, magnetRadius, center = true);
        }
}

module topRuler() {
    // flip upside down and shift back so no/less supports needed
    translate([0,0,thickness])
    rotate([0,180,0])
    translate([-width/2,-length/2]) // center on middle of ruler    
    difference() {
        cube([15,length,thickness]);  // full range 3 ruler
        
        // slot for extending ruler
        translate([width/2,length-slotLength,0])
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

// lower ruler (4.5 extension)
module bottomRuler() { 
    translate([-width/2,-length/2,0]) // center on middle line 
    union() {
    
        // strip for inserting when extending
        translate([width/2,0,0])
            rail();
 
        // start the actual ruler part at the end of the rail
        translate([0,slotLength,0])
        difference() {
            // solid range 2 part for extending
            cube([width,length-slotLength,thickness]);  
            
            // slot for crossing rulers
            // TODO: modularize?
            // TODO: add optional opening for a magnet?
            translate([0,(range*2)-slotLength-width-slotMargin/2, thickness/2])
                union() {
                    cube([width,width+slotMargin, thickness/2]);
                    translate([width/2, width/2,-magnetThickness/2])
                    cylinder(magnetThickness, magnetRadius, magnetRadius, center = true);
                }
            
            // range 3
            notch(0.5);
            rangeLabel("3", 0.5);
           
            // range 4 (no notch; aligns with the crossing ruler slot)
            rangeLabel("4", 1.5);
    
        }
    }
}



