/*
--------------------------------------------------------------------------------
The Nick Shabazz Parametric Knife Display Stand (dmccaffrey fork)
Originally created by Nick Shabazz - 2024
--------------------------------------------------------------------------------
*/

/*
Introduction
--------------------------------------------------------------------------------
This file is written in the OpenSCAD language and should be opened in OpenSCAD
for editing or to render a result.
- https://openscad.org/
- https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_Language

To get started simply modify the holder and base configuration to your liking.
Holder properties are specified as vectors so that any number of objects can
be supported in any ordering.


Note: All distance values are specified in millimeters.
--------------------------------------------------------------------------------
*/


/*
Holder Configuration
--------------------------------------------------------------------------------
- Objects can currently be of type "pen", "knife" (blade and hanlde), or "sword" (blade and blade)
- Show side may be "right" or left"
- Heigh offset specifies the staggering in height between holders
- Depth offset specifies the stagging in depth (front to back) between holders
- Width species with width (righ to left) of each holder
- Held dimensinons specify the left and right handle/pen or blade cutout diameter
- Drop height specifies the difference between the 'handle' side and non-hanlde side
*/
objects             = ["pen", "knife", "sword"];
showSide            = ["na", "right", "left"];
holderHeightOffset  = [0, 15, 15];
holderDepthOffset   = [5, 5, 0];
holderDepth         = [30, 30, 30];
holderWidth         = [10, 20, 20];
heldDimensions      = [ [15, 10], [3, 20], [6, 6] ];
dropHeight          = [0, 0, 10];
//------------------------------------------------------------------------------

/*
Base Configuration
--------------------------------------------------------------------------------
*/
splitBase           = false;    // Set to true to print separate holder pieces
openBase            = true;     // Set to true to print the base with a cutout between the holders
baseTaperPercent    = 20;       // The percentage of taper (bottom to top) for the base
basePerimiter       = 25;       // The perimeter radius of the base
baseHeight          = 8;        // Hight of the base
baseWidth           = 150;      // Width of the base
//------------------------------------------------------------------------------


/*
Derived Configuration
--------------------------------------------------------------------------------
*/
baseLength = Sum(holderDepthOffset) + Sum(holderDepth);
echo("Base length: ", baseLength);

supportPosOffset = 0.10;
leftHolderPos = supportPosOffset * baseWidth;
rightHolderPos = (1 - supportPosOffset) * baseWidth;
echo("Handle positions: left=", leftHolderPos, "right=", rightHolderPos);
//------------------------------------------------------------------------------

/*
Rendering
--------------------------------------------------------------------------------
*/
union(){
    for (i = [0:len(objects)-1]){
        holderDepths = (i > 0) ? Sum(holderDepth, i-1) : 0;
        holderOffsets = (i > 0) ? Sum(holderDepthOffset, i-1) : 0;
        offset = holderDepths + holderOffsets + holderDepth[0]/2;
        echo("Offset=", offset);
        
        holderHeight = Sum(holderHeightOffset, i) + baseHeight;
        dropSideHeight = holderHeight - dropHeight[i];
        echo("Generating holder: num=", i, "offset=", offset, "baseHeight=", baseHeight, "dropSideHeight=", dropSideHeight);
        
        showSidePos = (showSide[i] == "right") ? rightHolderPos : leftHolderPos;
        otherSidePos = (showSide[i] == "right") ? leftHolderPos : rightHolderPos;
        
        if(objects[i] == "sword") {
            translate([offset, otherSidePos, baseHeight])
                rotate([0, 0, 0])
                bladeholder(holderDepth[i], holderWidth[i], holderHeight, heldDimensions[i][0]*3, heldDimensions[i][0], heldDimensions[i][1]);
            
        } else {
            translate([offset, otherSidePos, baseHeight])
                rotate([0, 0, 90])
                handleholder(holderDepth[i], holderWidth[i], holderHeight, heldDimensions[i][1]);
        }
        
        if(objects[i] == "knife" || objects[i] == "sword") {
            translate([offset, showSidePos, baseHeight])
                rotate([0, 0, 0])
                bladeholder(holderDepth[i], holderWidth[i], dropSideHeight, heldDimensions[i][0]*3, heldDimensions[i][0], heldDimensions[i][1]);
            
        } else {
            translate([offset, showSidePos, baseHeight])
                rotate([0, 0, 90])
                handleholder(holderDepth[i], holderWidth[i], dropSideHeight, heldDimensions[i][0]);
        }
    };
    basePerimWithTaper = basePerimiter - basePerimiter * (baseTaperPercent/100);
    if(splitBase) {
        splitBaseShape(baseLength, baseWidth, baseHeight, basePerimiter, basePerimWithTaper);
        
    } else {
        unifiedBaseShape(baseLength, baseWidth, baseHeight, basePerimiter, basePerimWithTaper);
    }
};
//------------------------------------------------------------------------------

