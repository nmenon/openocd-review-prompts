# TI-Authored OpenOCD Patch Registry

Persistent index of OpenOCD Gerrit changes authored by @ti.com contributors.
Used to drive iterative rule enrichment from real reviewer feedback.

## Files

| File | Contents |
|------|----------|
| `changeids.md` | Canonical list of all known TI change IDs with subject + status |
| `harvest-YYYY-MM-DD.md` | Full harvest run with all inline review comments |
| `rules-derived.md` | Rules and patterns extracted from review comments |

## Coverage

Sampling scans (step 5/10/20) will miss some patches. When a TI contributor
is identified, also check ±50 surrounding IDs for related patches in the
same series.

## Re-running a harvest

To fetch full comment detail for a specific change ID:
```
/openocd-review <change_id> skip-build
```

To bulk-fetch comments for all known IDs, loop through `changeids.md`.

## Known TI Contributors

| Name | Email | Focus area |
|------|-------|------------|
| Nishanth Menon | nmenon@ti.com | AM-series targets, MSPM0 flash |
| (others TBD from harvest) | | |
