# UI And Design Rules

This file contains general visual design guidance that is not tied to one
specific Flutter API.


## Visual Design
- Build interfaces that are clear, calm, and intentional.
- Ensure responsive behavior across supported sizes.
- Make navigation discoverable and predictable.
- Use typography hierarchy to guide attention.
- Use backgrounds, shadows, and icons deliberately rather than decoratively.
- Interactive elements should be legible, reachable, and visually obvious.
- For product and CRM surfaces, prioritize dense, scannable, task-first layouts over marketing-style composition.
- Prefer existing `packages/ui` components, tokens, icons, spacing, and theme extensions before adding local visual variants.
- Avoid nested cards, decorative panels, ornamental gradients, glow effects, glassmorphism, novelty palettes, and generic SaaS styling when they reduce scanning or conflict with the app.
- Pressed, selected, loading, disabled, and error states should not shift layout bounds or move neighboring content.


## Color Scheme
- Meet WCAG 2.1 contrast requirements.
- Minimum contrast:
  - normal text: **4.5:1**
  - large text: **3:1**
- Maintain clear primary, secondary, and accent hierarchy.
- Use complementary colors sparingly for accents, not for long text or base surfaces.
- Check light and dark themes independently; do not infer one from the other.
- Use semantic theme colors and `UIColors` instead of hard-coded per-screen colors.
- Do not convey state with color alone; pair it with text, iconography, shape, or placement.


## Typography
- Prefer one or two font families.
- Prioritize readability over visual novelty.
- Use size, weight, color, and spacing to establish hierarchy.
- Typical line height for body text: **1.4x to 1.6x** font size.
- Prefer body line lengths in the **45-75** character range.
- Avoid all caps for long text blocks.
- Long localized text, user names, service titles, prices, and dates must wrap, truncate, or disclose predictably without covering controls.
- Accessible labels should be concise and action-first. Do not duplicate role words that the platform already announces.


## Accessibility And Interaction
- Prefer native Flutter controls with built-in semantics before adding custom `Semantics` wrappers.
- Icon-only controls need localized semantic labels that distinguish repeated actions by target when necessary.
- Focus order should follow visual and reading order, and focus indicators must be visible.
- Keep focus and selected state visually distinct for tabs, filters, chips, lists, segmented controls, and toolbars.
- Every function must be reachable through visible controls and focus traversal; shortcuts may enhance but not replace navigation.
- Touch targets should remain reachable and stable across normal, pressed, loading, disabled, and selected states.
- Modal sheets, pickers, dialogs, loading overlays, and nested navigation must provide a clear exit path.
- For Cupertino contextual menus, prefer `CupertinoMenuAnchor` over `PullDownButton`.
- When migrating an existing `PullDownButton`, preserve current labels, icons, haptic feedback, selected-state affordances, and action handlers instead of redesigning the interaction.


## UI Hardening
- Check representative messy data before calling a non-trivial UI flow complete: empty lists, single-item lists, large lists, long names, long localized copy, huge amounts, missing optional fields, permission-denied states, network failures, validation errors, and retry paths.
- Fixed app bars, bottom bars, sheets, and CTA regions must respect safe areas and must not cover scrollable content.
- For large lists or frequently updating surfaces, prefer lazy lists and stable item dimensions to reduce jank.
- Extract shared UI primitives into `packages/ui` only after the same-intent pattern appears repeatedly; do not create abstractions for hypothetical reuse.