// =====================================================================
//  Retro industrial terminal enclosure
//  - Mini-ITX board (ASRock QC5000-ITX or any fanless mini-ITX)
//  - 15.6" laptop eDP panel (typical 359.5 x 223.8 x 3.2 mm)
//  - Home-made keyboard sits in a recessed well in the base
//  Every piece fits a 256 x 256 x 256 mm bed (Bambu Lab P2S).
//
//  Render one piece:  openscad -D 'part="base_FL"' -o base_FL.stl terminal.scad
//  Pieces: assembly | base_FL base_FR base_RL base_RR |
//          plate_FL plate_FR plate_RL plate_RR |
//          pod_BL pod_BR pod_TL pod_TR | hatch_L hatch_R | clamp_tab | trim_strip
//  (F/R = front/rear, L/R = left/right, B/T = bottom/top)
//
//  Joining: 2.0 mm holes on every seam take 1.75 mm filament offcuts as
//  alignment pins; glue the seams (CA or solvent), then the screwed-on
//  bottom plate and rear hatch tie everything together.
// =====================================================================

part = "assembly";
print_orient = true;   // rotate pieces into their suggested print orientation
show_ghosts  = true;   // panel/board dummies in the assembly view
solid_ghosts = false;  // draw dummies as solid colour (needed for --render PNGs)

$fn = 40;

// ---------- general ----------
t        = 4;      // wall thickness
pin_d    = 2.0;    // filament-pin hole
pin_len  = 16;
ins_d    = 4.2;    // M3 heat-set insert hole
ins_depth= 6;
screw_d  = 3.4;

// ---------- 15.6" panel (check against your panel's datasheet) ----------
panel_w = 359.5;  panel_h = 223.8;  panel_t = 3.2;
panel_clear = 1.0;
active_w = 344.2; active_h = 193.6;
active_bottom_margin = 23.7;   // panel bottom edge -> bottom of active area

// ---------- mini-ITX ----------
itx = 170;
board_x0 = 270;  board_y0 = 186;   // board front-left corner, I/O edge at the rear
standoff_h = 6;  pcb_t = 1.6;
// hole positions relative to board front-left corner (I/O edge = y 170)
itx_holes = [[6.35,4.90],[163.83,4.90],[6.35,159.84],[163.83,159.84]];
io_w = 158.75;  io_h = 44.45;
io_x_off  = 5.0;   // I/O aperture left edge measured from board left edge
io_z_drop = 2.3;   // aperture bottom sits this far below the PCB top

// ---------- base ----------
base_w = 460;  base_d = 360;
front_h = 45;  rear_h = 100;
ramp_y0 = 165; ramp_y1 = 195;
well_x0 = 40;  well_x1 = 420;  well_y0 = 12;  well_y1 = 152;
plate_t = 5;
skirt_o = 3.5;  skirt_h = 4;   // plinth lip round the base; keep skirt_h under the I/O cutout (5.3 mm)
split_x = 230;  split_y = 165;
badge_s = 18;  badge_clear = 0.5;  badge_depth = 1.2;   // square PC case badge (18 mm is the common sticker size)
ramp_angle = atan2(rear_h-front_h, ramp_y1-ramp_y0);
plate_split_x = 250;  plate_split_y = 180;
shell_bosses = [[8,8],[222,8],[238,8],[452,8],
                [8,158],[222,160],[238,160],[452,158],
                [8,200],[222,200],[238,200],[452,200],
                [8,352],[222,352],[238,352],[452,352]];

// ---------- display pod ----------
pod_w = base_w;  pod_tilt = 15;  pod_face_h = 280;  pod_top_d = 55;
pod_x0 = (base_w-pod_w)/2;  pod_y0 = 210;   // where the pod sits on the base top (sides flush)
bezel_bottom = 32;
pod_split_z = 135;
pod_top_y = pod_face_h * sin(pod_tilt);
pod_top_z = pod_face_h * cos(pod_tilt);
pod_bot_d = pod_top_y + pod_top_d;
cx = pod_w / 2;

