---
description: Run code generation (fluttergen + l10n + build_runner + format).
---

Run `mise exec -- make gen` to regenerate all generated sources, then briefly report what
changed. Do not hand-edit any generated file (`**/generated/**`, `*.g.dart`,
`*.gen.dart`) — if generation output looks wrong,
fix the source input, not the generated file.
