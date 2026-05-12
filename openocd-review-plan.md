# OpenOCD Review Plan — Rules Catalog

## Section 0: Subsystem Trigger Table

Scan the changed file paths and function names against this table.
Load the matching sections immediately before analysing.

| Subsystem | Path/Function Triggers | Rule Sections |
|-----------|----------------------|---------------|
| Flash NOR | `src/flash/nor/`, `flash_bank`, `flash_sector` | FLS-NOR-* |
| Flash NAND | `src/flash/nand/` | FLS-NAND-* |
| Target | `src/target/`, `target_type`, `cortex_`, `riscv_`, `mips_` | TGT-* |
| JTAG/TAP | `src/jtag/`, `jtag_`, `tap_`, `scan_`, `dr_scan`, `ir_scan` | TAP-* |
| Interface/Adapter | `src/jtag/drivers/`, `adapter_driver`, `libusb` | IFD-* |
| Tcl Scripts | `tcl/`, `.cfg`, `proc `, `target create`, `flash bank` | TCL-* |
| GDB Server | `src/server/gdb_server`, `gdb_`, `target_notif_`, `stop_reply` | SRV-GDB-* |
| Telnet/Tcl Server | `src/server/telnet_server`, `src/server/tcl_server` | SRV-TCL-* |
| RTOS | `src/rtos/`, `rtos_`, `threadid_t` | RTO-* |
| Helper | `src/helper/`, `command_`, `LOG_`, `Jim_` | HP-* |
| Transport | `src/transport/`, `transport_register`, `swd_` | TAP-SWD-* |

---

## CM — Commit Message Rules

### CM-1 [ERROR] Subject format
Subject line must follow `<area>: <description>`.

- `<area>` should identify the main subsystem touched. Examples:
  - `flash/nor/stm32f1x:`
  - `target/cortex_m:`
  - `jtag/drivers/ftdi:`
  - `tcl/target/rp2040:`
  - `doc:`, `build:`, `helper:`
- Description should be lowercase, imperative, ≤ 72 chars total for subject
- No full stop at end of subject

**Good**: `flash/nor/stm32f1x: add STM32G0 support`
**Bad**: `STM32 Flash: Added support for new device.`

### CM-1a [ERROR] Subject must be a single line — and must follow `subsystem: description`
The commit message subject must be a single line in the form `subsystem: description`.
Informal titles like "Initial cut at support for X" are rejected.

```
# WRONG:
Initial cut at support for LPC55S16.

# CORRECT:
tcl/target: add support for LPC55S16
```

*Source: Change 6800 — Antonio Borneo: "Please change the first line with something like: tcl/target: add support for LPC55S16"*

### CM-1b [ERROR] Subject must be a single line
The commit message subject must be exactly one line. A two-line subject
(e.g., a title followed immediately by a subtitle without a blank line)
is wrong. Move the second line into the body, separated by a blank line.

```
# WRONG:
tcl/board: Add support for Terasic DE1-SoC
A complete BSP for the DE1-SoC board

# CORRECT:
tcl/board: Add support for Terasic DE1-SoC

A complete BSP for the DE1-SoC board including...
```

*Source: Change 8175 — Antonio Borneo*

### CM-2 [ERROR] Signed-off-by missing
Every patch must have `Signed-off-by: Name <email>` trailer.

### CM-3 [WARNING] Body missing for non-trivial change
Non-trivial patches must have a body explaining:
- What bug is being fixed (or what feature is added)
- Why this approach was chosen
- How to test the change

One-liner commits are acceptable only for trivial changes (typo fixes, etc.).

### CM-4 [WARNING] Line length in body
Body lines should be ≤ 75 characters. URLs may be on their own line
preceded by `Link:`.

### CM-5 [WARNING] GPL copyright update for non-trivial changes
HACKING says: "Add yourself to the GPL copyright for non-trivial changes."

### CM-6 [WARNING] Bug report references
Bug fix commits should reference the original report:
- `Reported-by: Name <email>`
- `BugLink: https://sourceforge.net/p/openocd/tickets/NNN/`
- `Fixes: 123456789abc ("subject of broken commit")`

### CM-7 [WARNING] Documentation reference for new commands
When a new user-visible command is added, the commit message should note
that `doc/openocd.texi` was updated in the same commit (or explain why not).

### CM-8 [INFO] Checkpatch-ignore used
`Checkpatch-ignore:` in commit message requires justification that the
suppressed error is genuinely a false positive.

---

## WS — Whitespace and Formatting Rules

### WS-1 [ERROR] Tab indentation
OpenOCD uses tabs for indentation (`--tab-size=4` in checkpatch.conf).
Spaces for indentation are wrong.

### WS-2 [ERROR] Trailing whitespace
No trailing spaces or tabs on any line.

### WS-3 [ERROR] Line length
Maximum line length is 120 characters (from `.checkpatch.conf`).
Comment lines wrapping at 75–80 chars is preferred but not enforced.

### WS-4 [ERROR] Unix line endings
Files must use LF (Unix) line endings, not CRLF.

### WS-5 [WARNING] Blank lines at end of file
No trailing blank lines at end of file.

### WS-6 [ERROR] SPDX on new files
New source files require an SPDX identifier as the first line:

- C/C++ files: `// SPDX-License-Identifier: GPL-2.0-or-later`
- Tcl/cfg files: `# SPDX-License-Identifier: GPL-2.0-or-later`

Note: `//` for SPDX in C files is an explicit checkpatch exception in `.checkpatch.conf`.
Tcl configs are also required to carry the SPDX header — this is enforced on new `.cfg` files.

*Source: Change 6800 — Antonio Borneo: "Please add as first line: # SPDX-License-Identifier: GPL-2.0-or-later"*

### WS-7 [WARNING] Copyright statement format
Non-trivial contributions should add:
```c
/* Copyright (C) <year> <name> <email> */
```

### WS-8 [INFO] Blank line between function definitions
Single blank line between top-level function definitions.

---

## CO — Comments and Documentation Rules

### CO-1 [WARNING] C-style comments only (inside code)
Inside function bodies, use `/* ... */` for block comments.
`//` comments are not part of C89 and are stylistically avoided in
non-SPDX uses in OpenOCD's C source.
Exception: SPDX lines and jimtcl/third-party code.

