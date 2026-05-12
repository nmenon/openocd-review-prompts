# TI-Authored OpenOCD Change ID Registry

Last updated: 2026-05-12 (initial harvest pending)
Coverage: ~3000–8500 sampled every 5/10/20 IDs

## Format
```
NNNN | SUBJECT | STATUS | AUTHOR | FILES
```

## Known Changes (pre-harvest)

| ID | Subject | Status | Author | Area |
|----|---------|--------|--------|------|
| 8384 | flash/nor/mspm0: Add TI MSPM0xxxx support | MERGED | nmenon@ti.com | flash/nor |
| 8220 | flash/nor/mspm0: Add TI MSPM0xxxx support | ABANDONED | (non-TI, context: nmenon asked submitter to abandon) | flash/nor |

## From Harvest Runs

| ID | Subject | Status | Author | Area | Harvest date |
|----|---------|--------|--------|------|-------------|
| 7090 | tcl/target/ti_k3: Handle swd vs jtag | MERGED | nm@ti.com | tcl/target | 2026-05-12 |
| 7950 | tcl/target/ti_k3: Add AM273 SoC | MERGED | nm@ti.com | tcl/target | 2026-05-12 |
| 8050 | tcl/board: Add TI j722sevm config | MERGED | nm@ti.com | tcl/board | 2026-05-12 |
| 6615 | tcl/target/ti_k3: Add gdb-attach event hook for m3 and m4 | MERGED | nm@ti.com | tcl/target | 2026-05-12 |
| 5960 | tcl: discover | ABANDONED | nm@ti.com | tcl | 2026-05-12 |

## Coverage Notes

- 8000–8490 (every 5th, 99 IDs): 1 TI change (8050)
- 7000–7990 (every 10th, ~59 IDs): 2 TI changes (7090, 7950)
- 5500–6990 (every 10th, ~150 IDs): 1 TI change (6615, 5960)
- 3000–5490 (every 20th, ~125 IDs): 0 found; note: MSP432 work likely ~5390–5400 (parent commit `82a5c55` referenced by change 5400)

## Dense-scan candidates (TI clusters)

- ~5390–5400: MSP432 flash support (parent commit `82a5c55dc357` "flash/nor: update support for TI MSP432 devices")
- ~7080–7100: K3 target work (7090 found; check ±20 IDs for related series)

## Known TI Contributors (confirmed)

| Name | Email | Confirmed changes |
|------|-------|-------------------|
| Nishanth Menon | nm@ti.com | 7090, 7950, 8050, 6615, 5960 |
| Bryan Brattlof | hello@bryanbrattlof.com | Reviewer on 7090, 8050 (TI status in Gerrit profile) |
