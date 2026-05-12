# OpenOCD Review Verification Command

Read this file: {{REVIEW_DIR}}/false-positive-guide.md

Apply every gate in the false-positive guide to every finding currently in the
analysis. For each finding:

1. State whether it passes or fails each gate (G1 through G5)
2. For rule-specific checks, apply the relevant section
3. Drop any finding that fails a gate
4. For findings that pass all gates, confirm with: "VERIFIED: FINDING-N passes all gates"

Output:
```
VERIFICATION RESULTS
====================
FINDING-1 [RULE-CS-6]: <description>
  G1 (in diff):   PASS — line 42 is a + line
  G2 (reachable): PASS — file is in Makefile.am
  G3 (full func): PASS — read full probe() function
  G4 (new code):  PASS — not present before this patch
  G5 (exceptions): PASS — no exception applies
  VERDICT: CONFIRMED

FINDING-2 [RULE-ER-1]: <description>
  G3 (full func): FAIL — caller checks return value 3 lines above; hunk was misleading
  VERDICT: FALSE POSITIVE — DROPPED

Final: N findings confirmed, N dropped as false positives.
```

The argument to this command (if any) is a finding or list of findings to verify.
If no argument, verify all current findings.