pocket_w = panel_w + 2*panel_clear;
pocket_h = panel_h + 2*panel_clear;
pocket_u0 = bezel_bottom;
active_u0 = pocket_u0 + panel_clear + active_bottom_margin;
open_w = active_w + 2;  open_h = active_h + 2;
open_u0 = active_u0 - 1;
rib_d = 9;
clamp_boss_h = 10;
clamp_foot = clamp_boss_h - panel_t - 0.8;   // leaves room for a thin foam pad

clamp_pos = [[cx-192,80],[cx-192,200],[cx+192,80],[cx+192,200],
             [cx-100,265],[cx+100,265],[cx-100,22],[cx+100,22]];
hatch_pos = [[cx-190,60],[cx-190,210],[cx+190,60],[cx+190,210],
             [cx-100,11],[cx+100,11],[cx-100,257],[cx+100,257]];
mount_pos = [[cx-170,20],[cx+170,20],[cx-170,110],[cx+170,110]];   // pod coords
pod_mounts_global = [for (p = mount_pos) [p[0]+pod_x0, p[1]+pod_y0]];

// screen hood, built in the face frame F(): the roof sits square to the screen and
// the cheeks taper from nothing at hood_u0 to hood_d deep at the top of the face
hood_d = 50;  hood_u0 = 62;  hood_wall = 5;  hood_lip = 14;
function hood_depth(u) = hood_d * (u - hood_u0) / (pod_face_h - hood_u0);
// F() point (y, u) -> pod (y, z)
function F_yz(y, u) = [y*cos(pod_tilt) + u*sin(pod_tilt), -y*sin(pod_tilt) + u*cos(pod_tilt)];
// mid-thickness point of a cheek on the z seam (two fixed-point steps are plenty)
hood_pin_u1 = pod_split_z / cos(pod_tilt);
hood_pin_u  = (pod_split_z - hood_depth(hood_pin_u1)/2 * sin(pod_tilt)) / cos(pod_tilt);
hood_pin_yz = F_yz(-hood_depth(hood_pin_u)/2, hood_pin_u);
hood_top_z  = F_yz(-hood_d, pod_face_h)[1];      // front edge of the roof rises above the pod top

// lower bezel (u = height up the face)
// left side bezel: a column of 4 square buttons (12 mm caps) above a round speaker grille
col_x = 24;
btn_s = 12.4;
btn_u = [for (i = [0:3]) 200-i*20];
bolt_x = [16, pod_w-16];  bolt_u = 20;          // decorative bolt heads
spk_x = col_x;  spk_u = 100;                     // front speaker grille
// CRT-style surround: raised rounded ring around a rounded recess
ring_m = 18;  ring_h = 4;  recess_m = 8;
sill_x = 230;  sill_u0 = 10;  sill_hgt = 24;  sill_h = 4;   // raised sill under the screen
// dark trim strips (separate dark prints glued into face channels)
trim_x = [8.5, pod_w-12];  trim_w = 3.5;  trim_u0 = 120;  trim_len = 142;
side_spk = [77, 100];  side_spk_r = 18;          // side grilles, pod (y, z); ring stays below the z seam pins
// speaker retention: 4 bosses per grille; a clamp_tab's foot presses on the speaker rim
spk_rim = 3;                                     // speaker frame rim thickness + foam
spk_boss_h = clamp_foot + spk_rim;
spk_boss_r = 37;                                 // tab foot then lands at r 16..22 (40 mm speaker rim)
spk_boss_pos = [for (a = [45:90:315]) side_spk + spk_boss_r*[cos(a), sin(a)]];

hatch_w = 392;  hatch_h = 254;
hatch_x0 = cx - hatch_w/2;  hatch_z0 = 6.5;

// colours for the assembly preview
c_body = "#c9c4b5";  c_dark = "#3b3f44";  c_accent = "#d9822b";

// =====================================================================
//  helpers
// =====================================================================
module chamfer_rect(w, d, c)
    polygon([[c,0],[w-c,0],[w,c],[w,d-c],[w-c,d],[c,d],[0,d-c],[0,c]]);

