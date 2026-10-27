# Checklists by kind of change

Step 5 of the skill sends you here when the pull request adds or changes one of
the kinds below. Each list holds the questions that kind of change gets wrong
most often. Answer them against what Step 4 found: the inputs the result
depends on, every path that reaches the changed code, and the life of the data.
A question that does not apply is skipped; one you cannot answer from the code
is named in the result, with what would settle it.

## A cache

- **The key.** Is every input the result depends on in the key: the fields of
  the objects passed in, the tenant, the locale, the user or role, the version
  of the source? Does every path that reaches the cached code pass inputs that
  give the same result for the same key? A path that builds its input another
  way — another loader, a test-only query, a default value — can write a wrong
  entry that everyone then reads.
- **Who may see it.** Can a value cached for one user, role, or tenant be served
  to another?
- **What gets cached on failure.** Errors, timeouts, partial results, empty
  results. An empty result produced while the source is still being written —
  indexing lag, replication lag, eventual consistency — stays wrong for the
  whole time to live.
- **The round trip.** Is every type that can be stored read back equal, with
  the shapes real data has: polymorphic types and their type ids, ignored or
  computed fields, nulls, the biggest value? A value that can be written but not
  read becomes a permanent, silent miss when read errors are treated as misses.
- **Staleness.** What changes the source, and how long do readers see the old
  value? Deleted or renamed things that cached values still link to?
- **Size and neighbours.** Distinct keys per time to live on real traffic,
  times the size of a value, against the store's memory and eviction policy.
  Who else uses the store, and whose keys does the policy push out when it is
  full?
- **When the store fails.** The timeout on the request path: a slow cache can
  cost more than it saves. What happens when the store is down at startup and
  when it goes down at runtime. Do health checks or probes now depend on it?
- **Concurrency.** Many misses for one key at once. A lock that holds only
  inside one process while several run.
- **Deploys.** Entries written by the previous version when the shape of the
  value changes.

## A schema or data migration

- **Order against the release.** Old code on the new schema and new code on the
  old schema both run during a rolling deploy. Does each work?
- **Existing rows.** Defaults, nulls, the backfill, and how long it locks a big
  table.
- **The way back.** Can it be rolled back? Is a destructive step (drop, rename,
  narrowing a type) separate from the code that stops using the old shape?
- **Who applies it, and where.** Automatically on start, by a job, or by hand;
  in which environments; what happens when it runs twice.
- **Queries.** Indexes for the new queries; long locks from building them.

## A message producer or consumer

- **Duplicates.** Is handling the same message twice safe?
- **Order.** Does anything assume an order the broker does not guarantee?
- **Failure.** Retries, the dead-letter path, and a message that always fails.
- **The write and the publish.** Are they in one transaction, or can one happen
  without the other?
- **Compatibility.** Consumers still on the previous version of the message;
  producers still on the previous version during a deploy.

## An endpoint or its authorization

- **Who can call it.** Authentication, authorization per object (can a caller
  reach another user's or tenant's data by changing an id?), and whether it is
  reachable from outside when it should not be — test-only, admin, and internal
  operations included.
- **Input.** Validation, size limits, and what an oversized or malformed input
  does.
- **Output.** What errors and logs reveal: personal data, internals, secrets.
- **Load.** What one call costs, and what many calls in a row cost.

## A call to an external service

- **Timeouts.** Connect and read timeouts set, and short enough for the path it
  is on.
- **Retries.** Backoff, a limit, and no retry of a call that is not safe to
  repeat.
- **Failure.** What the user or the caller sees when the service is slow or
  down; whether a circuit breaker or a fallback is needed.
- **Clients and credentials.** A client or a token created per call instead of
  reused; tokens cached until they expire.
- **Where it runs.** On the request path, or somewhere the latency does not
  reach a user.
