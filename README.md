# Terminal enclosure: build notes

An original retro-industrial terminal case for a mini-ITX board, a 15.6" laptop panel and a compact keyboard (293 × 107 mm by default). Overall size is about 476 × 376 × 390 mm, including the plinth and the screen hood. It prints as 15 shell pieces plus 16 clamp tabs, 2 trim strips, a two-piece screen gasket, 2 visor inserts and a 3-piece webcam, and every piece fits a 256 mm bed. The left plate quarters are 248 mm wide because of the plinth, so check your slicer's usable bed area.

## Measure before printing
These defaults are typical values. Check them against your own parts and adjust the variables at the top of `terminal.scad`:
- **Panel**: `panel_w/h/t`, `active_w/h`, and `active_bottom_margin` (the border below the active area, where the FPC sits). Check the datasheet for your panel's model number.
- **Board**: `itx_holes`, `io_x_off` and `io_z_drop`. Test-fit the I/O shield against `base_RR` before printing the rest.
- **Keyboard**: set `kb_w` and `kb_d` to the keyboard's footprint, and `kb_t0` / `kb_t1` to the height of its body below the keycaps at the front and back, with any feet removed (default 15 mm at both). The well is the footprint plus 2 mm all round, open to the bottom plate. Sloping ribs on the plate tilt the keyboard to the deck's 4.8° wedge (set by `deck_h0`, the deck height at the front), with the top of its body flush with the deck. Cable notches in the well's back wall are listed in `kb_notches`; keep the ribs (`kb_rib_x`) clear of them.
- **Case badge**: the recess on the front ramp is 18.5 mm square and 1.2 mm deep. Set `badge_s` and `badge_depth` to suit your badge.
- **Webcam**: the tube has a 19 mm bore, 57 mm deep, and suits a laptop-style strip camera module. Set `cam_d`, `cam_bore` and `cam_len` for your module. The lens hole sits at the middle of the tube.
- **Panel controller board**: there are no mounts for it. Fix it to the pod's inside back wall with VHB tape or standoffs, and route the cable down through the slot to the base.

## Pieces
| Piece | Qty | Notes |
|---|---|---|
| base_FL/FR/RL/RR | 4 | Printed upside down (top face on the bed). The front pair export tilted so the sloping deck lies flat. Support the I/O cutout. |
| plate_FL/FR/RL/RR | 4 | Flat, with standoffs, keyboard ribs and the plinth lip facing up. Dark filament suits the plinth look. |
| pod_BL/BR/TL/TR | 4 | Lying on the outer side face. Use tree supports for the internal ribs and bosses. |
| hatch_L/R | 2 | Flat. |
| clamp_tab | 16 | Flat. 8 hold the panel and 8 hold the side speakers. |
| trim_strip | 2 | Flat, in dark filament. Glue into the channels down the outside of the hood cheeks, after joining the pod halves. |
| gasket_L/R | 2 | Flat as exported, in dark filament. Glue the halves into the recess round the screen. |
| visor | 2 | Flat, in translucent green PETG. Drops into the rebates in the hood roof from above. |
| cam_body | 1 | Standing on its closed end. |
| cam_cap | 1 | Flat, in dark filament. Press-fits into the open end of the tube. |
| cam_cradle | 1 | Standing on its bottom. Glue its back to the sill, over the cable hole. |
| island_L | 1 | Flat as exported. Glue into the shallow pocket on the deck left of the keyboard; the holes line up with the deck's. Dark filament makes a good contrast. |

Suggested settings: PETG or ASA (the PSU brick sits outside, but the case runs warm), 4 walls, 15% infill.

## Hardware
- About 48 M3 heat-set inserts: 16 in the shell, 4 for board standoffs, 4 for pod mounts, 8 for panel clamps, 8 for the hatch, 8 for the side speakers.
- 16 × M3×10 countersunk screws (plate to shell), 4 × M3×10 (base top to pod), 24 × M3×8 (clamps and hatch), 4 × M3×6 (board).
- 1.75 mm filament offcuts, about 16 mm long, for seam pins. Plus CA glue or solvent.
- picoPSU (24-pin) and a 12 V brick. The 11 mm hole in the rear takes a panel-mount DC jack.
- 16 mm momentary switch, 5 mm LEDs (4 holes in the base), 3 mm LEDs (4 in the bezel).
- 2 × 7 mm panel-mount momentary buttons for the keyboard deck (top right), and a 3 mm red LED for the card-slot indicator. The deck is 4 mm thick under these buttons and the power switch (the recess is backed from below).
- 4 × 12 mm tactile switches with square caps for the bezel buttons. There are no mounts; glue them to a strip of perfboard behind the openings.
- Optional speakers: about 20 mm behind the front grille (fix it with VHB), and up to about 44 mm round behind each side grille. Each side speaker is held by 4 clamp tabs screwed to bosses around its grille, with each tab's foot pressing on the speaker's rim. The bosses suit a rim plus foam about 3 mm thick; change `spk_rim` to suit yours.
- 4 × 12 mm rubber feet, plus thin foam pads for between the clamp tabs and the panel.
- An eDP controller board to suit your panel.
- A small USB camera module for the webcam (see *Measure before printing*).

## Exporting the parts
`./export.sh` writes every part to `stl/`, one file per part, already in print orientation, and prints how many of each to make. `./export.sh 3mf` writes 3MF files to `3mf/` instead. It looks for `openscad` on your PATH, then falls back to the macOS app; set `OPENSCAD=/path/to/openscad` to use another build (it needs the manifold backend). To export one part: `openscad --backend=manifold -D 'part="pod_TL"' -o pod_TL.stl terminal.scad`.

In Bambu Studio, import each file and don't rotate it; the model already lays it out for printing. The hatch halves (254 mm) and left plate quarters (248 mm) come close to the P2S's 256 mm bed, so centre them and turn off the skirt or brim if the slicer complains. Print the clamp tabs, visors and trim strips as several copies on one plate.

## Rendering
`openscad --backend=manifold --render -D solid_ghosts=true -o render.png terminal.scad`. Without `--render`, the PNG export uses preview mode, which gives up on this model and draws only the dummy parts. `solid_ghosts` draws the panel, board and keyboard dummies as solid colour, so they show up in the render.

## Assembly order
1. Press inserts into all bosses and standoffs.
2. Pin and glue the base quarters, then the plate quarters. Screw the plate on to check alignment.
3. Pin and glue the pod's bottom pair and top pair. Fit the panel and clamps, then join the halves. Glue in the trim strips, gasket halves and visor inserts.
4. Screw the pod to the base from inside, through the top, before closing the plate.
5. Fit the board and I/O shield, then the plate, then the hatch.
6. Feed the camera cable through the cradle and the sill hole, seat the camera in the tube, fit the cap, then glue the tube into the cradle at the tilt you want.
