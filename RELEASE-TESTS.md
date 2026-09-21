# Release packaging checks — 2026-09-21

These checks concern the new installer and wrapper. Historical GPU/game evidence and its limitations are in VALIDATION.md; packaging checks are not new game-stability evidence.

- Bash launcher syntax: passed.
- Actual isolated installation on the BC250, using the tested Proton 11.0-2c base: passed, including dependency resolution and payload checksums.
- Installed launcher `--check`: passed for both driver and private patched DLL.
- Existing installation refusal: passed without replacing files.
- Wrong Proton command refusal: passed.
- Native wrapper process launch and exported compute-to-graphics / compact-vertices-off policy: passed.
- Managed uninstall of the isolated copy: passed; original Proton and working driver retained.
- Original DLL SHA256 after checks: `1dd2de3737fa70b2131368304c36d8fae0797fb7f3bfe1357b207c59739686c5`.
- Original Mesa SHA256 after checks: `ee8b43e646036e6fde20040dbd18afb40da63f12b79d5c0826fcbdd9c0fae58e`.

No GPU submissions were made for these packaging checks. A fresh game launch through Steam's newly registered public compatibility-tool entry has not been qualified; the original private R2 launcher supplied the historical game evidence. Other distributions, Steam runtime layouts and Proton versions remain unqualified.