// 2D (a,b) -> x = a, z = b, extruded along +y
module extrude_y(L) rotate([90,0,0]) mirror([0,0,1]) linear_extrude(L) children();
// 2D (a,b) -> y = a, z = b, extruded along +x
module extrude_x(L) rotate([90,0,90]) linear_extrude(L) children();
// pod front-face frame: x, y = depth into the pod, z = up the face
module F() rotate([-pod_tilt,0,0]) children();

module pin_along_x(xc, y, z) translate([xc-pin_len/2, y, z]) rotate([0,90,0]) cylinder(d=pin_d, h=pin_len, $fn=16);
module pin_along_y(x, yc, z) translate([x, yc-pin_len/2, z]) rotate([-90,0,0]) cylinder(d=pin_d, h=pin_len, $fn=16);
module rrect(w, h, r) offset(r=r) offset(delta=-r) square([w, h]);

// hex-packed round holes inside radius r
module grille_2d(r, d=3, pitch=4.5)
    for (j = [-ceil(r/pitch):ceil(r/pitch)], i = [-ceil(r/pitch):ceil(r/pitch)])
        let (p = [(i + (j%2)/2) * pitch, j * pitch * sin(60)])
            if (norm(p) <= r - d/2) translate(p) circle(d=d, $fn=12);

module pin_along_z(x, y, zc) translate([x, y, zc-pin_len/2]) cylinder(d=pin_d, h=pin_len, $fn=16);

// =====================================================================
//  BASE
// =====================================================================
module base_profile()
    polygon([[0,0],[0,front_h-8],[8,front_h],[ramp_y0,front_h],[ramp_y1,rear_h],
             [base_d-8,rear_h],[base_d,rear_h-8],[base_d,0]]);

module base_outer()
    intersection() {
        extrude_x(base_w) base_profile();
        translate([0,0,-1]) linear_extrude(rear_h+2) chamfer_rect(base_w, base_d, 10);
    }

module base_inner()
    intersection() {
        translate([t,0,0]) extrude_x(base_w-2*t) union() {
            offset(delta=-t) base_profile();
            translate([t,-1]) square([base_d-2*t, t+1]);
        }
        translate([0,0,-2]) linear_extrude(rear_h+4) offset(delta=-t) chamfer_rect(base_w, base_d, 10);
    }

module well_box(e=0)
    translate([well_x0-e, well_y0-e, -1]) cube([well_x1-well_x0+2*e, well_y1-well_y0+2*e, front_h+2]);

