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
//          pod_BL pod_BR pod_TL pod_TR | hatch_L hatch_R | clamp_tab | trim_strip |
//          gasket_L gasket_R | visor | cam_body cam_cap cam_cradle | island_L
//  (F/R = front/rear, L/R = left/right, B/T = bottom/top)
//
//  Joining: 2.0 mm holes on every seam take 1.75 mm filament offcuts as
//  alignment pins; glue the seams (CA or solvent), then the screwed-on
//  bottom plate and rear hatch tie everything together.
// =====================================================================

part = "assembly";
print_orient = true;   // rotate pieces into their suggested print orientation
show_ghosts  = false;   // panel/board dummies in the assembly view
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
front_h = 45;  rear_h = 100;        // front_h: deck height where it meets the ramp
ramp_y0 = 165; ramp_y1 = 195;
// keyboard (check against yours): footprint, and body height below the keycaps at the
// front and back edges (feet removed). The well is open to the bottom plate; sloping ribs
// on the plate hold the keyboard so the top of its body sits flush with the deck.
kb_w = 293;  kb_d = 107;  kb_t0 = 15;  kb_t1 = 15;  kb_clear = 2;
// keyboard deck is a wedge: deck_h0 high at the front, rising to front_h at ramp_y0
deck_h0 = 31.1;
deck_a = atan2(front_h-deck_h0, ramp_y0);
function deck_z(y) = deck_h0 + y*tan(deck_a);
front_ch_h = 10;  front_ch_d = 9;    // chamfer on the front top edge so the deck reads thinner
base_corner_xy = 28;  base_corner_z = 14;   // facet on each top-front corner: reach along the top, depth down the corner (keep it above the plinth)
ramp_corner_xy = 12;  ramp_corner_d = 8;    // smaller facet at the top of the ramp: reach along the top edges (keep under the 15 mm strip in front of the pod), and down the ramp edge
well_x0 = base_w/2-kb_w/2-kb_clear;  well_x1 = base_w/2+kb_w/2+kb_clear;
well_y0 = 12;  well_y1 = well_y0+kb_d+2*kb_clear;
kb_rib_x = [125, 190, 270, 355];   // clear of the plate seam at plate_split_x and of the cable notches
// cable notches in the back wall of the well: [left x, width]. The left one is centred on a
// port kb_port_l in from the keyboard's left edge.
kb_port_l = 15;
kb_notches = [[base_w/2-kb_w/2+kb_port_l-15, 30], [300, 40]];
deck_lx = well_x0/2;  deck_rx = (well_x1+base_w)/2;   // centres of the deck either side of the well
// islands on the deck either side of the keyboard, running back to the foot of the grille
// panel (ramp_y0). Each is [centre x, front y, width, kind, features], a feature being
// [deck y, "hole" diameter | "grille" radius, size].
//  "raised": a separate print glued into an isl_seat-deep locating pocket, isl_h proud.
//  "sunken": a recess isl_sink deep cut into the deck, backed underneath to keep t of material.
// Left: 3 indicator LEDs and a mic grille. Right: 16 mm power button, LED, two 7 mm buttons.
isl_h = 3;  isl_seat = 0.6;  isl_clear = 0.2;  isl_r = 4;  isl_ch = 1.5;  isl_sink = 2;
islands = [[deck_lx, 40, 29, "raised", [[60,"hole",5.2], [80,"hole",5.2], [100,"hole",5.2], [132,"grille",8]]],
           [deck_rx, 52, 44, "sunken", [[80,"hole",16.2], [110,"hole",5.2], [125,"hole",7.2], [140,"hole",7.2]]]];
plate_t = 5;
// plinth lip round the base: tall at the front and sides, dropping to skirt_h_rear
// from skirt_rear_y back so it stays under the I/O cutout (5.3 mm)
skirt_o = 8;  skirt_h = 14;  skirt_h_rear = 4;  skirt_rear_y = 310;
split_x = 230;  split_y = 165;
badge_s = 18;  badge_clear = 0.5;  badge_depth = 1.2;   // square PC case badge (18 mm is the common sticker size)
ramp_angle = atan2(rear_h-front_h, ramp_y1-ramp_y0);
plate_split_x = 240;  plate_split_y = 180;   // offset from the shell seam; keep split + skirt_o under the bed size
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
scr_off = 11;   // screen sits right of centre, leaving room for the button panel inside the hood
scr_cx = cx + scr_off;

