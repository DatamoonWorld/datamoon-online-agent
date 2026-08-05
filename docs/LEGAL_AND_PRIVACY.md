# Legal And Privacy

## Canonical Public Documents

The canonical player-facing documents are published by `datamoon-online-web`
at `/terms` and `/privacy`. Do not duplicate their full text in the Client or
game services. The Client may summarize a requirement and link to the Web.

Current versions:

- Terms: `beta-1.0`, effective 2026-08-05.
- Privacy notice: `beta-1.0`, effective 2026-08-05.
- Controller: Gabriel Requena, Sao Paulo/SP, Brazil.
- Privacy contact: `datamoon.game@gmail.com` or a support ticket in the
  `privacy` category.

These drafts must receive legal review before a commercial release. Purchases
are disabled during this Beta; commerce, refund and withdrawal terms must be
published and accepted before enabling paid Coins, passes or cosmetics.

## Beta Eligibility

The Beta is restricted to users aged 18 or older. Registration and migration of
an existing account require:

- a birth date that establishes age 18+ at the time of acceptance;
- explicit Terms acceptance;
- explicit Privacy Notice acknowledgement.

The birth date is validated but not persisted. The database stores only the
adult confirmation timestamp, accepted document versions and UTC acceptance
timestamps. This data-minimization decision must not be weakened without a
documented need and privacy review.

## Authority And Enforcement

- Web presents the documents and collects consent.
- MySQL API is the authority for age confirmation and document versions.
- Auth maps the API result into a stable login result.
- Gateway relays the result and never decides eligibility.
- Client blocks entry and directs the player to `/legal-acceptance`.
- Game Server receives no gameplay ticket until the legal gate passes.

When either current version changes, existing accounts become pending again
until they accept the new version. Never rely only on a Web cookie or Client
flag for this decision.

## Retention

- Web sessions: up to 12 hours.
- Operational journald logs: normally 7 days and 200 MB on the PBE VM.
- Economic and administrative audits: 180 days.
- Closed support tickets and their messages/events: 12 months after closure.
- Active account and game data: while the account remains active, plus any
  period required for security, legal obligations or exercise of rights.

Account deletion is requested through authenticated support under `privacy`.
The intended workflow requires email confirmation, allows cancellation for 7
days and targets completion within 30 days, except data under mandatory or
defensible retention. Until the automated deletion workflow exists, support
must handle the request manually and record only the public ticket ID in logs.

## Beta Wipe

The end-of-Beta wipe may remove characters, Datamoons, progress, inventory and
currencies. Preserve only the account and eligibility for the commemorative
Beta package unless a later documented decision changes this scope.

## Release Validation

Manually validate registration for adult and underage dates, existing-account
acceptance, refusal to issue a game ticket before acceptance, login after
acceptance, document links, support privacy category and reacceptance after a
version change. Never log birth dates, passwords, tokens or acceptance form
contents.