module base_body() {
    difference() {
        union() {
            difference() { base_outer(); base_inner(); }
            intersection() { base_outer(); well_box(t); }
            intersection() {
                base_outer();
                for (p = shell_bosses) translate([p[0],p[1],0]) cylinder(d=8, h=rear_h+1);
            }
        }
        // keyboard well (open to the bottom plate) + cable notch
        well_box(0);
        translate([300, well_y1-1, -1]) cube([40, t+2, 16]);

        // insert holes in shell bosses
        for (p = shell_bosses) translate([p[0],p[1],-1]) cylinder(d=ins_d, h=ins_depth+1);

        // rear I/O aperture, DC jack, rear vents
        translate([board_x0+io_x_off, base_d-t-1, standoff_h+pcb_t-io_z_drop]) cube([io_w, t+2, io_h]);
        translate([60, base_d+1, 30]) rotate([90,0,0]) cylinder(d=11, h=t+2);
        for (i = [0:3]) translate([board_x0, base_d-t-1, 62+i*8]) cube([170, t+2, 4]);

        // ramp vents
        for (x = [62:12:194]) translate([x, ramp_y0+7, front_h-5]) cube([4, 16, rear_h]);
        for (x = [262:12:394]) translate([x, ramp_y0+7, front_h-5]) cube([4, 16, rear_h]);
        // case-badge recess, centred on the ramp between the grilles (straddles the x seam)
        translate([base_w/2, (ramp_y0+ramp_y1)/2, (front_h+rear_h)/2]) rotate([ramp_angle,0,0])
            translate([-(badge_s+badge_clear)/2, -(badge_s+badge_clear)/2, -badge_depth])
                cube([badge_s+badge_clear, badge_s+badge_clear, badge_depth+5]);
        // small vent row in front of the pod
        for (x = [60:10:200]) translate([x, 197, rear_h-t-1]) cube([3, 10, t+2]);
        for (x = [260:10:400]) translate([x, 197, rear_h-t-1]) cube([3, 10, t+2]);

        // side pockets with slots
        translate([-1, 215, 25]) cube([2.5, 125, 60]);
        translate([base_w-1.5, 215, 25]) cube([2.5, 125, 60]);
        for (i = [0:4]) {
            translate([-1, 230, 33+i*10]) cube([t+2, 95, 4]);
            translate([base_w-t-1, 230, 33+i*10]) cube([t+2, 95, 4]);
        }

        // cable pass-through and pod mounting holes in the top
        translate([60, 250, rear_h-t-1]) cube([80, 30, t+2]);
        for (p = pod_mounts_global) translate([p[0],p[1],rear_h-t-1]) cylinder(d=screw_d, h=t+2);

        // power button (16 mm) + LED, left indicator LEDs
        translate([438.5, 80, front_h-t-1]) cylinder(d=16.2, h=t+2);
        translate([438.5, 110, front_h-t-1]) cylinder(d=5.2, h=t+2);
        for (y = [60, 80, 100]) translate([20, y, front_h-t-1]) cylinder(d=5.2, h=t+2);
        // deck details: label plate + small grille top-left, two 7 mm buttons top-right
        translate([6, 23, front_h-1]) linear_extrude(2) chamfer_rect(28, 14, 2);
        translate([20, 132, front_h-t-1]) linear_extrude(t+2) grille_2d(8);
        for (y = [125, 140]) translate([438.5, y, front_h-t-1]) cylinder(d=7.2, h=t+2);

        // decorative groove across the front
        translate([-1, -1, front_h/2]) cube([base_w+2, 2, 2]);

        // seam pins: x seam
        for (p = [[2,12],[2,28],[2,34],[10,15],[10,32],[154,15],[154,32],[160,43],
                  [358,15],[358,40],[358,70],[358,90],
                  [220,98],[260,98],[300,98],[340,98]])
            pin_along_x(split_x, p[0], p[1]);
        // seam pins: y seam (side walls)
        for (x = [2, base_w-2], z = [10, 25, 38]) pin_along_y(x, split_y, z);
    }
}

module base_piece(ix, iy)
    intersection() {
        base_body();
        translate([ix==0 ? -5 : split_x, iy==0 ? -5 : split_y, -5])
            cube([ix==0 ? split_x+5 : base_w-split_x+5,
                  iy==0 ? split_y+5 : base_d-split_y+5, rear_h+10]);
    }

