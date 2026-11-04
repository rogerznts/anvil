# `study` — three worked examples

How `study` reads a screenshot the user admires, returns a diagnosis, and (optionally) hands the user's content to Hallmark to rebuild with the extracted DNA. Each worked example below shows: what the user pasted · what the skill names · what it refuses to do · what it produces.

The whole point of `study`: extract **structural DNA** (macrostructure + hero, nav and footer + type-pairing role + colour anchor + rhythm), **never pixels**. If the user wants a 1:1 copy, they want a different tool. `study` hands them a diagnosis and lets them keep the bones.

---

## Example A · A Pentagram-style editorial portfolio

**What the user pastes:** a screenshot of a New York studio's portfolio site — large italic-serif name in the top-left margin, numbered project list flowing down the page, generous warm-cream paper, a single warm-orange accent on the active project, a hairline rule between rows. (User says: *"I want my portfolio to feel like this.")*

### Refuse-or-proceed check

Public reference for inspiration → proceed. (Refusal heuristics fire on: paid-template-marketplace listings, copy-protected portfolios. None match.)

### Diagnosis report (what `study` returns first)

> **Macrostructure:** **Index-First** (numbered left-margin labels + huge italic serif + asymmetric spans + typographic-only CTA). It reads like a **Specimen**, but Hallmark keeps Specimen for type, publishing and writing; for a portfolio whose list is the page, the shape is Index-First.
>
> **Hero posture:** Index — the page's only anchor is a vertical column of two-digit indices: the list is the visual.
>
> **Sections:** none beyond the list. The work is the pitch.
>
> **Footer:** colophon — studio name, year, contact, three links on one line under a hairline, no nav.
>
> **Display family role:** italic editorial serif (high optical size, soft axis, ink-black). **Body family role:** geometric sans (humanist Inter-Tight-or-similar at 350-400 weight). Two free candidates: *Fraunces* italic display + *Geist* body. One paid candidate the user might confirm: *Tiempos Headline* + *Söhne*. The skill names *roles*, not exact font IDs — visual font ID is unreliable.
>
> **Surface lightness band:** light (paper L ≈ 96%). Slight warm tint at hue 80 — Pentagram-warm cream, not stark white.
>
> **Accent hue band + chroma:** warm-orange ~25-30°, low chroma (≤ 0.13), used at < 5% of viewport. One accent, applied to active state and the one number the brand wants the visitor to remember.
>
> **Density verdict:** sparse. ~3-4 macro elements on the first viewport. Generous vertical margin between rows (≥ `--space-3xl`).
>
> **Type-pairing role:** italic-display + sans-body — the canonical editorial pairing.
>
> **Three anti-patterns the screenshot has** that you should NOT carry over:
>
> 1. The hover-state on the number-label uses a slow ease-in-out 800 ms colour fade. Hallmark's motion rules put hover at about 220 ms, easing out. Carry the *idea* (colour-shift on hover); shorten the *duration*.
> 2. The footer text is set at 11 px with 0.06em tracking. Hallmark sets meta text one step under the body size and untracked: bump the size on rebuild and drop the tracking.
> 3. The indices are typed beside each title. Hallmark generates them from a real ordered list (`<ol>` with `counter()`), never as a typed number label; the column stays, the markup changes.

### Confirmation question

> *"Adopt this DNA wholesale, or change one axis? For example, I could keep the macrostructure (Index-First) but pick a catalog theme that better matches your work — if your tone is cooler and more B2B, I'd suggest **Ink** (white paper, a black with no hue, one teal) instead of the warm-oat **Specimen** theme."*

### What `study` hands to Hallmark when the user says "go"

`study` writes `design.md` at the project root (image mode, so no attestation question) and calls the Skill tool with `anvil-ui-hallmark`. The `## System` block:
```markdown
- Genre: editorial
- Shape of the first page: Index-First · hero: Index · nav: edge-aligned · footer: colophon
- Theme: custom (vibe: "quiet studio index, warm cream, one orange") · studied DNA, see Provenance
- Axes: light/roman-serif/warm · posture: restrained
```
`## Provenance` records `studied: yes · DNA-source: image (user reference)` and the font note: *paid fonts not confirmed — Tiempos Headline + Söhne substituted by Fraunces italic + Geist.* `## Notes` lists the three anti-patterns above.

Output, built by Hallmark: the user's actual portfolio entries arranged in a numbered-margin column with italic-Fraunces titles and Geist-body summaries. Hover at about 220 ms. Footer meta a step under the body, untracked. The bones come from the screenshot; the words and projects come from the user.

