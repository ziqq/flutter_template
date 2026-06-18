---
applyTo: "lib/src/feature/**/widget/*.dart"
description: "Use when: generating or editing Flutter feature widgets and screens, especially documentation comments for widget contracts, required scopes, callbacks, and UI-side effects."
---

# Feature Widget Documentation Instructions

These rules extend the broader Dart documentation rules for feature widget files.

## Focus

- Document the public widget or screen directly instead of adding file-level prose.
- Explain the user task or UI responsibility first.
- Keep docs short, concrete, and caller-focused.

## What To Explain For Widgets

- What user flow or screen responsibility this widget owns.
- Which scopes, controllers, models, or callbacks must already be available.
- Which constructor parameters materially change behavior.
- Which navigation, loading, empty, error, or retry behaviors are part of the contract.
- Which side effects a parent flow must know about.

## Preferred Style

- Start with one short summary sentence.
- Add another paragraph only when it helps another developer embed the widget correctly.
- Prefer phrases such as `Use this screen when ...`, `This widget expects ...`, and `Use [onFoo] to ...`.
- Use square-bracket references for in-scope types, members, and parameters.
- Keep examples short and only include them when setup or embedding is not obvious.

## Avoid

- File-level doc comments or anonymous `library;` directives.
- Explaining what the widget draws instead of how it should be used.
- Listing every constructor field in prose when only a few affect behavior.
- Repeating the widget name or obvious UI facts.
- Writing long examples when one short integration hint is enough.
