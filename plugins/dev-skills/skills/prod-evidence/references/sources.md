# Sources of numbers in a running system

Step 2 of the skill sends you here. Each kind of source below says what it
answers well, how to read it without load or writes, and where it misleads.
Tool names are examples; use whatever the system runs.

## The knowledge base and earlier measurements

Earlier cases and codebase notes often hold the dashboard, the log location,
the sign-in step, or a past value of the same number. A past value tells you
the order of magnitude and whether something changed; re-measure it before a
decision rests on it.

## Metrics that already exist

The service's own metrics, the platform's (a Prometheus-compatible store,
Grafana, Datadog), and the cloud provider's (CloudWatch, Azure Monitor, Google
Cloud Monitoring).

- **Good for:** rates, latencies, error counts, memory and connection use,
  history over weeks.
- **How:** a range query with a fixed window and step; `rate` over counters,
  quantiles from histograms; for a managed store, the provider's metrics for
  each node (memory used, items, evictions, connections). A dashboard's
  datasource can often be queried directly through the same login.
- **Traps:** an average hides the tail; one aggregate mixes very different
  requests (one endpoint can be most of the traffic and hide a slow one); a
  percentage needs its base, and the base is often in the provider's docs
  rather than a metric. When both are available, derive the limit from a value
  and its percentage (used bytes ÷ used %) instead of trusting a table. Memory
  reserved by the provider and the eviction policy live in the store's
  configuration, not in its metrics.

## Traces and span metrics

Tempo, Jaeger, X-Ray, and the metrics derived from spans.

- **Good for:** where the time of one kind of request goes; the latency of a
  dependency by caller; the share of requests that take a slow path.
- **How:** search by operation name and a duration threshold; span metrics
  grouped by an attribute.
- **Traps:** sampling, so counts from traces are not request counts; the
  attribute you need (an id, a slug, a query variable) is often not recorded,
  and then access logs answer instead.

## Logs

Application logs (Loki, Elasticsearch, CloudWatch Logs) and the access logs of
load balancers and CDNs, often kept as compressed files in object storage.

- **Good for:** counts of distinct things (pages, keys, clients), the split by
  client type, what a metric does not label.
- **How:** count in the log store when it can (`count_over_time`, `topk`, a
  terms aggregation). For files in object storage: list the window and its
  total size first; download only that window into a new, empty folder in your
  scratch directory; stream the files through a parser that keeps only the
  fields you need; aggregate; delete the folder.
- **Traps:** the files are per node and per few minutes, so a day can be
  hundreds of files; paths come URL-encoded, sometimes double-encoded, and with
  trailing whitespace from the line, so normalize before you count distinct
  values; bots and crawlers can be most of the traffic, so split by user agent
  (a heuristic: names containing bot, crawl, spider, slurp, and the major search
  and AI crawlers, plus HTTP libraries) and say that the split is approximate;
  health checks and monitoring add steady noise. Addresses and user agents are
  personal data: count them, never copy them out.

## The store's own statistics

Read-only commands of the database, cache, index, or queue: table and index
sizes, row counts, memory per key, index document counts, queue depth.

- **Good for:** the real size of what is stored, the number of entries.
- **How:** describe and list calls of the cloud provider for the store's type,
  size, and configuration; the store's statistics views or info commands from
  a read-only session; a replica rather than the primary when the command is
  heavy.
- **Traps:** a statistics view can lag; a command that scans all keys or rows
  is load, not a read — use a sample or the store's own counters.

## A few requests to a public endpoint

- **Good for:** the size and shape of a real response, the latency a client
  sees, whether an operation is reachable from outside.
- **How:** read the client's code for the address, the headers it sends (a
  tenant, a locale, a product or experience header), and the fields it asks
  for; send a handful of read requests, one at a time, for typical and large
  items; measure sizes in the encoding that will be stored.
- **Traps:** what the endpoint returns is not always what the service stores —
  fields can exist in the code but not in the schema, or the other way round;
  say how the measured response differs from the stored value. A response may
  come from a cache in front of the service. Never send a mutation.

## Code and configuration

- **Good for:** limits, timeouts, pool sizes, time to live, instance types, the
  settings a number depends on.
- **Traps:** configuration in the repository can differ from what is deployed;
  confirm the deployed value through the provider's describe calls when the
  decision depends on it. The capacity of an instance type comes from the
  provider's documentation: mark it as general knowledge unless an API returned
  it.

## Access

- Sign-in sessions often expire per account or per environment separately:
  access to one environment says nothing about another.
- Ask for the sign-in the moment you know you need it, with the exact command,
  and go on with what you can reach.
- Note in the knowledge base where a system's metrics and logs live and how to
  reach them, so the next measurement starts there.
