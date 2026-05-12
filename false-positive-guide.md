# OpenOCD Review — False Positive Verification Guide

Apply EVERY gate below to EVERY finding before including it in the report.
A finding that fails any gate must be dropped or reformulated.

---

## General Gates

### G1: Is the code actually in the diff?

The flagged code must be on a `+` line (or a new block of `+` lines) in the diff.
Do NOT flag code on context lines (lines starting with ` `).
Pre-existing issues outside the touched lines are not in scope.

**Verification**: Confirm the exact line is a `+` line in the patchset diff.

### G2: Is the code path reachable?

Verify the changed code is actually compiled and reachable:
- Is the file listed in `src/flash/nor/Makefile.am` (or similar)?
- Is it guarded by `#if defined(HAVE_...)` or `#ifdef CONFIG_...`?
- Does `configure.ac` contain the required `AC_DEFINE` or `--enable-` flag?
- Is the driver listed in `src/jtag/drivers/drivers.c` or `src/flash/nor/drivers.c`?

**Verification**: Read `Makefile.am` and `configure.ac` for the relevant path.

### G3: Was the full function read?

Never report a bug based solely on the diff hunk. Read the complete function
(all the way to `}` at the function's top level) before reporting.

A "null pointer dereference" might be safe because the null was checked
5 lines above the hunk.
A "resource leak" might be handled by a caller or destructor not visible in the diff.

**Verification**: Read the full function. State: "I read the full function at <path>."

### G4: Is this genuinely new vs. pre-existing?

If the same pattern exists in other functions in the same file that were NOT
touched by this patch, it is pre-existing. Flag it only if the patch actively
makes it worse or if it is security-critical.

**Verification**: Search for the same pattern in the same file.

### G5: Does the rule have documented exceptions?

Check the rule text in `openocd-review-plan.md` for exception clauses.
Common exceptions:
- `WS-6` (SPDX `//` style): `//` is OK for SPDX-License-Identifier lines
- `CO-1` (`//` comments): `//` is acceptable in Tcl scripts and third-party code
- `TY-2` (endianness): Explicitly little-endian architectures (RP2040, x86 targets) connecting to little-endian host may have justified direct pointer access with documentation
- `IN-1` (config.h first): Third-party or jimtcl code may not include config.h

**Verification**: Re-read the rule text for the exact exception condition.

---

## Rule-Specific Verification Notes

### ER-1 / ER-3: Return value checking

Before flagging "unchecked return value from `target_read_u32()`":
1. Read the entire function — is there a `goto cleanup` that handles the error implicitly?
2. Is this inside a `keep_alive()` loop where the error is tolerated (polling)?
3. Is the failure mode documented (e.g., "this always succeeds on the tested hardware")?

Still flag if: The return value is silently discarded and the program state is wrong on failure.

### FLS-NOR-5: Workarea management

Before flagging "workarea not freed on error path":
1. Read ALL return paths from the function (including via `goto` and nested returns)
2. Check if a wrapper function above handles cleanup
3. Verify `target_free_working_area()` is really missing on that specific path

### TAP-4: DR scan data alignment

Before flagging "byte order issue in scan field":
1. Check which architecture the driver targets — some are inherently big-endian
2. Verify whether the scan field is `in_value` (host reads target) or `out_value` (host writes target)
3. Read the ADIv5/JTAG spec comment in the file if present

### CS-1: Integer overflow in address arithmetic

Before flagging "potential overflow in address arithmetic":
1. Check if the operands are already bounded by earlier range checks
2. Verify the types involved — `uint32_t + uint32_t` on a 64-bit host won't overflow in the expression but may truncate on assignment

### CS-4: JTAG scan field lifetime

Before flagging "scan field buffer may go out of scope":
1. Confirm the buffer is actually stack-allocated (not `malloc`'d)
2. Verify `jtag_execute_queue()` is NOT called before the scope ends
3. If the buffer is declared at file scope or as `static`, this is not a bug

### NM-5: Struct typedef suffix

OpenOCD code does **not** add `_t` to struct typedefs by convention.
However, do NOT retroactively flag existing typedefs that predate this patch
if the patch does not introduce new ones.

### CM-3: Body missing for non-trivial change

A commit with one-liner body is acceptable if:
- The subject line itself is fully self-explanatory (e.g., `flash/nor/stm32g0: add device ID 0x4660`)
- The change is mechanical (whitespace, rename, format fix)

Do not flag one-liners for cosmetic or trivially obvious changes.

### TCL-2: Transport selection

Only flag if the `.cfg` file is intended for direct use as a target config
(not as an internal helper sourced by another config).
Board configs and helper scripts may not need their own transport selection.

### BV-4: New compiler warnings

Only flag warnings that are genuinely NEW — introduced by the patch.
Do not flag pre-existing warnings in files that the patch touches but doesn't change.

---

## Cross-Check Pattern

For every non-trivial finding:

1. **Read full function** (G3) — don't flag from a fragment
2. **Trace one caller up** — does the caller guarantee the condition the finding assumes is violated?
3. **Check prior patchsets** — was this already flagged and addressed (or intentionally kept)?
4. **Verify with a concrete manifestation path** — can you write out the exact sequence of calls that triggers the bug?

A finding that can't be demonstrated with a concrete call sequence is likely a false positive.

---

## Precedence of Evidence

1. **Code in the diff (`+` lines)** — strongest evidence
2. **Full function context** — strong evidence
3. **Caller context** — supporting evidence
4. **Pattern analysis** — weakest; always verify with #1 or #2 before reporting

Never report a finding based solely on pattern matching without verifying in context.