### CO-2 [WARNING] No obvious comments
Comments should explain *why*, not *what*. Avoid:
```c
/* Set the timeout to 5 */
timeout = 5;
```

### CO-3 [WARNING] New exported functions need documentation comment
New `extern` functions in headers should have a brief Doxygen comment
(or at minimum an explanation of parameters and return value).

### CO-4 [INFO] Explain non-obvious hardware behaviour
When writing code that works around chip errata or non-obvious hardware
behaviour, add a comment citing the reference manual section or errata ID.

### CO-5 [WARNING] Commit message claims verified
If the commit message says "fix XYZ", verify the patch actually fixes XYZ.
If the message says "improves performance", verify the change actually does so.

---

## HG — Header Guard Rules

### HG-1 [ERROR] Header guard present
New `.h` files must have a header guard:
```c
#ifndef OPENOCD_<SUBSYSTEM>_<FILE>_H
#define OPENOCD_<SUBSYSTEM>_<FILE>_H
...
#endif /* OPENOCD_<SUBSYSTEM>_<FILE>_H */
```

### HG-2 [WARNING] Guard naming convention
Guard name must match file path:
`src/flash/nor/foo.h` → `OPENOCD_FLASH_NOR_FOO_H`

### HG-3 [INFO] End-of-header comment
`#endif` at end of header should have a comment repeating the guard name.

---

## IN — Include Ordering Rules

### IN-1 [WARNING] Mandatory first include in implementation files
Every `.c` file must include `<config.h>` first:
```c
#ifdef HAVE_CONFIG_H
#include "config.h"
#endif
```

### IN-2 [WARNING] Include grouping
Includes should be grouped:
1. `config.h` (if applicable)
2. System/standard library headers (`<stdint.h>`, `<string.h>`)
3. Project headers (`"target/target.h"`, `"flash/nor/core.h"`)
4. Local headers (same directory, `"foo.h"`)

Blank line between groups.

### IN-3 [WARNING] No unused includes
Do not add `#include` that is not needed by the file.

### IN-4 [INFO] Forward declarations vs includes
Use forward struct declarations in headers where possible to reduce
compilation dependencies.

---

## NM — Naming Conventions

### NM-1 [WARNING] Function names: snake_case
All function names should use `snake_case`, not `camelCase` or `MixedCase`.

### NM-2 [WARNING] Driver function table naming
Driver implementation functions should be named `<driver_name>_<operation>`:
```c
static int stm32f1x_probe(struct flash_bank *bank);
static int stm32f1x_erase(struct flash_bank *bank, unsigned int first, unsigned int last);
```

### NM-3 [WARNING] Static helper prefix
File-local (static) helper functions should not have the driver prefix unless
they'd conflict with other static functions. The `static` qualifier already
provides the namespace.

### NM-4 [ERROR] Constants: UPPER_SNAKE_CASE
Constants defined with `#define` or `enum` values should be UPPER_SNAKE_CASE.

### NM-5 [WARNING] Structs and typedefs
Do not add `_t` suffix to struct types (OpenOCD style uses `struct foo`).
Opaque types in headers may use typedefs if necessary, without `_t`.