//Sum the elements of a vector between zero and the end.
function SubSum(vec, i, end)=vec[i]+((i == end) ? 0 : SubSum(vec, i+1, end));
function Sum(vec, end=-1) = (end == -1) ? SubSum(vec, 0, len(vec)-1) : SubSum(vec, 0, end);

// This creates the base with rounded edges
module unifiedBaseShape(length, width, thiccness, bottomRadius, topRaduis) {
    difference() {
    hull(){
        // Creates a hull around four tapered cylinders
        translate([0, 0, 0]){
            cylinder(thiccness, bottomRadius, topRaduis);
        };
        translate([length, width, 0]){
            cylinder(thiccness, bottomRadius, topRaduis);
        };
        translate([0, width, 0]){
            cylinder(thiccness, bottomRadius, topRaduis);
        };
        translate([length, 0, 0]){
            cylinder(thiccness, bottomRadius, topRaduis);
        };
    };
    if(openBase) {
        translate([0, baseWidth * 0.3, -10]) {
            cube([length, baseWidth * 0.4, 100]);
        };
     }
 };};
 
// This creates a separate base with rounded edges for the blade and hanlde sides
module splitBaseShape(length, width, thiccness, bottomRadius, topRaduis) {
    // Creates a hull around  tapered cylinders for the blade holders
    hull(){
        translate([0, leftHolderPos, 0]){
            cylinder(thiccness, bottomRadius, topRaduis);
        };
        translate([length, leftHolderPos, 0]){
            cylinder(thiccness, bottomRadius, topRaduis);
        };
        translate([0, leftHolderPos, 0]){
            cylinder(thiccness, bottomRadius, topRaduis);
        };
        translate([length, leftHolderPos, 0]){
            cylinder(thiccness, bottomRadius, topRaduis);
        };
    };
    // Creates a hull around  tapered cylinders for the hanlde holders
    hull(){
        translate([length,rightHolderPos, 0]){
            cylinder(thiccness,bottomRadius, topRaduis);
        };
        translate([0,rightHolderPos, 0]){
            cylinder(thiccness,bottomRadius, topRaduis);
        };
        translate([length, rightHolderPos, 0]){
            cylinder(thiccness, bottomRadius, topRaduis);
        };
        translate([0, rightHolderPos, 0]){
            cylinder(thiccness, bottomRadius, topRaduis);
        };
    }
 };
 
// This creates a holder with a round cutout for handles           
module handleholder(supportlength, supportwidth, height, handlediameter) {
    toplength=(handlediameter*1.1);
    taperpercent=toplength/supportlength;
    difference() {
        linear_extrude(height = height, twist = 0, scale = taperpercent, slices = 200)
            square([supportwidth,supportlength], center=true);
        
        translate([0,0,height+0.1*handlediameter])
            rotate([0,90,0])
            cylinder(h=100,d=handlediameter, center=true);
    }
}

// This creates a holder with a notched cutout for blades
module bladeholder(supportlength, supportwidth, height, bladenotchdepth,bladenotchwidth, handlediameter) {
    toplength=(bladenotchwidth*2);
    taperpercent=toplength/supportlength;

    difference() {
        linear_extrude(height = height, twist = 0, scale = taperpercent, slices = 200)
            square([supportlength, supportwidth], center=true);
        
        translate([0,0,height+0.1*bladenotchdepth])
            rotate([0,180,0])
            linear_extrude(height = bladenotchdepth, twist = 0, scale = 0.5, slices = 200)
            square([bladenotchwidth,1000], center=true);
    }
}


