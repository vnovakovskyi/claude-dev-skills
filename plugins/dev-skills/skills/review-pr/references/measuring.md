# Measure the numbers a finding rests on

Step 7 of the skill sends you here when a finding rests on a number from a
running system: a size, a rate, the count of distinct values, a share of the
traffic, a memory or connection limit. An estimate of such a number can be off
by an order of magnitude and turn a minor finding into a blocking one, or the
other way round.

- **Measure instead of estimating** when this session can read that system:
  its metrics, access logs, a sample of real data, a read-only request to a
  public endpoint. `../prod-evidence/references/sources.md` (from this skill's
  directory) lists the kinds of sources and the traps in each.
- **Only read.** Never write to a production system to get a number, and keep
  the load light: bounded windows, a handful of requests.
- **Aggregates only.** Download raw data into a new, empty folder in your
  scratch directory, reduce it to counts, and delete it as soon as you have
  them, when it holds personal data such as addresses or user ids.
- **Every number has a source:** the system, the query or command, and the
  time window. A derived number shows its arithmetic.
- **Ask for access early.** When a measurement needs access only the user can
  give (a sign-in, a VPN, a token), say so with the exact command as soon as
  you know it, not at the end: getting access can take them a while, and the
  review goes on meanwhile.
- **When you cannot measure it,** the finding stays `PLAUSIBLE` and says which
  measurement would settle it, as a command the user can run.