### NM-6 [WARNING] Don't shadow external names
Local variable names must not shadow global function names or type names from
OpenOCD infrastructure (e.g., don't name a variable `target`, `bank`, `tap`).

### NM-7 [INFO] Tcl proc naming in scripts
In Tcl target/board configs, procs should be named with the chip name prefix:
`proc rp2040_something { }` not `proc something { }`.

---

## TY — Types and Casting Rules

### TY-1 [WARNING] Use uint32_t / int32_t for register values
Use fixed-width types from `<stdint.h>` for hardware register values, not
`int`, `long`, or `unsigned`. This ensures endianness-correctness.

### TY-2 [ERROR] Endianness safety
OpenOCD must run on both little-endian and big-endian hosts.
- Use `le_to_h_u32(buf)` / `h_u32_to_le(buf, val)` for reading/writing
  target memory in host-endian format
- Use `be_to_h_u32(buf)` / `h_u32_to_be(buf, val)` for big-endian targets
- Never cast a `uint8_t *` directly to `uint32_t *` and dereference

### TY-3 [WARNING] Use bool for boolean values
Use `bool`, `true`, `false` (from `<stdbool.h>`) rather than `int 0/1`.

### TY-4 [WARNING] Avoid int for error returns
Use `int` only for error codes (ERROR_OK, ERROR_FAIL, etc.). Do not mix
error codes with pointer-sized types or use `int` for hardware register values.

### TY-5 [WARNING] Enum for state machines
Use `enum` rather than `#define` integer constants for target states,
flash bank states, JTAG states, etc.

### TY-6 [INFO] No implicit function declarations
All functions must be declared before use. Do not rely on implicit `int`
return types. Use `static` for file-local functions.

### TY-7 [INFO] Explicit cast before narrowing
When narrowing a value (e.g., `uint64_t` to `uint32_t`), use an explicit cast
and check for truncation where the high bits could be non-zero.

---

## ER — Error Handling Rules

### ER-1 [ERROR] Check return values of target memory access
Always check the return value of:
- `target_read_u32()`, `target_write_u32()`
- `target_read_memory()`, `target_write_memory()`
- `target_read_buffer()`, `target_write_buffer()`

### ER-2 [ERROR] Propagate errors with ERROR_OK/ERROR_FAIL
Use `if (retval != ERROR_OK) return retval;` (or `goto cleanup`) rather
than ignoring errors and continuing.

### ER-3 [ERROR] Flash operation error handling
Flash erase, write, and protect operations must:
- Check all sub-operation return values
- Restore the target to a known state on failure where possible
- Not leave the flash in a partially programmed state without reporting

### ER-4 [WARNING] LOG_ERROR on unexpected failures
Use `LOG_ERROR("...")` when a hardware operation fails unexpectedly.
Reserve `LOG_DEBUG` for expected/informational paths.

### ER-5 [WARNING] NULL pointer checks before dereference
Pointers returned from `get_flash_bank_by_addr()`, `get_target_by_num()`,
and similar lookup functions may be NULL and must be checked.

### ER-6 [WARNING] Cleanup on early return
Functions that allocate resources (malloc, workarea, etc.) must free them
on all error return paths. Use `goto cleanup` patterns for clarity.

### ER-7 [WARNING] Error messages include context
`LOG_ERROR("operation failed")` is insufficient. Include the target name,
address, or register value: `LOG_ERROR("target %s: read at 0x%08" PRIx32 " failed", target_name(target), addr)`.

### ER-8 [INFO] Don't assert on user-visible input
`assert()` is for programming errors (invariants). Do not use `assert()`
to validate user input from commands or config files.

---

## CMD — Command Registration Rules

### CMD-1 [WARNING] COMMAND_HANDLER signature
Use the standard `COMMAND_HANDLER(foo_bar_command)` macro, not a hand-rolled
function signature.

### CMD-2 [ERROR] COMMAND_PARSE_NUMBER bounds
When parsing numeric arguments from commands, always check they are within
valid range:
```c
COMMAND_PARSE_NUMBER(uint, CMD_ARGV[0], value);
if (value > MAX_VALUE) {
    command_print(CMD, "value out of range [0..%u]", MAX_VALUE);
    return ERROR_COMMAND_ARGUMENT_INVALID;
}
```

### CMD-3 [WARNING] Command documentation in .texi
New user-visible commands must have entries in `doc/openocd.texi` added in
the same commit as the code. The documentation must describe parameters,
return values, and side effects.

### CMD-4 [WARNING] Command help strings
The `COMMAND_REGISTRATION` entry must include a `help` string and `usage`
string. Neither should be empty.

### CMD-5 [WARNING] Avoid duplicate command names
Check that the new command name doesn't conflict with existing commands
in the same command context.

### CMD-6 [INFO] Command cleanup
Commands that allocate state must register a cleanup function or document
what cleans up after them.

---

## FLS-NOR — Flash NOR Driver Rules

### FLS-NOR-1 [ERROR] Implement all required flash_driver callbacks
A NOR flash driver must implement:
- `.probe` — detect the device, populate `bank->sectors`, `bank->size`
- `.erase` — erase sectors by range
- `.write` — write data
- `.info` — print driver info
- `.read` (optional but preferred over default)

Any unimplemented required callback must be documented.

### FLS-NOR-2 [ERROR] Probe must initialise bank->sectors
`flash_bank->sectors` must be allocated and populated in `.probe`.
Erase and write operations may crash if sectors are uninitialised.

### FLS-NOR-3 [ERROR] Sector erase protection
Before erasing, the driver must:
1. Check if the sector is protected with `bank->sectors[i].is_protected`
2. Unlock (if possible) or return `ERROR_FLASH_OPERATION_FAILED`
3. Verify erase completion (blank check or status register poll)

### FLS-NOR-4 [ERROR] Write algorithm alignment
Flash write algorithms must respect minimum write granularity (byte, word,
page). Writing fewer bytes than the minimum write unit requires special
handling.

### FLS-NOR-5 [ERROR] Workarea management
Flash algorithms using a workarea must:
- Request the workarea with `target_alloc_working_area()`
- Free it with `target_free_working_area()` in all exit paths
- Check the workarea was granted (it may not be if RAM is limited)

### FLS-NOR-6 [WARNING] Flash status register polling
After an erase or write, poll the status register until the operation
completes or times out. Do not assume completion after a fixed delay.

### FLS-NOR-7 [WARNING] Device ID validation in probe
`.probe` must compare the read device ID against the expected values and
return `ERROR_FAIL` if unrecognised.

### FLS-NOR-8 [WARNING] JEDEC/CFI infrastructure reuse
For CFI-compliant devices, use the existing `src/flash/nor/cfi.c`
infrastructure rather than re-implementing CFI detection.
For SFDP-based devices, use `src/flash/nor/sfdp.c`.

### FLS-NOR-9 [WARNING] `bank->base` usage
Always use `bank->base` as the base address for calculating target addresses.
Do not hardcode flash base addresses.

### FLS-NOR-10 [WARNING] Sector count vs size mismatch
Verify `bank->num_sectors * sector_size == bank->size` after probe.

### FLS-NOR-11 [INFO] Flash bank naming in Makefile.am
New flash drivers must be added to `src/flash/nor/Makefile.am` under
`noinst_LTLIBRARIES` and listed in `drivers.c`.

---

## FLS-NAND — Flash NAND Driver Rules

### FLS-NAND-1 [ERROR] Bad-block table management
NAND drivers must maintain or respect the bad-block table. Writing to
a factory-marked bad block corrupts data.

### FLS-NAND-2 [WARNING] ECC handling
Document whether the driver implements ECC or relies on the host/device.
NAND writes without ECC risk silent data corruption.

### FLS-NAND-3 [WARNING] Page/block alignment
NAND writes must be page-aligned; erases must be block-aligned.
Partial writes require read-modify-write handling.

---

## TGT — Target Support Rules

### TGT-1 [ERROR] target_type callbacks required
New target types must implement all members of `struct target_type`
marked as required. Optional callbacks may be NULL but must be documented.

### TGT-2 [ERROR] Halt before memory access in ARM/RISC-V/MIPS
Before accessing target memory with `target_read_memory()`, the target
must be halted or in debug state. Operations on running targets may corrupt
state.

### TGT-3 [ERROR] Register access via target API
Do not access target registers by constructing raw DAP/JTAG transactions
when higher-level APIs exist (e.g., `target_read_u32()`,
`register_get_by_name()`).

### TGT-4 [ERROR] Breakpoint and watchpoint limits
Before setting a hardware breakpoint/watchpoint, check
`target->breakpoints` and `target->watchpoints` counts against
the target's reported hardware limits.

### TGT-5 [WARNING] Reset handling correctness
Target reset implementations must handle all reset types:
`RESET_RUN`, `RESET_HALT`, `RESET_INIT`. Test that the target can
be reset and re-examined reliably.

### TGT-6 [WARNING] examine function side effects
`target->type->examine()` may be called multiple times. It must be
idempotent or track whether examination has already succeeded.

### TGT-7 [WARNING] `target_name(target)` for log messages
Use `target_name(target)` in log messages, not hardcoded strings.

### TGT-8 [WARNING] Semihosting handled via common API
New semihosting support must use the common semihosting infrastructure
in `src/target/semihosting_common.c` rather than implementing it from scratch.

### TGT-9 [INFO] New target documentation
New target types should have documentation in `doc/openocd.texi` describing:
- Supported device families
- JTAG/SWD specifics
- Any known limitations

### TGT-10 [INFO] Architecture-specific DBGBASE
For Cortex-based targets, `DBGBASE` should be detected dynamically via
the ROM table rather than hardcoded where possible.

---

## TAP — JTAG/TAP/SWD Core Rules

### TAP-1 [ERROR] JTAG state machine consistency
After a scan operation, the TAP state machine must be left in the state
the caller expects (typically `TAP_IDLE` or `TAP_DRSHIFT`).
Use `jtag_add_runtest()` to advance to `TAP_IDLE` after DR/IR scans.

### TAP-2 [ERROR] Scan field alignment
`scan_field.num_bits` must equal the actual IR/DR register size of the
device. Mismatches corrupt the JTAG chain for all subsequent devices.

### TAP-3 [ERROR] Multi-TAP chain correctness
In multi-TAP chains, IR lengths are cumulative. When addressing one device,
the IR fields of all other devices must contain their BYPASS instruction
(usually all 1s). Do not assume a single-device chain.

### TAP-4 [WARNING] DR scan data alignment
When building `scan_field.out_value` buffers, verify the byte order
matches what the target chip expects. ARM ADIv5 uses little-endian.

### TAP-5 [WARNING] Error recovery after JTAG failure
After a JTAG error (timeout, invalid response), the TAP must be reset
to `TAP_RESET` state before attempting further operations.

### TAP-SWD-1 [ERROR] SWD turnaround timing
SWD protocol requires turnaround clocks between the request phase and
data phase. Skipping them violates protocol and may corrupt the DP.

### TAP-SWD-2 [WARNING] SWD fault handling
After an SWD FAULT or WAIT response, the DP must be cleared
(`ABORT` register) before further transactions.

---

## IFD — Interface/Adapter Driver Rules

### IFD-1 [ERROR] libusb error handling
All `libusb_*` calls that can fail must have their return value checked.
`libusb_bulk_transfer()` may transfer fewer bytes than requested — verify
`actual_length`.

### IFD-2 [ERROR] USB context initialisation
`libusb_init()` must be called before any other libusb operation.
The context must be freed with `libusb_exit()` on shutdown.

### IFD-3 [WARNING] VID/PID discovery not hardcoded
Where possible, use the OpenOCD VID/PID discovery mechanism rather than
hardcoding USB vendor/product IDs. New devices should be added to the
appropriate driver's device table.

### IFD-4 [WARNING] Adapter speed honoured
The adapter driver must implement the `speed` callback and respect the
frequency set by the user. Document the valid speed range.

### IFD-5 [WARNING] Cleanup on disconnect
The `quit` callback must free all resources allocated in `init`/`reset`.
USB handles, transfer buffers, and allocated contexts must all be released.

### IFD-6 [INFO] Adapter claimed in EEPROM/descriptor
For FTDI-based adapters, document the EEPROM configuration required
(channel mode, latency timer, etc.) in the driver comments.

---

## TCL — Tcl Configuration Script Rules

### TCL-1 [ERROR] Standard config variable pattern
Target `.cfg` files must follow the standard variable default pattern:
```tcl
if { [info exists CHIPNAME] } {
    set _CHIPNAME $CHIPNAME
} else {
    set _CHIPNAME mydevice
}
```
This allows overriding from a board config without modifying the target config.

### TCL-2 [ERROR] Transport selection
Include `transport select swd` or `transport select jtag` (or handle both
with `transport select`). Target configs that assume a single transport
without checking will fail silently on boards with the other transport.

### TCL-2a [ERROR] Use `swj_newdap` not manual transport conditionals
When a target supports both JTAG and SWD, use `swj_newdap` (from
`target/swj-dp.tcl`) rather than a manual conditional:

```tcl
# WRONG — Borneo -1'd this pattern:
if {[using_jtag]} {
    jtag newtap $_CHIPNAME cpu -irlen 4 -expected-id $_TAPID
} else {
    swd newdap $_CHIPNAME cpu -expected-id $_TAPID
}

# CORRECT:
source [find target/swj-dp.tcl]
swj_newdap $_CHIPNAME cpu -irlen 4 -expected-id $_TAPID
```

`swj_newdap` encapsulates the transport selection correctly and supports
all transports including SWD multi-drop. The `source [find target/swj-dp.tcl]`
must accompany it.

*Source: Change 7090 — Antonio Borneo, Code-Review-1 on PS2, +2 after fix*

### TCL-3 [WARNING] Use `source [find ...]` not bare `source`
Use `source [find target/swj-dp.tcl]` not `source target/swj-dp.tcl`.
The `find` command searches the script search paths correctly.

### TCL-4 [WARNING] Target name namespacing
Use `$_CHIPNAME.cpu` naming pattern for target names to avoid conflicts
when multiple chips are on the same board.

### TCL-5 [WARNING] Flash bank address from variable
Flash bank base addresses should come from a configurable variable
(or be documented) rather than always hardcoded.

### TCL-6 [WARNING] Events use `configure -event`
Target event handlers must be set via `target configure -event <name> { ... }`
not directly manipulated.

### TCL-7 [WARNING] echo only for informational messages
Use `echo "Info: ..."` for informational output in config scripts.
Do not use echo for errors — the target config should `error` or let
the command fail naturally.

### TCL-8 [INFO] Board configs override target configs
Board configs (in `tcl/board/`) should source target configs with overrides
for chip-specific variables, not copy/modify target configs.

### TCL-10 [ERROR] No dead code in Tcl scripts
Remove all of the following from `.cfg` files:
- Unused local variables (set but never read)
- Procs that are defined but never called
- `arp_examine` calls on targets NOT created with `-defer-examine`
  (examination already happens automatically during init)
- `dbginit` calls where examination already ran it
- `target smp` / SMP proc calls when `target smp` was never set up
- Stale comments that no longer describe the current code

*Source: Change 8175 — Antonio Borneo (6 separate inline comments)*

### TCL-11 [WARNING] Do not repeat OpenOCD defaults
Do not include settings that are already OpenOCD's default:
```tcl
# These are defaults — do NOT include unless you need to change them:
gdb_memory_map enable       # already default
gdb_flash_program enable    # already default
```
Only include settings that differ from the default, and comment why.

*Source: Change 8175 — Antonio Borneo: "OpenOCD default is already ... so these two could be dropped"*

### TCL-12 [WARNING] Comment justification for non-default settings
When enabling a non-default setting in a board or target config,
add a comment explaining why it is needed:
```tcl
# Required for NAND: default map doesn't expose NOR bank at 0x08000000
gdb_memory_map disable
```
Without a comment, reviewers will ask "why do you need to enable this?"

*Source: Change 8175 — Antonio Borneo: "For my curiosity, why you need to enable them? What issue you get?"*

### TCL-13 [WARNING] `arp_examine` only for `-defer-examine` targets
Only call `arp_examine` on targets that were created with `-defer-examine`.
Targets without `-defer-examine` are examined automatically during init;
calling `arp_examine` again is redundant and confusing.

```tcl
# WRONG — target was not created with -defer-examine:
target create $_TARGETNAME aarch64 -dap $_DAP -dbgbase 0x90410000
...
$_TARGETNAME arp_examine   # redundant, examination already happened

# CORRECT — only use when defer-examine was set:
target create $_TARGETNAME aarch64 -dap $_DAP -dbgbase 0x90410000 -defer-examine
...
$_TARGETNAME arp_examine   # OK
```

*Source: Change 8175 — Antonio Borneo: "arp_examine has sense for targets created with -defer-examine, which is not the case here"*

### TCL-9 [INFO] Proc namespace in target configs
Procs defined in target configs should be prefixed with the target name
to avoid name collisions:
```tcl
proc rp2040_something { } { ... }
```

### TCL-14 [ERROR] Adapter speed must be a realistic kHz value
`adapter speed` takes a value in kHz. Do not use `0xffffffff` or other
extreme values. Typical values: `1000` (1 MHz), `4000` (4 MHz).
`adapter speed 4294967295` is ~4 THz and will be flagged immediately.

*Source: Change 6800 — Antonio Borneo: "the value is in kHz. Any special reason for this strange value ~4THz (0xffffffff)? usually we have more humble values like 1000 or 4000"*

### TCL-15 [ERROR] Remove commented-out code before submission
Do not submit new `.cfg` files containing commented-out code blocks without
an explanation. Antonio Borneo asks "why this line commented out? What the
reason to keep it?" for every such instance. Remove all dead/commented-out
code before submitting.

*Source: Change 6800 — Antonio Borneo (×3 separate comments on commented-out blocks)*

### TCL-16 [ERROR] Custom gdb-attach event must preserve `halt 1000`
The default `gdb-attach` event executes `halt 1000` because GDB requires
the target to be halted on attach. When overriding with a custom handler,
the `halt 1000` call must be kept:

```tcl
# WRONG — breaks GDB attach:
$_TARGETNAME configure -event gdb-attach { my_custom_setup }

# CORRECT:
$_TARGETNAME configure -event gdb-attach {
    my_custom_setup
    halt 1000
}
```

*Source: Change 6615 — Antonio Borneo: "By using a custom gdb-attach you drop the default. Now GDB will complain that cannot attach to the target."*

### TCL-17 [WARNING] Consider non-GDB (telnet) users when changing target access
OpenOCD is used from both GDB and the telnet/scripting interface. Target
event handlers and access procs must remain usable from telnet, not only
from GDB sessions.

*Source: Change 6615 — Antonio Borneo: "what about ignoring GDB and using OpenOCD from telnet interface? With this change we loose the possibility to access the core."*

### TCL-18 [ERROR] Consistent processor naming throughout a config file
Use one consistent processor name. Do not mix `M4` and `M33` for the same
core in the same file. If the variable is `M33_JTAG_TAPID`, the target
type must also be the M33 variant.

*Source: Change 6800 — Antonio Borneo: "M4 or M33? Few lines above you used M33_JTAG_TAPID!"*

---

## SRV-GDB — GDB Server Rules

### SRV-GDB-1 [ERROR] Stop reply completeness
GDB stop replies (`T` packet) must include all registers required by
the target description (target XML). Missing registers cause GDB to
display corrupt state.

### SRV-GDB-2 [ERROR] Memory map correctness
Flash regions in the GDB memory map (`qXfer:memory-map:read`) must match
the actual flash banks configured. Incorrect map causes GDB to attempt
RAM writes to flash or vice versa.

### SRV-GDB-3 [WARNING] Thread ID uniqueness
Thread IDs reported to GDB must be unique and stable across resume/halt
cycles. Reusing thread IDs from different targets confuses GDB.

### SRV-GDB-4 [WARNING] File-I/O semihosting interaction
GDB file-I/O (semihosting via GDB) requires the target to be in a specific
state. Do not call GDB file-I/O from interrupt context or while the target
is running.

---

## SRV-TCL — Telnet/Tcl Server Rules

### SRV-TCL-1 [WARNING] Command output format
Commands that produce machine-readable output should have a stable format.
Changing output format (column order, prefixes) breaks scripts that parse it.

### SRV-TCL-2 [INFO] Long-running commands need progress feedback
Commands that may take seconds (flash erase, firmware programming) should
call `keep_alive()` periodically to prevent GDB timeout.

---

## RTO — RTOS Support Rules

### RTO-1 [ERROR] RTOS struct offsets version-checked
Hardcoded offsets into RTOS data structures (thread control blocks, etc.)
must be version-checked. Different versions of the same RTOS may have
different struct layouts.

### RTO-2 [WARNING] RTOS symbol lookup errors handled
When `target_lookup_symbol()` fails to find an RTOS symbol, the RTOS
detection should fall back gracefully, not crash OpenOCD.

### RTO-3 [WARNING] Thread stack safety
When reading thread stacks, verify the stack pointer is within the valid
stack range before dereferencing. A corrupt SP can cause OpenOCD to crash.

### RTO-4 [INFO] New RTOS registration
New RTOS implementations must be registered in `src/rtos/rtos.c`
in the `rtos_types` table.

---

## HP — Helper/Utility Rules

### HP-1 [WARNING] Command framework: Jim_NvpNameLookup vs enum
Use `Jim_Nvp_name2value_err()` for name-to-value lookups in command parsing.
Do not write ad-hoc string comparisons for enumerated command arguments.

### HP-2 [WARNING] LOG_ macro usage
- `LOG_ERROR(...)` — permanent error, operation cannot continue
- `LOG_WARNING(...)` — recoverable issue, user should be aware
- `LOG_INFO(...)` — informational, visible by default
- `LOG_DEBUG(...)` — debug detail, only with `-d` flag
- `LOG_DEBUG_IO(...)` — I/O tracing, highest verbosity

Do not use `printf()` or `fprintf()` directly in OpenOCD code.

### HP-3 [ERROR] No dynamic buffer overruns
When using `snprintf()`, `strncat()`, and similar, ensure the destination
buffer is large enough. Prefer dynamic allocation with `asprintf()` for
variable-length strings.

### HP-4 [WARNING] Free after use
Memory allocated with `malloc()` / `calloc()` / `strdup()` must be freed.
Run with Valgrind or ASAN to verify no leaks.

### HP-5 [INFO] Configuration callbacks
When adding a new configuration item, register it through the configuration
framework (`register_commands()`) rather than using global variables directly.

### HP-6 [WARNING] Use configure.ac for platform-specific headers
When guarding platform-specific includes, use `AC_CHECK_HEADERS([header.h])`
in `configure.ac` and the generated `HAVE_HEADER_H` macro, not repeated
inline platform/version guards. Repeating the same platform check in
multiple source files makes the code unreadable.

```c
/* WRONG — repeating IS_DARWIN version checks everywhere: */
#if IS_DARWIN && __MAC_OS_X_VERSION_MAX_ALLOWED >= 101500
#include <libproc.h>
#endif

/* CORRECT — configure.ac: AC_CHECK_HEADERS([libproc.h])
   Then in source: */
#if IS_DARWIN
#ifdef HAVE_LIBPROC_H
#include <libproc.h>
#endif
#endif
```

*Source: Change 8130 — Antonio Borneo*

### HP-7 [WARNING] Do not add per-message target state without verbosity control
Do not add the target's running/halted state to every log message.
All three primary maintainers (Vanek, Schink, Borneo) have independently
objected to this pattern (Change 8127). It is too verbose by default and
produces misleading `<unknown>` labels during examination.

If per-area verbosity is needed, propose a configurable debug-level system
rather than unconditional additions to all log lines.

*Source: Change 8127 — Tomas Vanek, Marc Schink, Antonio Borneo (unanimous)*

---

## BV — Build Verification Rules

### BV-1 [ERROR] Patch applies cleanly
`git am` must succeed without conflicts or whitespace errors.

### BV-2 [WARNING] No trailing whitespace
`git am` must report no whitespace errors.

### BV-3 [ERROR] Build succeeds
`./bootstrap && ./configure && make` must complete without errors.

### BV-4 [WARNING] No new compiler warnings
The build must produce no new compiler warnings with `-Wall -Wextra`.
Existing warnings are not the scope of this patch review.

### BV-5 [ERROR] Checkpatch passes
`tools/checkpatch.sh` must exit 0. Jenkins applies `-1` for any
checkpatch error or warning.

---

## CS — Correctness and Security Rules

### CS-1 [ERROR] Integer overflow in address arithmetic
Flash and memory address calculations must not overflow `uint32_t` or
`uint64_t`. Check: `if (base + offset < base)` or use safe arithmetic.

### CS-2 [ERROR] Buffer bounds in packet parsing
When parsing GDB, JTAG, or SWD packets, verify that length fields do not
exceed the allocated buffer size before using them as loop bounds or
memcpy lengths.

### CS-3 [ERROR] Use-after-free patterns
Pointers to freed structures (e.g., `target_free_all_working_areas()`)
must be set to NULL after freeing. Subsequent use checks for NULL.

### CS-4 [ERROR] JTAG scan field lifetime
`scan_field.in_value` and `scan_field.out_value` buffers must remain valid
until `jtag_execute_queue()` is called. Stack-allocated buffers that go
out of scope before the queue is flushed are dangerously incorrect.

### CS-5 [WARNING] Config value sanitisation
Configuration values supplied by the user (via Tcl commands or `.cfg` files)
that are used in memory operations (size, offset, count) must be validated
before use.

### CS-6 [WARNING] Potential NULL dereference in lookup functions
`get_flash_bank_by_addr()`, `get_target_by_num()`, `register_get_by_name()`
and similar functions return NULL on failure. The caller must check.

### CS-7 [WARNING] Format string safety
`LOG_*()` calls must not use user-controlled strings as format specifiers.
Use `LOG_ERROR("%s", user_string)` not `LOG_ERROR(user_string)`.

### CS-8 [WARNING] Unaligned memory access
Target memory operations requiring word alignment (many ARM/MIPS peripherals)
must verify the target address is aligned. Unaligned access may be silently
corrupted or may fault.

### CS-9 [INFO] Time-of-check to time-of-use (TOCTOU) in flash
If flash protect state is read before erase/write and the actual operation
checks it again, document that a race exists. For single-core embedded
targets this is usually acceptable but should be noted.

### CS-10 [INFO] 64-bit host/32-bit target mismatches
When OpenOCD (running on a 64-bit host) stores target addresses, use
`target_addr_t` or `uint32_t`/`uint64_t` explicitly. Do not use `int` or
`long` which have different sizes on host vs. target.

---

---

## ARCH — Architecture and Project-Policy Rules

These rules capture OpenOCD-specific project conventions observed in maintainer reviews.

### ARCH-1 [ERROR] Do not patch auto-generated files

Files auto-generated from upstream specs (e.g., `src/target/riscv/encoding.h`
generated from `riscv/riscv-opcodes`) must NOT be patched directly in OpenOCD.
The fix must go upstream first. Maintainers will reject such patches.

*Source: Change 7600 — Antonio Borneo declined to merge a ULL-suffix fix in encoding.h.*

### ARCH-2 [ERROR] TCL command return and LOG output must remain separate

TCL commands must return a TCL value (string + error code). `LOG_*()` calls
are for logging to the user only. Do not bridge between them.

- `capture {}` is the correct tool to grab log output in Tcl
- Do NOT modify `LOG_*()` routing to feed into command return values
- The `tcl_server` log/return architecture is intentional

*Source: Change 7200 — Antonio Borneo blocked and explained the architecture.*

### ARCH-3 [WARNING] Coordinate with upstream vendor before submitting vendor support

If an upstream hardware vendor (TI, ST, NXP, etc.) has indicated they have
unpublished work in progress for the same feature, coordinate before submitting.
Contact the vendor team first or note in the commit message that coordination
was attempted.

*Source: Change 8220 — Third-party MSPM0 flash driver conflicted with TI's in-progress work.*

### ARCH-4 [WARNING] RTOS backends must follow the stacking file pattern

New RTOS backends must separate stacking register information into a dedicated
`src/rtos/rtos_<name>_stackings.c` and `src/rtos/rtos_<name>_stackings.h`,
matching the pattern of FreeRTOS, ChibiOS, NuttX, etc.

*Source: Change 7250 — Reviewer required separate stacking file for consistency.*

### ARCH-5 [INFO] Interim fix + FIXME comment is acceptable
When a proper fix requires large-scale refactoring (renaming, inlining,
touching many targets), a minimal interim fix (e.g., zero-initialisation
of an uninitialized field) with a `/* FIXME: proper fix is ... */` comment
is acceptable as a stepping-stone patch. Both Vanek and Borneo endorsed
this approach in 8181 rather than blocking on perfection.

*Source: Change 8181 — Tomas Vanek + Antonio Borneo*

### ARCH-7 [WARNING] Use a reasonable fixed work area size — do not use max SRAM
When specifying `-work-area-size` for a target, use a sensible fixed size
(e.g., `0x8000` = 32 KB) rather than attempting to use the entire available
SRAM. SRAM sections may not be contiguous or guaranteed available; 32 KB
is more than sufficient for all flash programming algorithms.

*Source: Change 6800 — Karl Palsson: "Just set this to something like 32k, that's more than enough for working space for flash algorithms"*

### ARCH-8 [INFO] Fix broken Tcl syntax rather than working around it
Do not add OpenOCD code to accept or normalise incorrect Tcl syntax.
jimtcl has its own constraints; patches should fix the scripts to use
correct syntax rather than making OpenOCD tolerate bad syntax.

*Source: Change 6560 — Antonio Borneo abandoned own patch: "Let's try to be compliant to TCL as possible, otherwise we could have other problems at next jimtcl version"*

### ARCH-6 [INFO] Any maintainer may override a prior Code-Review+2
A +2 from one maintainer does not close the review. Any other maintainer
may give -1 after a +2 if they identify real issues. This is normal
OpenOCD practice, not a conflict. Do not argue "but X already approved it."

*Source: Change 8232 — Antonio Borneo gave -1 after Tomas Vanek's +2, then +2 after fixes*

---

## NM/CS Clarifications from Real Reviews

### NM-8 [WARNING] Variable declaration placement (nuanced rule)

The coding style guide says: declare variables at first use, not at function top.

**However**, Tomas Vanek (maintainer) clarified (Change 8060):
- Widely-used boilerplate variables (`target`, `retval`, `bank`) that span most
  of the function *may* be declared at the top for readability
- Variables used only in a sub-block (`intr`, `sts1`, etc.) must be declared
  at first use per the strict rule
- When in doubt, apply the stricter "declare at first use" rule

### CMD-7 [ERROR] CMD_ARGC check must use exact conditions
Use `!= N` or `!= 3 && != 4` (when a range is valid) — not `< N` or `> N`
when the valid range is precisely known. Antonio Borneo consistently
replaces loose checks with exact ones:

```c
/* WRONG — too loose: */
if (CMD_ARGC > 4) return ERROR_COMMAND_SYNTAX_ERROR;

/* CORRECT — exact: */
if (CMD_ARGC != 3 && CMD_ARGC != 4) return ERROR_COMMAND_SYNTAX_ERROR;
```
Check lines after CMD_ARGC to determine all valid counts before writing the check.

*Source: Change 8000 — Antonio Borneo (3 consecutive inline comments on same file)*

### CMD-8 [ERROR] Declarations after CMD_ARGC check

Variable declarations for command argument parsing should come **after** the
`CMD_ARGC` bounds check, not before it. This ensures invalid argument count
is caught before any setup work is done.

*Source: Change 8060 — Marc Schink: "Move this **after** the CMD_ARGC check."*

### TY-10 [WARNING] `__attribute__((unused))` for deliberately kept unused parameters
When a refactor or patch leaves a function parameter unused but the parameter
must be kept for API/signature consistency (e.g., all GDB packet handlers
share the same signature), add `__attribute__ ((unused))` rather than removing
the parameter.

```c
static int gdb_handle_foo(struct connection *connection,
                          const char *packet,
                          int packet_size __attribute__ ((unused))) {
```

*Source: Change 7569 — Antonio Borneo: "Please add __attribute__ ((unused)) to 'packet_size'."*

### CM-3a [WARNING] CI/build fix commit messages must cite the exact failure
A commit that fixes a CI job, GitHub Actions workflow, or build warning must
include in the body: what failed, where (log link or error text), and why
the fix works. "Fixes error X" without context will receive a -1.

*Source: Change 7551 — Antonio Borneo: "I have no idea what this patch is fixing. Can you explain more, maybe in the commit message? Can you report the complete error message."*

### CM-9 [ERROR] Do not inadvertently revert submodule pointer
Patches must not revert git submodule pointers as a side effect of rebase or
merge. Antonio Borneo identifies submodule regressions immediately as a
blocking -1, independent of whether the rest of the patch is correct.
Check `git diff HEAD~1 -- jimtcl` before submitting.

*Source: Changes 7524, 7551 — Antonio Borneo: "I put -1 because you are incorrectly reverting the jimtcl submodule to 0.81, while we have just updated it to 0.82."*

### CM-3b [INFO] Note pre-existing doc/behaviour mismatches during rewrites
When refactoring or rewriting a COMMAND_HANDLER without changing behaviour,
check whether the command's documented behaviour matches its actual behaviour.
If a mismatch exists and is not fixed in this patch, add a comment or TODO.

*Source: Change 7554 — Tomas Vanek flagged that `jtag tapenable` returns an error when the tap is already in the desired state, contradicting the documentation.*

### CS-11 [WARNING] Register cache has semantic importance for Cortex-A/AArch64
The register cache is NOT merely a performance optimisation. On Cortex-A and
AArch64, R0 (and R1 for wide data) are used as scratch registers when reading
or writing other registers and memory. The cache preserves these values when
they get dirtied by such operations. Any patch touching register flush,
invalidate, or force-read must account for this and provide architecture-specific
implementations for at least Cortex-A and AArch64.

*Source: Change 8070 — Antonio Borneo: "Not true! On Cortex-A and AArch64 the register R0 is used to read/write either the other registers and the memory... the implementation of target_flush_all_regs_default() is broken for Cortex-A and AArch64 because it flushes R0 as first, but then flushing the other registers it causes R0 to become dirty!"*

### ARCH-9 [WARNING] Document the API before implementing it
For new public APIs in `src/target/register.h`, `target.c`, or other core
target infrastructure, Borneo requests a documentation patch first:
- Add doxygen comments to the relevant header
- Fill in the appropriate section of `doc/manual/target.txt`

Only after the API contract is documented and agreed should the implementation
follow. This avoids implementing the wrong semantics.

*Source: Change 8070 — Antonio Borneo: "What about starting with a first patch to clearly document the API we plan to introduce and their expected behavior? In src/target/register.h there is not a single doxygen comment."*

### ER-9 [INFO] Useless goto-to-return (non-blocking but noted)

A `goto cleanup;` where the label is immediately before a `return` with no
cleanup action is considered redundant by some reviewers. However, authors
have defended this pattern as promoting consistent control flow style.
This is an INFO-level note (not a blocking ERROR/WARNING).

*Source: Change 8060 — Marc Schink flagged; Brandon Martin defended as consistent style.*

### TY-8 [WARNING] Use int64_t for timeval_ms() return value

`timeval_ms()` returns `int64_t`. Variables storing its return value must be
`int64_t`, not `int`, `long`, or `uint32_t`.

*Source: Change 8060 — Marc Schink: "Use int64_t as it's the return datatype of timeval_ms()"*

### TY-9 [WARNING] Use unsigned types for counts and loop indices

Loop iteration variables and item counts should use `unsigned` (or `unsigned int`,
`uint32_t`) types, not signed `int`. Signed loop counters can mask wrap-around bugs.

*Source: Change 8060 — Marc Schink: "Should also be unsigned not signed."*

---

## Reference Patches with Known Issues

| Change | Subject | Area | Key Issues Found |
|--------|---------|------|-----------------|
| 6615 | tcl/target/ti_k3: Add gdb-attach hook for m3/m4 | tcl/target | TCL-16 (halt 1000 required), TCL-17 (telnet users) — TI patch |
| 7090 | tcl/target/ti_k3: Handle swd vs jtag | tcl/target | Manual `if/using_jtag/else` transport block rejected; must use `swj_newdap` (TCL-2a) |
| 7200 | server/tcl_server.c: Fix logs override problem | server | TCL return vs LOG must stay separate (ARCH-2) |
| 7551 | github/workflow: increase delete-tag-and-release version | build | CM-9 (submodule revert), CM-3a (explain failure in commit msg) |
| 7554 | jtag: rewrite jim_jtag_tap_enabler as COMMAND_HANDLER | jtag | CM-3b (note doc/behavior mismatch during rewrite) |
| 7569 | src: fix clang15 compiler warnings | helper | TY-10 (`__attribute__((unused))` for kept-but-unused params) |
| 7600 | target/riscv: use ULL suffix for long constants in encoding.h | target/riscv | Auto-generated file must be fixed upstream (ARCH-1) |
| 7940 | breakpoints: Fix endless loop in bp/wp_clear_target | target | Initial approach rejected; required tmp-pointer pattern for list iteration |
| 7950 | tcl/target/ti_k3: Add AM273 SoC | tcl/target | Clean merge — good reference for adding new SoC to existing multi-SoC cfg |
| 8000 | flash/nor/stm32h7x: Remove redundant error messages | flash/nor | CMD-7: exact CMD_ARGC conditions required (Borneo ×3) |
| 8060 | flash/nor/fsl_flexspi: Support arbitrary flash cmd | flash/nor | NM-8 (variable placement), CMD-7/8 (argc ordering), TY-8 (int64_t), TY-9 (unsigned), ER-9 |
| 8070 | target: Fix force-reading of registers | target | CS-11 (register cache semantics), ARCH-9 (document API first) |
| 8127 | helper/log: report target state in logs | helper | HP-7: verbosity rejected unanimously by all 3 maintainers |
| 8130 | helper/options.c: Extend IS_DARWIN guard | helper | HP-6: use AC_CHECK_HEADERS + HAVE_* macro in configure.ac |
| 8175 | tcl/board: Add Terasic DE1-SoC | tcl/board | CM-1a/b (subject format), TCL-10 (dead code), TCL-11 (defaults), TCL-12 (justify non-defaults), TCL-13 (arp_examine) |
| 8181 | target/breakpoints: do not use ->number field | target | ARCH-5 (interim FIXME fix accepted), ARCH-6 (Borneo -1'd after Vanek +2) |
| 8220 | flash/nor/mspm0: Add TI MSPM0xxxx support | flash/nor | ARCH-3: coordinate with upstream vendor before submitting |
| 8232 | drivers/cmsis_dap: Fix buffer overflow | jtag/drivers | ARCH-6: Borneo -1 after Vanek +2 — independent review always valid |
| 8450 | tcl/target/rp2350: workarounds for ROM API issues | tcl/target | Prior comment unresolved over multiple patchsets |
| 6800 | Initial cut at support for LPC55S16 | tcl/target | CM-1a (subsystem prefix), WS-6 (SPDX in TCL), TCL-14 (adapter speed), TCL-15 (dead code), TCL-18 (naming), ARCH-7 (work area size) |

*Gerrit harvest: 27 general + 5 TI-authored + 31 maintainer-review patches analysed (2026-05-12)*
*TI changeids registry: logs/ti-patches/changeids.md*
*Maintainer review harvest: logs/maintainer-reviews/harvest-2026-05-12.md*
