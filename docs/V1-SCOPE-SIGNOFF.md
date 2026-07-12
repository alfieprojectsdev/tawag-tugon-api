# Tawag-Tugon V1 — Scope Sign-Off

**For:** Chris "Ayok" Uybengkee<br>
**From:** Alfie Pelicano<br>
**Purpose:** Lock the Version 1 scope so build work can move without stalling on
open questions. Full technical detail lives in `TECH-SPEC.md` and `README.md` in
the project repo — this document is the short version, for decisions only.

**How to use this doc:** for each item below, mark one box and add any detail in
the notes line. "Revise" means "close, but change X" — please say what X is.
Send it back (or just reply per item over chat/email) and we lock it in.

---

## Why this matters

The engineering side already trimmed the build down to a minimal V1 based on
what you asked for — one app, one LGU, offline speed-dial directory, local
news, simple admin. That trim is documented and ready. What's blocking faster
progress now is a short list of decisions only you can make: the target LGU,
the assets, and a few scope calls. Nothing below requires technical knowledge
to answer.

---

## 1. Final app name

"Tawag-Tugon" is a working title only — never approved as final.

- [ ] **Approve** — keep "Tawag-Tugon" as the name.
- [ ] **Reject / Revise** — final name is: ______________________

*Why it matters: branding assets (icon, splash screen, app store listing) get
built against whatever name we lock now. Changing it later means redoing those.*

---

## 2. First real LGU (the one we build and demo)

We need ONE actual city/district to build the real V1 around — not a demo
placeholder. Quezon City has been used for test data so far, but that was our
placeholder, not a confirmed target.

- [ ] **Approve** — Quezon City is the target. Contact/coordination point: ______________________
- [ ] **Revise** — different LGU: ______________________. Contact/coordination point: ______________________

*Why it matters: this is the single biggest blocker right now. Everything else
(real numbers, branding, the demo itself) depends on knowing which LGU.*

---

## 3. Branding assets for that LGU

Needed from you / your daughter before we can build the branded demo:
- App icon
- LGU logo/seal
- Brand color(s)

- [ ] **Approve** — will deliver by: ______________________ (date)
- [ ] **Revise** — need help with: ______________________

---

## 4. Real content for that LGU

Needed: verified emergency contact numbers (barangay, police, fire, nearest
hospital — with the right phone/Viber number for each) and 2-3 sample
announcements to seed the news feed.

- [ ] **Approve** — will deliver by: ______________________ (date)
- [ ] **Revise** — notes: ______________________

*Why it matters: a demo with fake numbers doesn't land with a mayor. This has
to be real before we show it to anyone.*

---

## 5. Branding approach: locked vs. dynamic

Two ways to handle "one app, many LGUs":
- **Per-LGU locked (recommended):** each LGU gets its own build — swap the
  config, rebuild, done. Simple, ships now.
- **GPS-based dynamic branding:** one install auto-detects location and
  re-skins itself. More impressive, meaningfully more engineering work, not
  needed to prove the concept to a mayor.

- [ ] **Approve** — per-LGU locked for V1 (recommended)
- [ ] **Revise** — want dynamic branding in V1: ______________________

---

## 6. "Messenger contact" — what does that actually mean?

You mentioned Viber and Messenger. Two options:
- **Phone + Viber only (recommended for V1):** covers how almost all local
  responders (barangay, police, fire) actually take calls.
- **Per-responder Messenger (`m.me`) links too:** more channels, more setup
  per contact, marginal benefit since most responders aren't on Messenger.

- [ ] **Approve** — phone + Viber only for V1
- [ ] **Revise** — need Messenger links too: ______________________

---

## 7. How LGU staff update numbers/announcements

For V1, staff need *some* way to edit contacts and post announcements without
calling a developer:
- **Built-in admin panel (recommended):** ships fastest, functional today,
  looks like a technical tool rather than a polished app screen.
- **Simple custom web form:** friendlier for non-technical staff, adds build
  time before we're demo-ready.

- [ ] **Approve** — built-in admin panel is fine for V1 demo purposes
- [ ] **Revise** — need the simpler web form before demo: ______________________

---

## 8. Confirm what's OUT of V1

To hit "working demo, fast," these are deliberately **not** being built yet.
None of them are required to show a mayor a working app:

| Deferred | Why it's fine to wait |
|---|---|
| Push notifications | App checks for updates when opened; good enough for V1 |
| Device-to-device / mesh networking (for total signal blackout) | Real feature, heavy engineering, not what you originally asked for |
| National weather/hazard data feeds (PAGASA/PHIVOLCS) | You asked for local barangay news, not national feeds |
| Automatic scraping of LGU websites for news | Staff post announcements manually for V1 — still meets "update without a developer" |
| Supporting many LGUs at once | We prove it works with ONE LGU first |

- [ ] **Approve** — agreed, none of this blocks the mayor demo
- [ ] **Reject / Revise** — one of these is actually needed now: ______________________

---

## 9. Funding/rollout model

You mentioned funding comes per barangay-cluster or per city, with different
budgets per locality. For V1 this doesn't change anything technical — we're
building one locked app for one LGU. Just confirming that's understood and
this decision doesn't need to be made yet.

- [ ] **Approve** — correct, no V1 impact, revisit at rollout stage
- [ ] **Revise** — notes: ______________________

---

## Sign-off

Once the above is marked, V1 build proceeds against locked scope — no further
scope questions until the demo is ready to show.

**Name:** ______________________<br>
**Date:** ______________________<br>
**Signature / confirmation (email reply is fine):** ______________________