---

## Example B · A Klim-Type-Foundry-leaning specimen

**What the user pastes:** a screenshot of a type-specimen page — full-bleed black paper, single huge geometric-sans display character ("R") tilted -2°, a ruled grid behind it, a footer-band with the typeface name, weight, OpenType features, and a tiny set of glyph callouts. (User says: *"This is the energy I want for our agency rebrand.")*

### Refuse-or-proceed check

Type specimens are typically published references; proceed. (If the screenshot were a paid font foundry's marketing page with an explicit "preview is licensed" watermark, the skill would refuse and ask the user to bring an unconfirmed reference.)

### Diagnosis report

> **Macrostructure:** **Type Specimen** (single character or word centred + ruled grid + footer-band of metadata).
>
> **Hero posture:** Poster — the entire above-the-fold is one letterform on a full-bleed ruled canvas.
>
> **Sections:** none on the first viewport. The page is *the work being specified*. The pitch (if any) lives below the fold as supporting paragraphs.
>
> **Footer:** colophon block — the name, the weight, the OpenType features and the designer credit as one band of metadata.
>
> **Display family role:** geometric-sans-heavy (display-display, weights 800-900). **Body family role:** the same sans at 400 — Hallmark allows one family for both when the single font *is* the design. Free candidate: *Bricolage Grotesque 800*. Paid candidate: *Druk* or *NaN Jaune*. *Refuse to guess the exact paid font ID.*
>
> **Surface lightness band:** dark (paper L ≈ 12%). The dark is uniform across the viewport — no gradient.
>
> **Accent hue band + chroma:** chromatic-other — single hot-orange callout at ≈ 0.18 chroma, used on **one** OpenType-feature label. Even in a stark specimen, the rule "accent < 5% of viewport" holds.
>
> **Density verdict:** ultra-sparse. One element above the fold. Density only increases below.
>
> **Type-pairing role:** single-family specimen (single-font is the design). Body and display the same family at different weights.
>
> **Two anti-patterns the screenshot has** to NOT carry over:
>
> 1. The footer-band uses light-grey text (oklch ~75% lightness) on near-black paper. Contrast ratio ~3.2:1 — fails WCAG AA for body. Bump to oklch ~88% on rebuild.
> 2. The grid lines behind the glyph are at 1 px solid white at 0.4 opacity. On a 4K display this becomes a sub-pixel that disappears or aliases. Use 1 px solid + colour-mix down to 35% lightness instead — keeps visibility across pixel densities.

### Confirmation question

> *"This DNA is for a specimen page, not a marketing page. If you're rebranding an agency, the glyph hero will be impressive on the first visit and pointless after. Suggested adaptation: Type Specimen as the homepage, then a Long Document or Workbench pattern for the about / case-studies / contact pages. Pick: keep all-Specimen, or hybrid?"*

### What `study` hands to Hallmark (hybrid path)

`study` writes `design.md` at the project root and calls the Skill tool with `anvil-ui-hallmark`, asking for the homepage and the inner pages. The `## System` block:
```markdown
- Genre: editorial
- Shape of the first page: Type Specimen · hero: Poster · nav: edge-aligned · footer: colophon block
- Theme: custom (vibe: "one glyph, ruled black field, hot orange") · studied DNA, see Provenance
- Axes: dark/grotesk-heavy/warm · posture: restrained
```
`## Provenance` records `studied: yes · DNA-source: image (user reference)` and *paid fonts not confirmed — Bricolage Grotesque 800 substituted for Druk*. `## Notes` lists the two anti-patterns above.

Output, built by Hallmark: the homepage emits the agency's mark in 22-rem Bricolage 800, ruled grid behind, metadata colophon footer. The about and case-study pages share the locked dark-paper + geometric-sans system but switch to the **Workbench** macrostructure. Hallmark's own rule for a locked `design.md`: pages share theme, type and accent and differ only in shape. Brand consistency, structural variety.

---

## Example C · A small-studio personal site (Rauno-Freiberg-style)

**What the user pastes:** a screenshot of a personal designer-engineer site — dark-mode paper, a small italic-serif name in the top-left, a single demo embed at the centre (CSS-art clock that ticks), a writing list below. (User says: *"I want my own personal site to feel like this.")*

### Refuse-or-proceed check

An ambiguous source is the edge case here. Per `study.md` § Refusal heuristics: when you can't tell whether the source is the user's own work or someone else's, ask first.

> *"Is this your own work, a public reference for inspiration, or someone else's live site? If it's someone else's live site, I'll extract the DNA at the structural level only — no copy, no demos, no font IDs — and you'll bring your own content. If it's a paid portfolio template, I won't reproduce it."*

User confirms: public reference for inspiration → proceed with DNA extraction only.

### Diagnosis report

> **Macrostructure:** **Long Document** with a centred demo leading the hero.
>
> **Hero posture:** Corridor, led by the demo — a single hand-built artefact (CSS art, SVG illustration, declarative animation) sized at ~24 rem, centred on the page, no other hero copy above it.
>
> **Sections:** Index — a list of writings, title + date + 1-line summary, in a tabular column.
>
> **Footer:** colophon.
>
> **Display family role:** italic editorial serif. **Body family role:** geometric sans, body weight 400. Free candidate pairing: *Fraunces* italic + *Geist*.
>
> **Surface lightness band:** dark (paper L ≈ 16%). Slight cool tint at hue 240. Inks at ~90-95% L, also slight cool.
>
> **Accent hue band + chroma:** chromatic-other — green at hue 145, ≈ 0.14 chroma. Used on the active demo's signal element (the ticking dot), nowhere else.
>
> **Density verdict:** sparse-medium. Hero demo + ~12-line writing list above the fold.
>
> **Type-pairing role:** italic-display-with-sans-body — same as Specimen, just on dark paper.
>
> **One anti-pattern the screenshot has** to NOT carry over:
>
> 1. The CSS-art clock loops at 1 fps with no `prefers-reduced-motion` fallback. **Always pair declarative animation with a reduced-motion alternative** — Hallmark's Floor makes it non-negotiable, and every loop stops under reduced motion and off-screen.
>
> One thing the screenshot does *better than most* and you SHOULD carry over:
>
> 1. The italic name in the top-left has a baseline at the same y-position as the centred demo's vertical centre — a subtle horizontal-baseline alignment that makes the page feel composed rather than stacked. Carry this; it's invisible until removed.

### Confirmation question

> *"The DNA is portable: dark paper, italic-Fraunces name, centred demo, cool-green accent. Two questions before I build: (1) what's your demo? — Hallmark can hand-build it in CSS if you describe it, or you can paste an existing animation. (2) do you have ~5 writings to seed the list, or should I leave a placeholder section?"*

### What `study` hands to Hallmark when the user provides their own demo + writings

The source is a public reference, not the user's own site, and the capture is a screenshot: image mode, so `study` writes `design.md` without the URL-mode attestation and calls the Skill tool with `anvil-ui-hallmark`, passing the demo description and the writings. The `## System` block:
```markdown
- Genre: atmospheric
- Shape of the first page: Long Document · hero: Corridor · nav: edge-aligned · footer: colophon
- Theme: custom (vibe: "quiet dark notebook, one ticking green") · studied DNA, see Provenance
- Axes: dark/roman-serif/chromatic-green · posture: restrained
```
`## Notes` carries the reduced-motion anti-pattern and the baseline alignment worth keeping.

Output, built by Hallmark: the user's actual name in italic-Fraunces top-left, their demo (e.g. an ambient breathing-loop) hand-built as CSS art with an explicit `@media (prefers-reduced-motion: reduce)` fallback, their writings tabulated below in Geist body. The bones from the screenshot; the demo and writings from the user. **No pixel-faithful reproduction.**

---

## What `study` doesn't do (worth restating)

1. **Names the font role, not the font ID.** Visual font identification is unreliable. The skill proposes one or two real candidates from the canon and asks the user to confirm.
2. **Never copies pixels.** The DNA is the macrostructure + hero, nav and footer + colour-anchor + type-pairing — not the dress.
3. **Refuses the obvious bad sources.** Paid-template-marketplace listings; copy-protected portfolios without permission.
4. **Always disclosures the substitutions.** When the screenshot's font is paid (Tiempos / Söhne / Druk) and the user hasn't confirmed a licence, the skill names a free understudy (Fraunces / Inter Tight / Bricolage Grotesque) and *says it's substituting*.

These three examples cover the most common categories of `study` request: an editorial portfolio, a type-specimen statement page, and a small personal site. The protocol is the same for every screenshot — refuse-or-proceed, diagnose, confirm, build. See [`study.md`](study.md) for the full protocol.
