# OpenOCD Patch Review Command

Read this file: {{REVIEW_DIR}}/review-core.md

Also read these files before proceeding:
- {{REVIEW_DIR}}/openocd-review-plan.md
- {{REVIEW_DIR}}/false-positive-guide.md

The OpenOCD source tree is at: {{OPENOCD_SRC}}

The change ID to review is: $ARGUMENTS

If no change ID is provided, ask the user for one.

If the argument is `<change_id> skip-build`, set BUILD_CMD to "skip-build".

Follow the execution protocol in review-core.md exactly.
Start with Task 0, then proceed through Tasks 1A-1C, 2, 3, 4, 5, 6 in order.
Task 1A (build in background) must be started before Task 1B (reading files).
