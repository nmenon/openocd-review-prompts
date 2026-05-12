# OpenOCD Patch Review Framework

AI-assisted, rule-based review framework for OpenOCD Gerrit patches.
Modelled on the [TF-A review framework](https://github.com/nmenon/arm-trusted-firmware-review-prompts)
and the [Linux kernel review prompts](https://github.com/masoncl/review-prompts),
incorporating patterns from real OpenOCD maintainer reviews.

---

## Dependencies

* [gerrit-code-review-mcp](https://github.com/cayirtepeomer/gerrit-code-review-mcp) — Gerrit MCP tool (fetch changes, post reviews)
* https://review.openocd.org - Gerrit Instance for OpenOCD reviews
* A local OpenOCD clone and build environment.

---

## What It Does

Given an OpenOCD Gerrit change number, this framework:

1. Fetches the patch and **all prior reviewer comments** from Gerrit
2. Applies the patch to your local OpenOCD tree and launches a **build in the background**
3. Runs `tools/checkpatch.sh` in the background
4. **Reads the full context** of every changed function (not just the diff hunk)
5. Applies **24 rule categories** covering commit message, style, subsystem correctness, and security
6. Checks whether prior reviewer comments were **FIXED / PARTIAL / NOT FIXED**
7. Eliminates false positives through a structured verification pass
8. Produces a **plain-text review report** with severity ratings
9. Asks (and **never acts without explicit confirmation**) whether to post it to Gerrit

---

## Prerequisites

### 1. Claude Code

Install [Claude Code](https://docs.claude.com/en/docs/claude-code/overview) CLI.

### 2. openocd-gerrit-review MCP Server

This framework requires the `openocd-gerrit-review` MCP server to fetch patches
from `review.openocd.org`. Configure it in your Claude Code settings
(`.claude/settings.json` or `~/.claude/settings.json`):

```json
{
  "mcpServers": {
    "openocd-gerrit-review": {
      "command": "path/to/openocd-gerrit-review-mcp",
      "args": [],
      "env": {
        "GERRIT_URL": "https://review.openocd.org"
        "GERRIT_USER": "username",
        "GERRIT_AUTH_METHOD": "basic",
        "GERRIT_PASSWORD": "password from https://review.openocd.org/settings/#HTTPCredentials",
        "GERRIT_SSL_VERIFY": "true"
      }
    }
  }
}
```

Verify it works by running in Claude Code:
```
What is the subject of OpenOCD Gerrit change 8450?
```
Claude should fetch and return: `tcl/target/rp2350: workarounds for ROM API issues`.

### 3. Build Dependencies

Refer to the latest [OpenOCD installation requirements](https://github.com/openocd-org/openocd/blob/master/README.md#openocd-dependencies)

```bash
# Debian/Ubuntu
sudo apt install autoconf automake libtool pkg-config libusb-1.0-0-dev \
                 libhidapi-dev libftdi1-dev gcc make

# Fedora/RHEL
sudo dnf install autoconf automake libtool pkg-config libusb1-devel \
                 hidapi-devel libftdi-devel gcc make
```

### 4. OpenOCD Source Clone

Clone the OpenOCD repository:
```bash
git clone https://review.openocd.org/openocd.git ~/src/openocd
cd ~/src/openocd
./bootstrap && ./configure && make -j$(nproc)   # verify it builds clean
```

---

## Installation

```bash
git clone <this-repo> openocd-review-prompts
cd openocd-review-prompts
./setup.sh --openocd-src ~/src/openocd
```

`setup.sh` will:
- Auto-detect common OpenOCD clone paths, or prompt you for one
- Substitute the path into all template files
- Install `~/.claude/skills/openocd/SKILL.md` (auto-loaded in OpenOCD trees)
- Install `~/.claude/commands/openocd-review.md` (`/openocd-review` command)
- Install `~/.claude/commands/openocd-verify.md` (`/openocd-verify` command)

**Re-run `./setup.sh` any time you edit files under `skills/` or `slash-commands/`.**

---

## Quick Start

Open Claude Code in the OpenOCD source tree (or anywhere) and run:

```
/openocd-review 8450
```

To skip the build step (faster, style/logic only):
```
/openocd-review 8400 skip-build
```

Claude will work through the review protocol and produce output like:

```
CHANGE_ID: 8400
SUBJECT: flash/nor: add DesignWare SPI controller driver
AUTHOR: ...
SUBSYSTEMS: flash/nor
PATCHSET: 3

REACHABILITY: confirmed

CHANGE-1: FUNC-NEW src/flash/nor/dwspi.c dwspi_probe()
CHANGE-2: FUNC-NEW src/flash/nor/dwspi.c dwspi_flash_read()
CHANGE-3: MAKEFILE src/flash/nor/Makefile.am

Prior Comments: 5 total — FIXED: 4, NOT FIXED: 1, STALE: 0

FINDING-1:
  Rule: FLS-NOR-7
  Severity: WARNING
  Function: dwspi_probe()
  File: src/flash/nor/dwspi.c
  Description: Does dwspi_probe() validate the device ID before populating
               bank->sectors? If the ID is unrecognised, should it return
               ERROR_FAIL rather than continuing?
  Evidence:
    device_id = dwspi_read_id(bank);
    bank->num_sectors = ...   /* no ID check before this */

...

FINAL FINDINGS: 3 (1 ERROR, 1 WARNING, 1 INFO)
FINAL SEVERITY: medium
BUILD: PASS
CHECKPATCH: PASS
REPORT: /tmp/openocd-review-8400-ps3.md

Submit this review to Gerrit? [yes/NO]
```

---

## Workflow Details

```
Task 0   Setup & fetch
           └─ Fetch change + all prior inline comments from Gerrit
              Identify OpenOCD source tree path
              Ask for build command (or accept from invocation)

Task 1A  Background jobs (started FIRST to overlap with analysis)
           └─ git am → patch applied
              ./bootstrap && ./configure && make   [background]
              tools/checkpatch.sh                   [background]

Task 1B  Read changed files in full
           └─ Every touched file read completely (not just diff hunk)

Task 1C  Categorise changes
           └─ CHANGE-N entries: FUNC-NEW/MOD, CTRL-FLOW, RESOURCE,
              API-CHANGE, CMD-NEW, TYPE-NEW, INCLUDE-CHG, MAKEFILE,
              TCL-SCRIPT, DOC-ONLY

Task 2   Regression analysis
           └─ Reachability gate (Makefile.am, configure.ac, #ifdef)
              Apply all matching subsystem rules
              Trace call chains one level up and down

Task 3   Prior comment audit
           └─ Each prior inline comment → FIXED / PARTIAL / NOT FIXED / STALE

Task 4   False-positive elimination
           └─ G1: code on + lines?  G2: reachable?  G3: full function read?
              G4: not pre-existing?  G5: no exception applies?

Task 5   Collect build results
           └─ BV-1..BV-5: git am / whitespace / build / warnings / checkpatch

Task 6   Report + optional Gerrit submission
           └─ Plain-text report  +  review-metadata.json
              Ask user before any Gerrit post
```

---

## Rule Categories

| Prefix | Category | Key Rules |
|--------|----------|-----------|
| `CM-`  | Commit Message | Subject format, Signed-off-by, body for non-trivial changes |
| `WS-`  | Whitespace | Tabs, 120-char lines, SPDX on new files |
| `CO-`  | Comments | C-style only, explain why not what, doc for new exports |
| `HG-`  | Header Guards | `#ifndef OPENOCD_<PATH>_H` pattern |
| `IN-`  | Includes | `config.h` first, group ordering |
| `NM-`  | Naming | `snake_case`, `UPPER_SNAKE_CASE`, driver prefix pattern |
| `TY-`  | Types | Fixed-width types, `int64_t` for `timeval_ms()`, endianness helpers |
| `ER-`  | Error Handling | Check all target memory ops, propagate errors, null checks |
| `CMD-` | Commands | `COMMAND_HANDLER` macro, CMD_ARGC first, `.texi` docs |
| `FLS-NOR-` | Flash NOR | All callbacks, probe initialises sectors, workarea lifecycle |
| `FLS-NAND-` | Flash NAND | Bad-block table, ECC, alignment |
| `TGT-` | Target | `target_type` callbacks, halt before access, API usage |
| `TAP-` | JTAG/TAP/SWD | State machine, scan field alignment, SWD turnaround |
| `IFD-` | Interface Drivers | libusb error handling, USB context, speed callback |
| `TCL-` | Tcl Scripts | Config variable defaults, transport selection, `find` usage |
| `SRV-GDB-` | GDB Server | Stop reply completeness, memory map correctness |
| `SRV-TCL-` | Tcl Server | Stable output format, `keep_alive()` for long ops |
| `RTO-` | RTOS | Version-checked offsets, symbol lookup errors, stack safety |
| `HP-`  | Helpers | `Jim_Nvp` for enums, `LOG_*` macros, no `printf`, buffer safety |
| `BV-`  | Build Verification | patch applies, build clean, no new warnings, checkpatch passes |
| `CS-`  | Correctness/Security | Address overflow, buffer bounds, use-after-free, scan field lifetime |
| `ARCH-` | Project Architecture | Auto-generated files upstream, TCL return vs LOG separation |

Rules derived from: `HACKING` file, `.checkpatch.conf`, OpenOCD source conventions,
and analysis of 27 merged/reviewed patches from Gerrit (range 7150–8450).

---

## Output Files

| File | Contents |
|------|----------|
| `/tmp/openocd-review-<id>-ps<N>.md` | Full review report |
| `./review-metadata.json` | Machine-readable summary for scripts |

### review-metadata.json schema
```json
{
  "change_id": 8400,
  "patchset": 3,
  "subject": "flash/nor: add DesignWare SPI controller driver",
  "subsystems": ["flash/nor"],
  "issues-found": 3,
  "issue-severity-score": "medium",
  "issue-severity-explanation": "One unchecked return value in probe path could cause silent failure",
  "build_status": "pass",
  "prior_comments_fixed": 4,
  "prior_comments_not_fixed": 1
}
```

Severity scores: `none` | `low` | `medium` | `high` | `urgent`

---

## Gerrit Voting

The framework suggests a Gerrit vote based on findings:

| Situation | Suggested Vote |
|-----------|---------------|
| Only INFO findings, build passes | `0` (no score) |
| Any WARNING | `0` |
| Any ERROR, or build/checkpatch failure | `-1` |
| Prior comments NOT FIXED + any ERROR | `-1` |

Claude **always asks before submitting**. The default answer is NO.
Never runs `submit_gerrit_review` autonomously.

---

## Subsystem Trigger System

The review plan (Section 0) maps changed file paths to subsystem rule sections.
Claude loads the relevant sections automatically. For example:

- Touching `src/flash/nor/` → applies all `FLS-NOR-*` rules
- Touching `src/jtag/drivers/` → applies all `IFD-*` and `TAP-*` rules
- Touching `tcl/target/*.cfg` → applies all `TCL-*` rules
- Touching `src/rtos/` → applies all `RTO-*` rules

---

## Reference Patches

Real patches with documented review findings (from `logs/gerrit_harvest_2026-05-12.md`):

| Change | Subject | Key Issues |
|--------|---------|------------|
| 8060 | flash/nor/fsl_flexspi: Support arbitrary flash cmd | Variable placement (NM-8), `int64_t` for timeval_ms (TY-8), CMD_ARGC ordering (CMD-7) |
| 8220 | flash/nor/mspm0: Add TI MSPM0xxxx support | Upstream vendor coordination required (ARCH-3) |
| 7940 | breakpoints: Fix endless loop in bp/wp_clear_target | First approach rejected; required tmp-pointer pattern |
| 7600 | target/riscv: ULL suffix in encoding.h | Auto-generated file — must fix upstream (ARCH-1) |
| 7200 | server/tcl_server: Fix logs override | TCL return vs LOG must stay separate (ARCH-2) |
| 7350 | jtag/drivers/bcm2835gpio: peripheral_mem_dev | 29 comments over 6 months; 4 patchsets |
| 8180 | rtos/nuttx: Fix stack alignment for cortex-m | 39 comments over 10 patchsets |

---

## File Structure

```
openocd-review-prompts/
├── README.md                          This file
├── review-core.md                     Execution protocol (6 tasks)
├── openocd-review-plan.md             Rules catalog (24 categories, 150+ rules)
├── false-positive-guide.md            Verification gates (G1–G5 + rule-specific)
├── setup.sh                           Installation script
├── skills/
│   └── openocd.md                     Claude Code skill template
├── slash-commands/
│   ├── openocd-review.md              /openocd-review command template
│   └── openocd-verify.md              /openocd-verify command template
└── .claude/
    └── settings.local.json            MCP + bash permissions for this project
```

Templates use `{{OPENOCD_SRC}}` and `{{REVIEW_DIR}}` placeholders that `setup.sh`
replaces with the actual paths on your machine.

---

## Enriching the Rules (Gerrit Harvest)

To add more rules from real review history, run a harvest against a batch of
recent merged patches and save the inline comment text. The `logs/` directory
contains the initial harvest. Additional harvests can be done by fetching
more change IDs via the Gerrit MCP and noting patterns in maintainer comments.

Maintainer accounts to watch for review patterns:
- **Tomas Vanek** (`vanekt`) — primary maintainer, submits and merges most patches
- **Antonio Borneo** — architecture and protocol correctness expert
- **Marc Schink** (`zapb`) — coding style and type correctness
- **Jan Matyas** — RISC-V, target debugging
- **Tim Newsome** — RISC-V, general reviews

---

## Troubleshooting

**`/openocd-review` says the MCP is not available:**
Check that `openocd-gerrit-review` appears in `claude mcp list`. Re-run
`claude mcp add` if needed.

**`git am` fails with conflicts:**
The patch was submitted against a different base. Claude will record BV-1: FAIL
and continue with style/logic analysis. Use `skip-build` if you just want rules.

**Build fails but patch looks correct:**
May be a missing `--enable-<driver>` configure flag. Common ones:
`--enable-ftdi --enable-stlink --enable-cmsis-dap --enable-jlink`

**checkpatch gives false positives:**
OpenOCD's `.checkpatch.conf` suppresses many Linux-specific checks. If checkpatch
still fires on something that looks correct, check whether the commit message
should include `Checkpatch-ignore: <TYPE>` (see `HACKING` for details).

**`setup.sh` can't find the OpenOCD tree:**
Pass the path explicitly:
```bash
./setup.sh --openocd-src /full/path/to/openocd
```

---

## Contributing to This Framework

1. Edit files under `skills/` or `slash-commands/` (templates with `{{...}}` placeholders)
2. Edit `review-core.md` or `openocd-review-plan.md` for rule changes
3. Run `./setup.sh --openocd-src <path>` to re-deploy
4. Add new rules to `openocd-review-plan.md` with a source citation (`*Source: Change NNNN*`)
5. Add confirmed patterns to `logs/` as harvest notes

When adding rules, cite the Gerrit change that motivated them. This keeps the
rules grounded in actual review feedback rather than speculation.
