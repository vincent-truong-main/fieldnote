# Fieldnote Billing — Domain Model (working notes)

Consolidated from an event-storming-lite discovery session. This is a snapshot of decisions made so far, not a finished spec — open questions are marked at the bottom.

## Business vision (the stakeholder brief)

- **Product:** Fieldnote — a lightweight CRM for solo/small-team service businesses (photographers, consultants, freelance devs). Their own clients never touch the billing system being modeled here; billing is Fieldnote charging *its* customers.
- **Buyer:** Not sophisticated software buyers — usually switching from a spreadsheet or notes app. One or two people, sometimes a small team.
- **Stage:** Series A, growing, self-serve-led. Sales only gets involved for Team-plan accounts or churn-risk discount conversations — there's no sales gate between signup and revenue for most customers.
- **Stated priority:** low friction everywhere in the funnel — signup, reactivation, upgrades. This has repeatedly won out over "squeeze more revenue at this one step" arguments during discovery (see the Locked-state and pre-filled-plan decisions below).
- **Countervailing pressure:** finance wants better trial-to-paid conversion and dislikes unbounded ghost trial accounts sitting in limbo forever.
- **Revenue model:** subscription only — no usage-based add-ons, no marketplace cut. This billing engine effectively *is* the company's cash flow.
- **Plans (given, not yet fully modeled):** Starter, Pro, Team — monthly and annual. Team is per-seat; Starter/Pro are flat. No free tier currently exists in the plan lineup (relevant to the Locked-state design below).

## How to resume this session

If picking this back up cold: re-read "Business vision" and "Not yet modeled" below, then continue the event-storming-lite technique — narrate the next customer-timeline event in plain English (failed payment / dunning is the natural next thread), turn it into a Given/When/Then, and update this doc's Events and Not-yet-modeled sections as decisions get made.

## Problem space decomposition

- **Core domain:** Billing / Subscription engine — the rules, the cash flow, where the risk and complexity live.
- **Supporting subdomain:** Internal ops dashboard (support view/fix billing).
- **Supporting subdomain:** Customer-facing billing page (invoices, card, plan changes).

## Entities

- **Customer** — the service business paying for Fieldnote.
- **Subscription** — one per Customer, carries the state machine below. Created once, at trial start — not recreated later.
- **Plan** — Starter, Pro, Team. Starter/Pro flat-priced, Team per-seat. Monthly or annual.
- *(Open: Payment Method — currently assumed to live inside Customer rather than as its own entity. Not finalized.)*

## Subscription states

```
Trialing → Locked → Active
```

- **Trialing** — 14-day trial, no card required to enter.
- **Locked** — trial expired without a card on file. Data is visible (read-only) but not editable — no new clients, no new bookings. Chosen over hiding data entirely or freezing the account, for two reasons: (1) lower friction to reactivate — no support ticket needed to get back in, and (2) loss aversion — seeing frozen real data converts better than a blank screen.
- **Active** — paying customer, full access.

## Events / Scenarios (BDD style)

**Trial starts**
```
Given a visitor is on the signup page
When they select the Pro plan and submit
Then a Subscription is created in Trialing state
```

**Trial expires without a card**
```
Given a Subscription is in Trialing state
When the 14-day trial period ends and no payment method is on file
Then the Subscription moves to Locked state
```

**Customer reactivates from Locked**
```
Given a customer's Subscription is in Locked state, with their original plan pre-filled and editable
When the customer confirms the plan and adds a payment method
Then the existing Subscription transitions to Active state
```
(Plan is pre-filled from their original selection rather than forcing a fresh choice — resolves a tension between "maximize revenue by making them re-choose" and the low-friction product philosophy; pre-fill-but-editable satisfies both.)

## Business context / constraints behind these decisions

- Self-serve is the primary acquisition channel; low friction at every step is a stated product priority.
- Finance cares about trial-to-paid conversion, wants to avoid unbounded "ghost" trial accounts.
- Billing is the company's only revenue line (subscription-only, no usage/marketplace revenue).

## Not yet modeled

- Seats (Team plan add/remove mid-cycle, fair billing)
- Plan upgrade/downgrade mid-cycle (proration)
- Sales-comped custom discounts
- Failed payments, retry logic, dunning (must not lock out mid-workday)
- Cancellation and resume-a-month-later flow
- Whether Payment Method is its own entity