// =====================================================================
//  BOTTOM PLATE (z = -plate_t .. 0)
// =====================================================================
module plate() {
    difference() {
        union() {
            translate([0,0,-plate_t]) linear_extrude(plate_t) offset(delta=-0.3) chamfer_rect(base_w, base_d, 10);
            // plinth: plate grows out under the shell and turns up as a chamfered lip
            difference() {
                hull() {
                    translate([0,0,-plate_t]) linear_extrude(0.01) offset(delta=skirt_o) chamfer_rect(base_w, base_d, 10);
                    translate([0,0,skirt_h-0.01]) linear_extrude(0.01) offset(delta=skirt_o-1.2) chamfer_rect(base_w, base_d, 10);
                }
                translate([0,0,-0.01]) linear_extrude(skirt_h+1) offset(delta=0.3) chamfer_rect(base_w, base_d, 10);
            }
            for (h = itx_holes) translate([board_x0+h[0], board_y0+h[1], 0]) cylinder(d=9, h=standoff_h);
        }
        for (h = itx_holes) translate([board_x0+h[0], board_y0+h[1], standoff_h-ins_depth]) cylinder(d=ins_d, h=ins_depth+1);
        // countersunk screws up into the shell bosses
        for (p = shell_bosses) translate([p[0],p[1],-plate_t-1]) {
            cylinder(d=screw_d, h=plate_t+2);
            translate([0,0,0.99]) cylinder(d1=6.6, d2=screw_d, h=1.6);
        }
        // vents under the board
        for (i = [0:9]) translate([board_x0+20, board_y0+15+i*14, -plate_t-1]) cube([130, 4, plate_t+2]);
        // rubber-foot recesses
        for (p = [[30,30],[base_w-30,30],[30,base_d-30],[base_w-30,base_d-30]])
            translate([p[0],p[1],-plate_t-1]) cylinder(d=12.5, h=2.5);
        // seam pins
        for (y = [40,120,220,320]) pin_along_x(plate_split_x, y, -plate_t/2);
        for (x = [60,180,320,420]) pin_along_y(x, plate_split_y, -plate_t/2);
    }
}

module plate_piece(ix, iy)
    intersection() {
        plate();
        translate([ix==0 ? -5 : plate_split_x, iy==0 ? -5 : plate_split_y, -plate_t-5])
            cube([ix==0 ? plate_split_x+5 : base_w-plate_split_x+5,
                  iy==0 ? plate_split_y+5 : base_d-plate_split_y+5, plate_t+standoff_h+10]);
    }

// =====================================================================
//  DISPLAY POD (local coords: front-bottom edge at origin)
// =====================================================================
module pod_profile()
    offset(delta=6, chamfer=true) offset(delta=-6)
        polygon([[0,0],[pod_top_y,pod_top_z],[pod_bot_d,pod_top_z],[pod_bot_d,0]]);

module pod_foot()
    polygon([[0,0],[pod_w,0],[pod_w,pod_bot_d-8],[pod_w-8,pod_bot_d],[8,pod_bot_d],[0,pod_bot_d-8]]);

module pod_solid(s=0)
    intersection() {
        translate([s,0,0]) extrude_x(pod_w-2*s) offset(delta=-s) pod_profile();
        translate([0,0,-1]) linear_extrude(pod_top_z+2) offset(delta=-s) pod_foot();
        translate([0,-1,0]) extrude_y(pod_bot_d+2) offset(delta=-s) chamfer_rect(pod_w, pod_top_z, 8);
        F() translate([0,0,-50]) linear_extrude(500) offset(delta=-s) chamfer_rect(pod_w, 500, 8);
    }

module pod_features() {
    // panel pocket ribs
    F() difference() {
        translate([cx-pocket_w/2-3, t-0.01, pocket_u0-3]) cube([pocket_w+6, rib_d, pocket_h+6]);
        translate([cx-pocket_w/2, t-1, pocket_u0]) cube([pocket_w, rib_d+2, pocket_h]);
    }
    for (p = clamp_pos) F() translate([p[0], t-0.01, p[1]]) rotate([-90,0,0]) cylinder(d=8, h=clamp_boss_h);
    for (p = hatch_pos) translate([p[0], pod_bot_d-t+0.01, p[1]]) rotate([90,0,0]) cylinder(d=9, h=10);
    for (p = mount_pos) translate([p[0], p[1], t-0.01]) cylinder(d=9, h=10);
    for (p = spk_boss_pos) {
        translate([t-0.01, p[0], p[1]]) rotate([0,90,0]) cylinder(d=9, h=spk_boss_h);
        translate([pod_w-t+0.01, p[0], p[1]]) rotate([0,-90,0]) cylinder(d=9, h=spk_boss_h);
    }
}

module pod_grooves()
    for (side = [0,1]) translate([side==1 ? pod_w-1.2 : -1, 0, 0])
        intersection() {
            extrude_x(2.2) offset(delta=-14) pod_profile();
            for (i = [0:3]) translate([-1, -1, 150+i*30]) cube([5, 400, 5]);
        }