pocket_w = panel_w + 2*panel_clear;
pocket_h = panel_h + 2*panel_clear;
pocket_u0 = bezel_bottom;
active_u0 = pocket_u0 + panel_clear + active_bottom_margin;
open_w = active_w + 2;  open_h = active_h + 2;
open_u0 = active_u0 - 1;
rib_d = 9;
clamp_boss_h = 10;
clamp_foot = clamp_boss_h - panel_t - 0.8;   // leaves room for a thin foam pad

clamp_pos = [[scr_cx-192,80],[scr_cx-192,200],[scr_cx+192,80],[scr_cx+192,200],
             [scr_cx-100,265],[scr_cx+100,265],[scr_cx-100,22],[scr_cx+100,22]];
hatch_pos = [[cx-190,60],[cx-190,210],[cx+190,60],[cx+190,210],
             [cx-100,11],[cx+100,11],[cx-100,257],[cx+100,257]];
mount_pos = [[cx-170,20],[cx+170,20],[cx-170,110],[cx+170,110]];   // pod coords
pod_mounts_global = [for (p = mount_pos) [p[0]+pod_x0, p[1]+pod_y0]];

// screen hood, built in the face frame F(): a U (cheeks + roof) seen from the front,
// big radius on its top corners, rounded front edges. The front edge runs from hood_d0
// deep at hood_u0 to hood_d at the top of the face; below that the cheek feet sweep back
// at hood_foot degrees from the face and meet it at hood_u0.
hood_d = 50;  hood_d0 = 28;  hood_u0 = 40;  hood_wall = 9;  hood_foot = 45;
hood_in = 10;   // cheeks sit this far in from the sides of the pod, so the hood reads as part of the face
hood_R = 30;  hood_ri = 10;  hood_r = 5;  hood_steps = 10;   // outer / inner corner radius, front-edge radius
hood_back = 8;   // hood reaches this far behind the face, filling the pod's vertical edge chamfer
// brow: the roof's front edge bulges forward in the middle, with angled ends
brow_w = 160;  brow_d = 12;  brow_taper = 25;
function hood_depth(u) = hood_d0 + (hood_d - hood_d0) * (u - hood_u0) / (pod_face_h - hood_u0);
hood_foot_k = tan(hood_foot);   // foot depth gained per mm up the face
hood_knee_u = hood_u0 + hood_d0 / (hood_foot_k - (hood_d - hood_d0) / (pod_face_h - hood_u0));   // foot meets front edge
// F() point (y, u) -> pod (y, z)
function F_yz(y, u) = [y*cos(pod_tilt) + u*sin(pod_tilt), -y*sin(pod_tilt) + u*cos(pod_tilt)];
// pod (y, z) of the point at face depth yf that lies on the z seam
function seam_yz(yf) = F_yz(yf, (pod_split_z + yf*sin(pod_tilt)) / cos(pod_tilt));
hood_top_z = F_yz(-hood_d-brow_d, pod_face_h)[1];   // front edge of the brow rises above the pod top
// tinted visor: two windows in the roof either side of a centre bar (the x seam runs
// through the bar), rebated from the top for 2 mm translucent green inserts
visor_x = [[hood_in+hood_wall+16, cx-10], [cx+10, pod_w-hood_in-hood_wall-16]];
visor_y = [-38, -8];  visor_lip = 4;  visor_t = 2;

// lower bezel (u = height up the face)
// left side bezel: a raised panel holding a column of 4 square buttons (12 mm caps)
// above a round speaker grille
bp_w = 22;
col_x = hood_in+hood_wall+3+bp_w/2;   // 3 mm in from the cheek
btn_s = 12.4;
btn_u = [for (i = [0:3]) 200-i*20];
spk_x = col_x;  spk_u = 100;                     // front speaker grille
bp_u0 = spk_u-16;  bp_u1 = btn_u[0]+12;  bp_h = 3;   // button panel
// hinge knobs at the cheek feet, so the hood looks like it pivots
knob_x = [hood_in+9, pod_w-hood_in-9];  knob_u = 24;  knob_d = 22;  knob_h = 6;
// CRT-style surround: raised rounded ring around a rounded recess
ring_m = 20;  ring_h = 4;  recess_m = 12;  recess_r = 16;
sill_x = 300;  sill_u0 = 10;  sill_hgt = 24;  sill_h = 4;   // raised sill under the screen
slot_x0 = scr_cx-120;                                         // card slot, red LED at its left
// dark gasket: separate print (two halves) glued into the recess. Funnels out towards
// the viewer and stands proud of the ring; its round inner corners mask the panel corners.
gasket_r = 16;  gasket_proud = 3;  gasket_flare = 4;
gasket_t = ring_h + 1.5 + gasket_proud;
// dark trim strips (separate dark prints glued into channels down the outside of each
// hood cheek, along its back edge just in front of the face)
trim_w = 3.5;  trim_y = -5;  trim_u0 = hood_u0+15;  trim_len = pod_face_h-hood_R-2-trim_u0;
// webcam on the sill: tube body in a cradle glued to the sill. The bore suits a
// laptop-style strip camera module; the cable runs down through the cradle into the pod.
cam_x = scr_cx+50;  cam_d = 24;  cam_bore = 19;  cam_len = 60;  cam_lens = 8;
cam_ax = [15, 23];      // tube axis in cradle coords (out from the sill, up the face)
cr_u0 = 13;  cr_w = cam_len-16;  cr_dep = 22;  cr_h = cam_ax[1]-cam_d/2+7;  cr_cable_z = 8.5;
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
    polygon([[0,0],[0,deck_h0-front_ch_h],[front_ch_d,deck_z(front_ch_d)],[ramp_y0,front_h],[ramp_y1,rear_h],
             [base_d-8,rear_h],[base_d,rear_h-8],[base_d,0]]);

