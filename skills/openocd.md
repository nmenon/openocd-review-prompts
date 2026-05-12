# OpenOCD Review Skill

This skill is auto-loaded when working in an OpenOCD source tree.

## Source Tree

OpenOCD source is at: {{OPENOCD_SRC}}

## Context

OpenOCD (Open On-Chip Debugger) is a free/open-source embedded debug tool
supporting JTAG, SWD, and other debug transports. The project uses:

- **Build system**: GNU autotools (`configure.ac`, `Makefile.am`)
- **Language**: C (C99/C11 with POSIX extensions), Tcl scripts
- **Code style**: 4-space tabs, 120-char lines, snake_case functions
- **Review server**: https://review.openocd.org (Gerrit)
- **Checkpatch**: `tools/checkpatch.sh` (Jenkins CI validates all submissions)
- **License**: GPL-2.0-or-later

## Key Invariants

When reviewing or explaining OpenOCD code, keep these invariants in mind:

1. **Target must be halted before register/memory access** —
   any `target_read_*()` or `target_write_*()` call on a running target
   will fail or corrupt state.

2. **Workarea must be freed on all exit paths** —
   `target_alloc_working_area()` must be paired with
   `target_free_working_area()` on every return path.

3. **JTAG scan fields must remain valid until `jtag_execute_queue()`** —
   `scan_field.in_value` and `scan_field.out_value` buffers are owned
   by the caller until the queue is flushed.

4. **Endianness: use OpenOCD buffer helpers** —
   use `le_to_h_u32()`, `h_u32_to_le()`, `be_to_h_u32()`, `h_u32_to_be()`
   instead of direct pointer casting. OpenOCD runs on both LE and BE hosts.

5. **New flash drivers must be registered in `drivers.c`** —
   and added to `Makefile.am`.

6. **Config variables in Tcl scripts must have defaults** —
   use `if { [info exists VAR] } { ... } else { set _VAR default }` pattern.

## Subsystem Quick Reference

| Path | Subsystem |
|------|-----------|
| `src/flash/nor/` | NOR flash chip drivers |
| `src/flash/nand/` | NAND flash chip drivers |
| `src/target/` | CPU target support (ARM, RISC-V, MIPS, etc.) |
| `src/jtag/` | JTAG core and TAP state machine |
| `src/jtag/drivers/` | Interface adapter drivers |
| `src/transport/` | JTAG/SWD transport abstraction |
| `src/server/` | GDB, telnet, Tcl server implementations |
| `src/rtos/` | RTOS awareness (FreeRTOS, uCOS, etc.) |
| `src/helper/` | Command framework, logging, utilities |
| `tcl/` | Tcl configuration scripts |
| `doc/openocd.texi` | User manual (must update for new commands) |

## Review Commands

- `/openocd-review <change_id>` — full review of a Gerrit patch
- `/openocd-verify` — apply false-positive gates to current findings

## Important Files

- `HACKING` — patch submission guidelines
- `.checkpatch.conf` — checkpatch configuration
- `src/flash/nor/drivers.c` — flash driver registry
- `src/jtag/drivers/drivers.c` — JTAG adapter driver registry
- `src/target/target.c` — target type registry
- `src/rtos/rtos.c` — RTOS type registry

## Gerrit Notes

- All patches go to `refs/for/master`
- Jenkins runs checkpatch on every patchset; failures give `-1`
- `-1` (Code-Review) from a maintainer requires the concern to be addressed
  or explained before resubmission
- A `-1` may be overridden after 30 days if concerns were addressed but the
  reviewer did not re-review