// cheek profile in the face frame (y, u): front edge tapers out to hood_d at the top
module hood_cheek_2d()
    polygon([[2, hood_u0], [0, hood_u0], [-hood_d, pod_face_h], [2, pod_face_h]]);

module hood()
    F() intersection() {
        union() {
            for (x = [0, pod_w-hood_wall]) translate([x,0,0]) extrude_x(hood_wall) hood_cheek_2d();
            translate([0, -hood_d, pod_face_h-hood_wall]) cube([pod_w, hood_d+6, hood_wall]);
            translate([0, -hood_d, pod_face_h-hood_lip]) cube([pod_w, hood_wall, hood_lip]);
        }
        translate([0, -hood_d-10, 0]) extrude_y(hood_d+30) chamfer_rect(pod_w, pod_face_h, 8);
    }

module face_dressing() {
    F() translate([0, -ring_h, 0]) extrude_y(ring_h+0.01)
        translate([cx-open_w/2-ring_m, open_u0-ring_m]) rrect(open_w+2*ring_m, open_h+2*ring_m, ring_m);
    F() hull() {
        translate([cx-sill_x/2, -0.99, sill_u0]) cube([sill_x, 1, sill_hgt]);
        translate([cx-sill_x/2+sill_h, -sill_h, sill_u0+sill_h*0.75]) cube([sill_x-2*sill_h, 0.01, sill_hgt-1.5*sill_h]);
    }
}

module bolt_heads()
    for (x = bolt_x) F() translate([x, 0.01, bolt_u]) rotate([90,0,0]) cylinder(d=12, h=2.5);