// cuts the two top-front corners with a facet reaching a along the top edges and b down
// the corner: everything on the corner side of the plane x/a + y/a - (z - deck_h0)/b = k,
// where k moves the plane in by off (a tetrahedron hull)
module base_corner_cut(a, b, off=0)
    let (k = 1 + off*sqrt(2/(a*a) + 1/(b*b)))
    for (m = [0, 1]) translate([m*base_w, 0, 0]) mirror([m, 0, 0]) hull()
        for (p = [[-60, -60, deck_h0+60], [a*k+60, -60, deck_h0], [-60, a*k+60, deck_h0],
                  [-30, -30, deck_h0-b*(k+60/a)]])
            translate(p) cube(0.01, center=true);

// the two corners at the top of the ramp, where ramp, top and side wall meet: s scales the
// facet's three corner points (1 = the facet itself), p is the point down the ramp edge
ramp_dir = [0, ramp_y0-ramp_y1, front_h-rear_h] / norm([0, ramp_y0-ramp_y1, front_h-rear_h]);
module ramp_corner_tetra(s=1, grow=0)
    for (m = [0, 1]) translate([m*base_w, 0, 0]) mirror([m, 0, 0])
        let (c = [0, ramp_y1, rear_h],
             p = [c + s*[ramp_corner_xy, 0, 0], c + s*[0, ramp_corner_xy, 0], c + s*ramp_corner_d*ramp_dir],
             g = (p[0] + p[1] + p[2]) / 3)
        hull() for (q = [c + grow*(c-g)/norm(c-g), for (v = p) v + grow*(v-g)/norm(v-g)])
            translate(q) cube(0.01, center=true);

module base_outer()
    difference() {
        intersection() {
            extrude_x(base_w) base_profile();
            translate([0,0,-1]) linear_extrude(rear_h+2) chamfer_rect(base_w, base_d, 10);
        }
        base_corner_cut(base_corner_xy, base_corner_z);
        ramp_corner_tetra(1, 2);   // pushed slightly outward so no skin is left on the faces
    }

module base_inner()
    difference() {
        intersection() {
            translate([t,0,0]) extrude_x(base_w-2*t) union() {
                offset(delta=-t) base_profile();
                translate([t,-1]) square([base_d-2*t, t+1]);
            }
            translate([0,0,-2]) linear_extrude(rear_h+4) offset(delta=-t) chamfer_rect(base_w, base_d, 10);
        }
        base_corner_cut(base_corner_xy, base_corner_z, t);   // same plane, moved in by the wall thickness
    }

// local frame on the sloping deck: origin on the deck surface at (x, y), z normal to it
module on_deck(x, y) translate([x, y, deck_z(y)]) rotate([deck_a,0,0]) children();

// island length along the sloping deck, from its front edge to the foot of the grille panel
function isl_len(isl) = (ramp_y0 - isl[1]) / cos(deck_a);
// feature position along the island
function isl_fy(isl, f) = (f[0] - isl[1]) / cos(deck_a);

// island outline in its own frame (origin at its front-centre on the deck): rounded front
// corners, square back ending short by `back` (negative runs past the grille panel's foot).
// Grown by e, but never further back than that.
module island_2d(isl, e=0, back=0)
    let (w = isl[2], l = isl_len(isl) - back)
    intersection() {
        offset(delta=e) hull() {
            translate([-w/2, 0]) rrect(w, l, isl_r);
            translate([-w/2, l/2]) square([w, l/2]);
        }
        translate([-w, -10]) square([2*w, isl_len(isl)-min(back, 0)+10]);
    }
