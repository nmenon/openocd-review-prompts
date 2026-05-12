# Maintainer Review Comment Harvest

Review feedback from the four primary OpenOCD reviewers, extracted from
Gerrit inline comments. Used to derive and validate review rules.

## Target Reviewers

| Reviewer | Email | Review Style | Focus Areas |
|----------|-------|-------------|-------------|
| Antonio Borneo | borneo.antonio@gmail.com | Architecture and protocol correctness. Detailed multi-round reviews. Often cherry-picks and submits final patchset. | TCL/server architecture, protocol compliance, driver abstractions |
| Tomas Vanek | vanekt@fbl.cz | Primary maintainer. Pragmatic style guide interpretation. Submits self-reviewed patches. | All areas, RP2xxx, flash, targets |
| Marc Schink | zapb | Strict coding style. Type correctness. | Coding style, type safety, command argument handling |
| Paul Fertser | fercerpav@gmail.com | Protocol accuracy. JTAG/SWD correctness. | JTAG/SWD/TAP, target support, protocol |

## Files

| File | Contents |
|------|----------|
| `harvest-2026-05-12.md` | Combined inline comments from all three range scans |
| `rules-by-reviewer.md` | Patterns grouped by reviewer, ready for rule extraction |
| `change-index.md` | Index of all changes that received maintainer inline comments |

## Coverage (2-year window, ~6500–8500)

- Range 8100–8490: every 3rd ID (~130 IDs)
- Range 7500–8100: every 3rd ID (~200 IDs)
- Range 6500–7500: every 5th ID (~200 IDs)