module pod_body() {
    u_seam = (pod_split_z + 2.5*sin(pod_tilt)) / cos(pod_tilt);
    difference() {
        union() {
            difference() { pod_solid(0); pod_solid(t); }
            intersection() { pod_solid(0); pod_features(); }
            hood();
            bolt_heads();
            face_dressing();
        }
        // screen opening (rounded corners) with 45-degree bevel
        F() translate([0, -1, 0]) extrude_y(t+2) translate([cx-open_w/2, open_u0]) rrect(open_w, open_h, 3);
        F() hull() {
            translate([0, 1.49, 0]) extrude_y(0.01) translate([cx-open_w/2-2, open_u0-2]) rrect(open_w+4, open_h+4, 5);
            translate([0, 3.5, 0]) extrude_y(0.01) translate([cx-open_w/2, open_u0]) rrect(open_w, open_h, 3);
        }
        // rounded recess inside the raised ring, floor 1.5 mm into the face
        F() translate([0, -ring_h-1, 0]) extrude_y(ring_h+2.5)
            translate([cx-open_w/2-recess_m, open_u0-recess_m]) rrect(open_w+2*recess_m, open_h+2*recess_m, 10);
        // trim-strip channels, 2 mm deep
        for (x = trim_x) F() translate([x, -1, trim_u0]) cube([trim_w, 3, trim_len]);
        // bezel: button column, card-slot recess, indicator LEDs, round speaker grille
        for (u = btn_u) F() translate([col_x-btn_s/2, -1, u-btn_s/2]) cube([btn_s, t+2, btn_s]);
        // card slot recessed into the sill, red indicator at its left
        F() translate([cx-55, -sill_h-1, 15]) extrude_y(3) chamfer_rect(110, 14, 3);
        F() translate([cx-48, -sill_h-1, 20.5]) cube([96, sill_h+2, 3]);
        F() translate([cx-80, -sill_h-1, 22]) rotate([-90,0,0]) cylinder(d=3.2, h=sill_h+t+2);
        for (i = [0:3]) F() translate([cx+120+i*9, -1, 22]) rotate([-90,0,0]) cylinder(d=3.2, h=t+2);
        F() translate([spk_x, -1, spk_u]) extrude_y(2.5) circle(d=28);
        F() translate([spk_x, -1, spk_u]) extrude_y(t+1) grille_2d(11);
        // hex sockets in the bolt heads
        for (x = bolt_x) F() translate([x, -3.5, bolt_u]) rotate([-90,0,0]) cylinder(d=5, h=2, $fn=6);
        // side speaker grilles: recessed ring + perforation (recessed so pieces print flat on their sides)
        for (side = [0,1]) {
            translate([side==1 ? pod_w-1.2 : -1, 0, 0]) extrude_x(2.2)
                translate(side_spk) difference() { circle(d=2*side_spk_r+14); circle(d=2*side_spk_r+8); }
            translate([side==1 ? pod_w-t-1 : -1, 0, 0]) extrude_x(t+2)
                translate(side_spk) grille_2d(side_spk_r, d=3.5, pitch=5.5);
        }

        // rear access opening, top vents, cable hole
        translate([cx-184, pod_bot_d-t-1, 18]) cube([368, t+2, 232]);
        for (x = [cx-150:12:cx+150]) if (abs(x-cx) > 20)
            translate([x-2, pod_top_y+15, pod_top_z-t-1]) cube([4, 28, t+2]);
        translate([cx-170, 40, -1]) cube([80, 30, t+2]);

        // insert holes
        for (p = clamp_pos) F() translate([p[0], t+clamp_boss_h-ins_depth, p[1]]) rotate([-90,0,0]) cylinder(d=ins_d, h=ins_depth+1);
        for (p = hatch_pos) translate([p[0], pod_bot_d+1, p[1]]) rotate([90,0,0]) cylinder(d=ins_d, h=t+ins_depth+1);
        for (p = mount_pos) translate([p[0], p[1], -1]) cylinder(d=ins_d, h=t+ins_depth+1);
        for (p = spk_boss_pos, x = [t+spk_boss_h-ins_depth, pod_w-t-spk_boss_h-1])
            translate([x, p[0], p[1]]) rotate([0,90,0]) cylinder(d=ins_d, h=ins_depth+1);

        pod_grooves();

        // seam pins: x seam
        for (p = [[20,2],[60,2],[100,2],[85,pod_top_z-2],[110,pod_top_z-2],
                  [pod_bot_d-2,11],[pod_bot_d-2,257]])
            pin_along_x(cx, p[0], p[1]);
        for (u = [12, 40, 268]) F() pin_along_x(cx, 2.5, u);
        F() pin_along_x(cx, -hood_d/2, pod_face_h-hood_wall/2);              // hood roof
        F() pin_along_x(cx, -hood_d+hood_wall/2, pod_face_h-hood_lip/2);     // hood lip
        // seam pins: z seam
        for (x = [2.5, pod_w-2.5], y = [50, 85, 115]) pin_along_z(x, y, pod_split_z);
        for (x = [8.8, pod_w-8.8]) pin_along_z(x, pod_bot_d-2, pod_split_z);
        for (x = [hood_wall/2, pod_w-hood_wall/2]) pin_along_z(x, hood_pin_yz[0], pod_split_z);
        for (x = [14, pod_w-14]) F() pin_along_z(x, 2.5, u_seam);
    }
}

module pod_piece(ix, iz)
    intersection() {
        pod_body();
        translate([ix==0 ? -5 : cx, -5, iz==0 ? -5 : pod_split_z])
            cube([ix==0 ? cx+5 : pod_w-cx+5, pod_bot_d+10,
                  iz==0 ? pod_split_z+5 : hood_top_z-pod_split_z+5]);
    }

// =====================================================================
//  REAR HATCH and PANEL CLAMP
// =====================================================================
module hatch_2d()
    difference() {
        chamfer_rect(hatch_w, hatch_h, 6);
        for (p = hatch_pos) translate([p[0]-hatch_x0, p[1]-hatch_z0]) circle(d=screw_d);
        for (i = [0:9], s = [-1,1]) translate([hatch_w/2 + s*100 - 70, 50 + i*16]) square([140, 4]);
    }