// the same outline chamfered in by isl_ch at the sides and front, back edge kept square
module island_top_2d(isl, back=0)
    hull() {
        offset(delta=-isl_ch) island_2d(isl, 0, back);
        translate([-isl[2]/2+isl_ch, isl_len(isl)-back-0.01]) square([isl[2]-2*isl_ch, 0.01]);
    }

// one hole or grille, h tall, centred on the origin
module island_feature(f, h)
    if (f[1] == "grille") linear_extrude(h) grille_2d(f[2]);
    else cylinder(d=f[2], h=h);

// a raised island part: seats in its pocket, chamfered above the deck; prints as is
module island(isl)
    difference() {
        hull() {
            linear_extrude(isl_seat+0.01) island_2d(isl, 0, isl_clear);
            translate([0, 0, isl_seat+isl_h-0.01]) linear_extrude(0.01) island_top_2d(isl, isl_clear);
        }
        for (f = isl[4]) translate([0, isl_fy(isl, f), -1]) island_feature(f, isl_seat+isl_h+2);
    }

// cut into the deck for an island (on_deck frame): the pocket or the chamfered recess
module island_cut(isl)
    if (isl[3] == "raised")
        translate([0, 0, -isl_seat]) linear_extrude(isl_seat+1) island_2d(isl, isl_clear);
    else hull() {
        // runs past the grille panel's foot; base_body trims it there with an upright back wall
        translate([0, 0, -isl_sink]) linear_extrude(0.01) island_top_2d(isl, -3);
        linear_extrude(1) island_2d(isl, 0, -3);
    }
// how far below the deck surface an island's floor sits
function isl_floor(isl) = isl[3] == "raised" ? 0 : isl_sink;

module well_box(e=0)
    translate([well_x0-e, well_y0-e, -1]) cube([well_x1-well_x0+2*e, well_y1-well_y0+2*e, front_h+2]);

