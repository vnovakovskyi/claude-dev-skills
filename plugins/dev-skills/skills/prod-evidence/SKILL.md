---
name: prod-evidence
description: Get a number from a running system instead of estimating it — a size, a rate, a latency, a count of distinct users or pages, a share of traffic, how full a store is — read-only, from metrics, traces, logs, load-balancer access logs, the store's own statistics, or a few read requests to a public endpoint. States where every number came from, the time window, the arithmetic, and the caveats; keeps aggregates only and deletes downloaded personal data. Never writes to a production system. Use when a question, a review finding, a plan, or an incident depends on how big, how often, or how many in production, or when the user asks to measure or check something in prod.
argument-hint: '<the number or question to measure; optional: the system and the time window>'
allowed-tools: Read, Grep, Glob
---

# Measure it in the running system

You are running the **Measure it in the running system** skill.

User request:

`$ARGUMENTS`

## Purpose

Replace an estimate with a measurement. A review finding, a capacity question,
or a design choice often rests on one number: how big a value is, how many
distinct keys a day brings, what share of the traffic is bots, how full a store
already is. An estimate of that number can be off by an order of magnitude and
turn a minor point into a blocking one, or the other way round.

The user gets the number, how it was measured, and how sure it is, in a form
they can repeat.

## Hard rules

- **Read only.** Never write to a production system to get a number: no
  configuration change, restart, scaling, cache flush, test record, or request
  that changes state. A read request to a public endpoint is fine; a mutation
  is not, whatever the endpoint calls it. Commands that only list, describe,
  or fetch metrics and logs are fine.
- **Light on the system.** Bound every query by a time window and a limit.
  Prefer metrics that already exist over generating load. Send a handful of
  sample requests, one after another, never a loop against production. Do not
  run heavy statistics commands on a primary under load when a replica or a
  metric answers the same question.
- **Access comes from the user.** Never enter credentials. When a source needs a
  sign-in, a VPN, or a token, tell the user exactly what to run as soon as you
  know it, and go on with what you can do meanwhile.
- **Aggregates only.** Data that names people — addresses, user ids, emails,
  session ids, request bodies — never goes into the chat, a file, or the
  knowledge base. Download raw logs only into a new, empty folder in your
  scratch directory, reduce them to counts, and delete them as soon as you have
  the counts. Say that you did.
- **Every number has a source.** The system, the query or command, the time
  window, and the time zone. A number you derived shows its arithmetic. A
  number you did not measure — an instance type's memory from the provider's
  documentation, a library default — is marked as general knowledge.
- **Measured, derived, and assumed stay apart.** A measured value is not
  rounded into an assumption, and an assumption is not presented as measured.

## Step 1 — Pin down the number

Restate in one line what is to be measured:

- **the quantity and its unit:** bytes per entry, requests per second, distinct
  keys per six hours, the 95th percentile in milliseconds;
- **the population:** which service, tenant, endpoint, or kind of client —
  people and bots are different populations;
- **the window:** which hours and days are representative, peak and quiet;
- **the decision it feeds,** and how precise it must be for that decision. "Does
  it fit in 1 GB" needs a range, not three decimals.

When the question can be read in very different ways, ask one short question;
otherwise take the most likely reading and say which one.

Search the knowledge base first, as `../../references/knowledge-base.md` (from
this skill's base directory) describes: earlier cases and codebase notes often
hold the access recipe, the dashboard, or a past value of the same number.

## Step 2 — Choose the sources

Pick the cheapest source that answers the question, and a second one to check
it against when the decision is expensive. `references/sources.md` lists the
kinds of sources, what each answers well, and the traps in each. In short:

1. the knowledge base and earlier measurements;
2. metrics that already exist (the service's own, the platform's, the cloud
   provider's);
3. traces and the metrics derived from spans;
4. logs: application logs and the access logs of load balancers and CDNs;
5. the store's own statistics, through read-only commands;
6. a few read requests to a public endpoint, sent the way the real client sends
   them;
7. code and configuration, for limits and settings.

Check access to each before you plan around it. When it is missing, say what
the user has to run.

## Step 3 — Measure

- Run the smallest query that gives the number. Look at the size of a log set
  before you download it, and take only the window you need.
- Keep the raw output out of the conversation: aggregate in the command or in a
  short script, and print only the counts.
- Record each command and query as you go, with its window.
- When you send requests to an endpoint, read the client's code first for the
  address and the headers it needs, and request only what the real client
  requests.

## Step 4 — Check the number

- **Units and scale:** bytes against bits, per second against per minute, a
  percentage of what.
- **A second source** when one exists: the metric against the logs, a sample
  against the total.
- **Bias:** bots and crawlers, health checks, cached responses that never reach
  the service, one tenant that dominates, a quiet day chosen by accident.
- **Coverage:** what share of the population the sample covers, and what it
  leaves out.

## Step 5 — Derive and answer

Combine the measured values into the answer the decision needs, with the
arithmetic shown and a low–high range where an input varies. Then clean up:
delete downloaded data and temporary files.

Answer in the chat in the language of the request:

```md
**Question:** <the number, in one line, as you understood it>

**Answer:** <the number or range, and what it means for the decision, in 1–3 sentences>

**Measured**
| Value | Source | Query or command | Window |
|---|---|---|---|
| <value> | <system> | <short form, full in "To repeat"> | <from–to, time zone> |

**Derived:** <the arithmetic, with the range>

**Caveats:** <bias, coverage, one-day samples, values not measured>

**Not measured:** <what you could not reach, and what would settle it>

**To repeat:** <the commands, ready to run>

**Cleaned up:** <what was downloaded and deleted, or "nothing downloaded">
```

## Saving

When a case in the knowledge base covers the subject, write the measurement to
`evidence-<YYYY-MM-DD>-<subject>.md` in that case, in English, in the shape
above, and add one line to the card's findings. Otherwise save only when the
user asks. A reusable access recipe — where a system's metrics or logs live and
how to reach them — is worth a line in the knowledge base too. Never save
personal data, credentials, or raw log lines. Rebuild the index as the
reference describes.

## Completion criteria

The skill is complete only when:

- The user has the number, or a clear statement of what could not be measured
  and what would settle it.
- Every value names its source, query, and window; derived values show their
  arithmetic; general knowledge is marked as such.
- Nothing was written to a production system, and downloaded data is deleted.