module hatch_half(ix)
    linear_extrude(3) intersection() {
        hatch_2d();
        translate([ix==0 ? -1 : hatch_w/2, -1]) square([hatch_w/2+1, hatch_h+2]);
    }

// prints flat; 2 mm sits in the channel, 2 mm stands proud
module trim_strip() cube([trim_len-0.4, trim_w-0.4, 4]);

module clamp_tab() {
    difference() {
        cube([26, 10, 3]);
        translate([5, 5, -1]) cylinder(d=screw_d, h=5);
    }
    translate([20, 0, 0]) cube([6, 10, 3+clamp_foot]);
}

// =====================================================================
//  ASSEMBLY / PART SELECTION
// =====================================================================
// dummy parts: translucent in preview, or solid colour when solid_ghosts is set
module ghost(c) if (solid_ghosts) color(c) children(); else %children();

module assembly() {
    color(c_body) base_body();
    color(c_dark) plate();
    translate([pod_x0, pod_y0, rear_h]) {
        color(c_body) pod_body();
        color(c_accent) translate([hatch_x0, pod_bot_d, hatch_z0]) extrude_y(3) hatch_2d();
        for (x = trim_x) color(c_dark) F() translate([x+0.2, -2, trim_u0+0.2]) cube([trim_w-0.4, 4, trim_len-0.4]);
        if (show_ghosts) {
            ghost("#16261c") F() translate([cx-panel_w/2, t, pocket_u0+panel_clear]) cube([panel_w, panel_t, panel_h]);
            ghost("#c0302a") F() translate([cx-80, -sill_h-0.5, 22]) rotate([-90,0,0]) cylinder(d=3, h=sill_h+1);
            for (u = btn_u)   // button caps
                ghost(c_accent) F() translate([col_x-btn_s/2+0.4, -1.5, u-btn_s/2+0.4]) cube([btn_s-0.8, t+1.5, btn_s-0.8]);
        }
    }
    if (show_ghosts) {
        ghost("#2f5d3a") translate([board_x0, board_y0, standoff_h]) cube([itx, itx, pcb_t]);
        ghost(c_dark) translate([well_x0+5, well_y0+5, 0])
            cube([well_x1-well_x0-10, well_y1-well_y0-10, 25]);   // keyboard placeholder
        for (y = [125, 140]) ghost(c_accent) translate([438.5, y, front_h-t-0.5]) cylinder(d=6.8, h=t+1.5);
    }
}

module oriented_base(ix, iy)
    if (print_orient) translate([0,0, iy==0 ? front_h : rear_h]) rotate([180,0,0]) base_piece(ix, iy);
    else base_piece(ix, iy);

module oriented_plate(ix, iy)
    if (print_orient) translate([0,0,plate_t]) plate_piece(ix, iy);
    else plate_piece(ix, iy);

module oriented_pod(ix, iz)
    if (!print_orient) pod_piece(ix, iz);
    else if (ix == 0) rotate([0,-90,0]) pod_piece(ix, iz);
    else translate([0,0,pod_w]) rotate([0,90,0]) pod_piece(ix, iz);

if      (part == "assembly")  assembly();
else if (part == "base_FL")   oriented_base(0,0);
else if (part == "base_FR")   oriented_base(1,0);
else if (part == "base_RL")   oriented_base(0,1);
else if (part == "base_RR")   oriented_base(1,1);
else if (part == "plate_FL")  oriented_plate(0,0);
else if (part == "plate_FR")  oriented_plate(1,0);
else if (part == "plate_RL")  oriented_plate(0,1);
else if (part == "plate_RR")  oriented_plate(1,1);
else if (part == "pod_BL")    oriented_pod(0,0);
else if (part == "pod_BR")    oriented_pod(1,0);
else if (part == "pod_TL")    oriented_pod(0,1);
else if (part == "pod_TR")    oriented_pod(1,1);
else if (part == "hatch_L")   hatch_half(0);
else if (part == "hatch_R")   hatch_half(1);
else if (part == "clamp_tab") clamp_tab();
else if (part == "trim_strip") trim_strip();