module base_body() {
    difference() {
        union() {
            difference() { base_outer(); base_inner(); }
            intersection() { base_outer(); well_box(t); }
            intersection() { base_outer(); ramp_corner_tetra(3); }   // solid behind the ramp corner facets
            // backing under sunken islands, so the recess floor keeps a full wall
            for (isl = islands) if (isl[3] == "sunken") intersection() {
                base_outer();
                on_deck(isl[0], isl[1]) translate([0, 0, -t-isl_sink]) linear_extrude(isl_sink+0.01) island_2d(isl, 3);
            }
            intersection() {
                base_outer();
                for (p = shell_bosses) translate([p[0],p[1],0]) cylinder(d=8, h=rear_h+1);
            }
        }
        // keyboard well (open to the bottom plate) + cable notches through its back wall,
        // tall enough for a plug to pass into the base, with the deck left bridging over them
        well_box(0);
        for (n = kb_notches) translate([n[0], well_y1-1, -1]) cube([n[1], t+2, deck_z(well_y1)-t+1]);

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

        // deck islands: pockets or recesses, and their holes through the deck
        for (isl = islands) {
            intersection() {
                on_deck(isl[0], isl[1]) island_cut(isl);
                translate([-1, -1, -1]) cube([base_w+2, ramp_y0+1, rear_h+2]);   // upright back wall at the grille panel
            }
            for (f = isl[4]) on_deck(isl[0], f[0]) translate([0,0,-t-isl_floor(isl)-1]) island_feature(f, t+isl_floor(isl)+2);
        }
        // label plate, front left
        on_deck(deck_lx-14, 23) translate([0,0,-1]) linear_extrude(2) chamfer_rect(28, 14, 2);

        // decorative groove across the front, midway between the plinth and the chamfer
        translate([-1, -1, (skirt_h+deck_h0-front_ch_h)/2-1]) cube([base_w+2, 2, 2]);

        // seam pins: x seam
        for (p = [[2,12],[3,20],[10,15],[10,28],[well_y1+2,15],[well_y1+2,30],[160,43],
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
// ribs in the keyboard well: the keyboard's underside sits on them, its body top flush with
// the deck. They slope by the difference between the deck's slope and the keyboard's own.
kb_rib_y0 = well_y0+kb_clear;  kb_rib_y1 = well_y1-kb_clear;
function kb_body(y) = kb_t0 + (kb_t1-kb_t0)*(y-kb_rib_y0)/kb_d;
function kb_floor_z(y) = deck_z(y) - kb_body(y);
kb_floor_a = atan2(kb_floor_z(kb_rib_y1)-kb_floor_z(kb_rib_y0), kb_d);
module kb_ribs()
    for (x = kb_rib_x) translate([x-1.5, 0, -0.01]) extrude_x(3)
        polygon([[kb_rib_y0, 0], [kb_rib_y1, 0], [kb_rib_y1, kb_floor_z(kb_rib_y1)], [kb_rib_y0, kb_floor_z(kb_rib_y0)]]);

module plate() {
    difference() {
        union() {
            translate([0,0,-plate_t]) linear_extrude(plate_t) offset(delta=-0.3) chamfer_rect(base_w, base_d, 10);
            // plinth: plate grows out under the shell and turns up as a chamfered lip
            difference() {
                hull() {
                    translate([0,0,-plate_t]) linear_extrude(0.01) offset(delta=skirt_o) chamfer_rect(base_w, base_d, 10);
                    translate([0,0,skirt_h-0.01]) linear_extrude(0.01) offset(delta=skirt_o-2) chamfer_rect(base_w, base_d, 10);
                }
                translate([0,0,-0.01]) linear_extrude(skirt_h+1) offset(delta=0.3) chamfer_rect(base_w, base_d, 10);
                // 45-degree step down to the low rear lip
                translate([-skirt_o-1, 0, 0]) extrude_x(base_w+2*skirt_o+2)
                    polygon([[skirt_rear_y, skirt_h+1], [skirt_rear_y+skirt_h+1-skirt_h_rear, skirt_h_rear],
                             [base_d+skirt_o+1, skirt_h_rear], [base_d+skirt_o+1, skirt_h+1]]);
            }
            for (h = itx_holes) translate([board_x0+h[0], board_y0+h[1], 0]) cylinder(d=9, h=standoff_h);
            kb_ribs();
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
        translate([ix==0 ? -skirt_o-5 : plate_split_x, iy==0 ? -skirt_o-5 : plate_split_y, -plate_t-5])
            cube([ix==0 ? plate_split_x+skirt_o+5 : base_w-plate_split_x+skirt_o+5,
                  iy==0 ? plate_split_y+skirt_o+5 : base_d-plate_split_y+skirt_o+5, plate_t+max(standoff_h, skirt_h, kb_floor_z(kb_rib_y0), kb_floor_z(kb_rib_y1))+10]);
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
        translate([scr_cx-pocket_w/2-3, t-0.01, pocket_u0-3]) cube([pocket_w+6, rib_d, pocket_h+6]);
        translate([scr_cx-pocket_w/2, t-1, pocket_u0]) cube([pocket_w, rib_d+2, pocket_h]);
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

// hood outline in the face plane (x, u), inset by i: cheeks + roof, round top corners
module hood_2d(i=0)
    offset(r=-i) difference() {
        intersection() {   // rounded rect whose lower corners fall below the cheek feet
            translate([hood_in, hood_u0-hood_R]) rrect(pod_w-2*hood_in, pod_face_h-hood_u0+hood_R, hood_R);
            translate([0, hood_u0]) square([pod_w, pod_face_h]);
        }
        translate([hood_in+hood_wall, hood_u0-50])
            rrect(pod_w-2*(hood_in+hood_wall), pod_face_h-hood_wall-hood_u0+50, hood_ri);
    }

// everything behind the hood's front surface and swept-back feet, pulled back by s
module hood_depth_region(s)
    extrude_x(pod_w) polygon([[hood_back, hood_u0-(hood_back-s)/hood_foot_k],
                              [-hood_depth(hood_knee_u)+s, hood_knee_u],
                              [-hood_depth(pod_face_h+20)+s, pod_face_h+20], [hood_back, pod_face_h+20]]);

// the brow in plan (x, y), pulled back by s; its ends fall behind the main front edge
module brow_region(s)
    translate([0, 0, pod_face_h-hood_wall-1]) linear_extrude(hood_wall+2) offset(delta=-s)
        polygon([[cx-brow_w/2-brow_taper, -hood_d+2], [cx-brow_w/2, -hood_d-brow_d],
                 [cx+brow_w/2, -hood_d-brow_d], [cx+brow_w/2+brow_taper, -hood_d+2],
                 [cx+brow_w/2+brow_taper, hood_back+10], [cx-brow_w/2-brow_taper, hood_back+10]]);

// front edges rounded by stacking quarter-round steps: each step insets the outline a
// little more and reaches a little further forward
module hood()
    F() for (k = [0:hood_steps]) let (a = 90*k/hood_steps)
        intersection() {
            translate([0, -100, 0]) extrude_y(100+hood_back) hood_2d(hood_r*(1-cos(a)));
            union() {
                hood_depth_region(hood_r*(1-sin(a)));
                brow_region(hood_r*(1-sin(a)));
            }
        }

module face_dressing() {
    F() translate([0, -ring_h, 0]) extrude_y(ring_h+0.01)
        translate([scr_cx-open_w/2-ring_m, open_u0-ring_m]) rrect(open_w+2*ring_m, open_h+2*ring_m, ring_m);
    F() hull() {
        translate([scr_cx-sill_x/2, -0.99, sill_u0]) cube([sill_x, 1, sill_hgt]);
        translate([scr_cx-sill_x/2+sill_h, -sill_h, sill_u0+sill_h*0.75]) cube([sill_x-2*sill_h, 0.01, sill_hgt-1.5*sill_h]);
    }
    // raised button panel, 45-degree sides so it prints on the pod's side
    F() hull() {
        translate([0, -0.99, 0]) extrude_y(1) translate([col_x-bp_w/2, bp_u0]) rrect(bp_w, bp_u1-bp_u0, 6);
        translate([0, -bp_h, 0]) extrude_y(0.01)
            translate([col_x-bp_w/2+bp_h, bp_u0+bp_h]) rrect(bp_w-2*bp_h, bp_u1-bp_u0-2*bp_h, 4);
    }
}

module hinge_knobs()
    for (x = knob_x) F() translate([x, 0.01, knob_u]) rotate([90,0,0]) {
        cylinder(d=knob_d, h=knob_h-1.5);
        translate([0, 0, knob_h-1.51]) cylinder(d1=knob_d, d2=knob_d-3, h=1.5);
        cylinder(d=10, h=knob_h+1.5);   // centre cap
    }

module pod_body() {
    u_seam = (pod_split_z + 2.5*sin(pod_tilt)) / cos(pod_tilt);
    difference() {
        union() {
            difference() { pod_solid(0); pod_solid(t); }
            intersection() { pod_solid(0); pod_features(); }
            hood();
            hinge_knobs();
            face_dressing();
        }
        // screen opening (rounded corners) with 45-degree bevel
        F() translate([0, -1, 0]) extrude_y(t+2) translate([scr_cx-open_w/2, open_u0]) rrect(open_w, open_h, 3);
        F() hull() {
            translate([0, 1.49, 0]) extrude_y(0.01) translate([scr_cx-open_w/2-2, open_u0-2]) rrect(open_w+4, open_h+4, 5);
            translate([0, 3.5, 0]) extrude_y(0.01) translate([scr_cx-open_w/2, open_u0]) rrect(open_w, open_h, 3);
        }
        // rounded recess inside the raised ring for the gasket, floor 1.5 mm into the face
        F() translate([0, -ring_h-1, 0]) extrude_y(ring_h+2.5)
            translate([scr_cx-open_w/2-recess_m, open_u0-recess_m]) rrect(open_w+2*recess_m, open_h+2*recess_m, recess_r);
        // visor windows and their rebates
        for (w = visor_x) F() {
            translate([w[0], visor_y[0], pod_face_h-hood_wall-1]) cube([w[1]-w[0], visor_y[1]-visor_y[0], hood_wall+2]);
            translate([w[0]-visor_lip, visor_y[0]-visor_lip, pod_face_h-visor_t-0.2])
                cube([w[1]-w[0]+2*visor_lip, visor_y[1]-visor_y[0]+2*visor_lip, 5]);
        }
        // trim-strip channels down the outside of each hood cheek, 2 mm deep
        for (x = [hood_in-1, pod_w-hood_in-2]) F() translate([x, trim_y, trim_u0]) cube([3, trim_w, trim_len]);
        // bezel: button column and speaker grille through the raised panel
        for (u = btn_u) F() translate([col_x-btn_s/2, -bp_h-1, u-btn_s/2]) cube([btn_s, bp_h+t+2, btn_s]);
        F() translate([spk_x, -bp_h-1, spk_u]) extrude_y(2.5) circle(d=15);
        F() translate([spk_x, -bp_h-1, spk_u]) extrude_y(bp_h+t+1) grille_2d(6.5);
        // card slot recessed into the sill, red indicator at its left, indicator LEDs at the right
        F() translate([slot_x0, -sill_h-1, 15]) extrude_y(3) chamfer_rect(110, 14, 3);
        F() translate([slot_x0+7, -sill_h-1, 20.5]) cube([96, sill_h+2, 3]);
        F() translate([slot_x0-12, -sill_h-1, 22]) rotate([-90,0,0]) cylinder(d=3.2, h=sill_h+t+2);
        for (i = [0:3]) F() translate([scr_cx+100+i*9, -sill_h-1, 22]) rotate([-90,0,0]) cylinder(d=3.2, h=sill_h+t+2);
        // webcam cable hole behind the cradle
        F() translate([cam_x, -sill_h-1, cr_u0+cr_cable_z]) rotate([-90,0,0]) cylinder(d=8, h=sill_h+t+2);
        // hex sockets in the knob caps
        for (x = knob_x) F() translate([x, -knob_h-2.5, knob_u]) rotate([-90,0,0]) cylinder(d=5, h=2, $fn=6);
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
        for (y = [-54, -44, -22]) F() pin_along_x(cx, y, pod_face_h-hood_wall/2-1);   // hood roof (brow + centre bar)
        // seam pins: z seam
        for (x = [2.5, pod_w-2.5], y = [50, 85, 115]) pin_along_z(x, y, pod_split_z);
        for (x = [8.8, pod_w-8.8]) pin_along_z(x, pod_bot_d-2, pod_split_z);
        for (x = [hood_in+hood_wall/2, pod_w-hood_in-hood_wall/2], yf = [-12, -24]) pin_along_z(x, seam_yz(yf)[0], pod_split_z);   // cheeks
        for (x = [14, pod_w-14]) F() pin_along_z(x, 2.5, u_seam);
    }
}

module pod_piece(ix, iz)
    intersection() {
        pod_body();
        translate([ix==0 ? -5 : cx, -60, iz==0 ? -5 : pod_split_z])   // hood cheeks reach in front of y = 0
            cube([ix==0 ? cx+5 : pod_w-cx+5, pod_bot_d+65,
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

// =====================================================================
//  GASKET, VISOR and WEBCAM (separate prints)
// =====================================================================
// origin at the bottom-left of the screen opening; z = 0 sits on the recess floor.
// Prints as is: the funnel widens upwards, so there is no overhang.
module gasket()
    difference() {
        linear_extrude(gasket_t) offset(delta=-0.3)
            translate([-recess_m, -recess_m]) rrect(open_w+2*recess_m, open_h+2*recess_m, recess_r);
        hull() {
            translate([0, 0, -0.01]) linear_extrude(0.01) rrect(open_w, open_h, gasket_r);
            translate([0, 0, gasket_t]) linear_extrude(0.01) offset(r=gasket_flare) rrect(open_w, open_h, gasket_r);
        }
    }

module gasket_half(ix)   // too wide for the bed in one piece
    intersection() {
        gasket();
        translate([ix==0 ? -recess_m-1 : open_w/2, -recess_m-1, -1])
            cube([open_w/2+recess_m+1, open_h+2*recess_m+2, gasket_t+2]);
    }

// translucent green insert for one roof window; prints flat
module visor()
    cube([visor_x[0][1]-visor_x[0][0]+2*visor_lip-0.4, visor_y[1]-visor_y[0]+2*visor_lip-0.4, visor_t]);

// tube along x with the lens facing +y and the cable exit facing -z; closed at x = 0
module cam_body()
    difference() {
        rotate([0,90,0]) cylinder(d=cam_d, h=cam_len, $fn=60);
        translate([2.5, 0, 0]) rotate([0,90,0]) cylinder(d=cam_bore, h=cam_len, $fn=60);
        translate([cam_len/2, 0, 0]) rotate([-90,0,0]) cylinder(d=cam_lens, h=cam_d);
        translate([cam_len/2, cam_d/2-1, 0]) rotate([-90,0,0]) cylinder(d=cam_lens+6, h=2);   // flat lens seat
        translate([cam_len/2, 0, 0]) rotate([180,0,0]) cylinder(d=7, h=cam_d);
        for (x = [5, cam_len-7]) translate([x, 0, 0]) rotate([0,90,0])   // end-cap bands
            difference() { cylinder(d=cam_d+1, h=1.2, $fn=60); cylinder(d=cam_d-1.6, h=1.2, $fn=60); }
    }

// press-fit plug for the open end, with a small grille
module cam_cap()
    difference() {
        union() { cylinder(d=cam_d, h=2, $fn=60); cylinder(d=cam_bore-0.3, h=6, $fn=60); }
        translate([0, 0, 2]) cylinder(d=cam_bore-2.7, h=5, $fn=60);
        translate([0, 0, -1]) linear_extrude(4) grille_2d(cam_bore/2-3, d=2, pitch=3);
    }

// x along the tube, y out from the sill, z up the face; origin at the back-bottom centre.
// The back glues to the sill; prints standing on its bottom.
module cam_cradle()
    difference() {
        translate([-cr_w/2, 0, 0]) extrude_x(cr_w)
            polygon([[0,0], [cr_dep-4,0], [cr_dep,4], [cr_dep,cr_h], [0,cr_h]]);
        translate([-cr_w, cam_ax[0], cam_ax[1]]) rotate([0,90,0]) cylinder(d=cam_d+0.4, h=2*cr_w, $fn=60);
        translate([0, -1, cr_cable_z]) rotate([-90,0,0]) cylinder(d=7, h=cam_ax[0]+1);
        translate([0, cam_ax[0], cr_cable_z]) cylinder(d=7, h=cr_h);
    }

// cradle, tube and cap together, in cradle coords
module webcam() {
    color(c_body) cam_cradle();
    color(c_body) translate([-cam_len/2, cam_ax[0], cam_ax[1]]) cam_body();
    color(c_dark) translate([cam_len/2+2, cam_ax[0], cam_ax[1]]) rotate([0,-90,0]) cam_cap();
}

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
    for (isl = islands) if (isl[3] == "raised") color(c_body) on_deck(isl[0], isl[1]) translate([0,0,-isl_seat]) island(isl);
    color(c_dark) plate();
    translate([pod_x0, pod_y0, rear_h]) {
        color(c_body) pod_body();
        color(c_accent) translate([hatch_x0, pod_bot_d, hatch_z0]) extrude_y(3) hatch_2d();
        for (x = [hood_in-2, pod_w-hood_in-2]) color(c_dark) F() translate([x, trim_y+0.2, trim_u0+0.2]) cube([4, trim_w-0.4, trim_len-0.4]);
        color(c_dark) F() translate([scr_cx-open_w/2, 1.5, open_u0]) rotate([90,0,0]) gasket();
        for (w = visor_x) color("#4f9a63", 0.7)
            F() translate([w[0]-visor_lip+0.2, visor_y[0]-visor_lip+0.2, pod_face_h-visor_t-0.2]) visor();
        F() translate([cam_x, -sill_h, cr_u0]) mirror([0,1,0]) webcam();
        if (show_ghosts) {
            ghost("#16261c") F() translate([scr_cx-panel_w/2, t, pocket_u0+panel_clear]) cube([panel_w, panel_t, panel_h]);
            ghost("#c0302a") F() translate([slot_x0-12, -sill_h-0.5, 22]) rotate([-90,0,0]) cylinder(d=3, h=sill_h+1);
            ghost("#16261c") F() translate([cam_x, -sill_h-cam_ax[0]-cam_d/2+0.5, cr_u0+cam_ax[1]])
                rotate([-90,0,0]) cylinder(d=cam_lens, h=2);   // lens
            for (u = btn_u)   // button caps
                ghost(c_accent) F() translate([col_x-btn_s/2+0.4, -bp_h-1.5, u-btn_s/2+0.4]) cube([btn_s-0.8, bp_h+t+1.5, btn_s-0.8]);
        }
    }
    if (show_ghosts) {
        ghost("#2f5d3a") translate([board_x0, board_y0, standoff_h]) cube([itx, itx, pcb_t]);
        ghost(c_dark) translate([base_w/2-kb_w/2, kb_rib_y0, kb_floor_z(kb_rib_y0)]) rotate([kb_floor_a,0,0])
            extrude_x(kb_w) polygon([[0,0], [kb_d,0], [kb_d,kb_t1], [0,kb_t0]]);   // keyboard placeholder (body only)
        for (y = [125, 140]) ghost(c_accent) on_deck(deck_rx, y) translate([0,0,-t-isl_sink-0.5]) cylinder(d=6.8, h=t+1.5);
    }
}

// base pieces print upside down; the front pair are tilted so the sloping deck lies flat
module oriented_base(ix, iy)
    if (!print_orient) base_piece(ix, iy);
    else if (iy == 0) rotate([180,0,0]) rotate([-deck_a,0,0]) translate([0,0,-deck_h0]) base_piece(ix, iy);
    else translate([0,0,rear_h]) rotate([180,0,0]) base_piece(ix, iy);

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
else if (part == "gasket_L")  gasket_half(0);
else if (part == "gasket_R")  gasket_half(1);
else if (part == "visor")     visor();
else if (part == "cam_body")  { if (print_orient) rotate([0,-90,0]) cam_body(); else cam_body(); }
else if (part == "cam_cap")   cam_cap();
else if (part == "cam_cradle") cam_cradle();
else if (part == "island_L")  island(islands[0]);
