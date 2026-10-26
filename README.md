# Terminal enclosure: build notes

An original retro-industrial terminal case for a mini-ITX board, a 15.6" laptop panel and a home-made keyboard. Overall size is about 467 × 367 × 390 mm, including the plinth lip and the screen hood. It prints as 15 pieces plus 16 clamp tabs and 2 trim strips, and every piece fits a 256 mm bed. The front-left and rear-left plate quarters are 253.5 mm wide because of the plinth lip, so check your slicer's usable bed area.

## Measure before printing
These defaults are typical values. Check them against your own parts and adjust the variables at the top of `terminal.scad`:
- **Panel**: `panel_w/h/t`, `active_w/h`, and `active_bottom_margin` (the border below the active area, where the FPC sits). Check the datasheet for your panel's model number.
- **Board**: `itx_holes`, `io_x_off` and `io_z_drop`. Test-fit the I/O shield against `base_RR` before printing the rest.
- **Keyboard well**: 380 × 140 mm, open to the bottom plate. Raise the keyboard on spacers if it sits too low.
- **Case badge**: the recess on the front ramp is 18.5 mm square and 1.2 mm deep. Set `badge_s` and `badge_depth` to suit your badge.
- **Panel controller board**: there are no mounts for it. Fix it to the pod's inside back wall with VHB tape or standoffs, and route the cable down through the slot to the base.

## Pieces
| Piece | Qty | Notes |
|---|---|---|
| base_FL/FR/RL/RR | 4 | Printed upside down (top face on the bed). Support the I/O cutout. |
| plate_FL/FR/RL/RR | 4 | Flat, with standoffs and the plinth lip facing up. Dark filament suits the plinth look. |
| pod_BL/BR/TL/TR | 4 | Lying on the outer side face. Use tree supports for the internal ribs and bosses. |
| hatch_L/R | 2 | Flat. |
| clamp_tab | 16 | Flat. 8 hold the panel and 8 hold the side speakers. |
| trim_strip | 2 | Flat, in dark filament. Glue into the channels beside the screen. |

Suggested settings: PETG or ASA (the PSU brick sits outside, but the case runs warm), 4 walls, 15% infill.

## Hardware
- About 48 M3 heat-set inserts: 16 in the shell, 4 for board standoffs, 4 for pod mounts, 8 for panel clamps, 8 for the hatch, 8 for the side speakers.
- 16 × M3×10 countersunk screws (plate to shell), 4 × M3×10 (base top to pod), 24 × M3×8 (clamps and hatch), 4 × M3×6 (board).
- 1.75 mm filament offcuts, about 16 mm long, for seam pins. Plus CA glue or solvent.
- picoPSU (24-pin) and a 12 V brick. The 11 mm hole in the rear takes a panel-mount DC jack.
- 16 mm momentary switch, 5 mm LEDs (4 holes in the base), 3 mm LEDs (4 in the bezel).
- 2 × 7 mm panel-mount momentary buttons for the keyboard deck (top right), and a 3 mm red LED for the card-slot indicator.
- 4 × 12 mm tactile switches with square caps for the bezel buttons. There are no mounts; glue them to a strip of perfboard behind the openings.
- Optional speakers: about 28 mm behind the front grille (fix it with VHB), and up to about 44 mm round behind each side grille. Each side speaker is held by 4 clamp tabs screwed to bosses around its grille, with each tab's foot pressing on the speaker's rim. The bosses suit a rim plus foam about 3 mm thick; change `spk_rim` to suit yours.
- 4 × 12 mm rubber feet, plus thin foam pads for between the clamp tabs and the panel.
- An eDP controller board to suit your panel.

## Rendering
`openscad --backend=manifold --render -D solid_ghosts=true -o render.png terminal.scad`. Without `--render`, the PNG export uses preview mode, which gives up on this model and draws only the dummy parts. `solid_ghosts` draws the panel, board and keyboard dummies as solid colour, so they show up in the render.

## Assembly order
1. Press inserts into all bosses and standoffs.
2. Pin and glue the base quarters, then the plate quarters. Screw the plate on to check alignment.
3. Pin and glue the pod's bottom pair and top pair. Fit the panel and clamps, then join the halves.
4. Screw the pod to the base from inside, through the top, before closing the plate.
5. Fit the board and I/O shield, then the plate, then the hatch.
