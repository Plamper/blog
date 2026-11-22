#import "@tola/address:0.0.0": join-route, output-of, slugify
#import "@tola/schema:0.0.0": parse, timestamp
#import "@tola/site:0.0.0": site
#import "@tola/source:0.0.0": parse-sources
#import "schema.typ": post-schema

/// Convert a parsed `date` (`datetime`) or `timestamp` (dictionary) into a `timestamp` record.
#let as-timestamp(value) = {
  if type(value) == dictionary {
    value
  } else {
    parse(value, timestamp)
  }
}

/// Convert a parsed `date` (`datetime`) or `timestamp` (dictionary) into a calendar `datetime`.
#let as-date(value) = {
  if type(value) == datetime {
    value
  } else {
    let parts = value.rfc3339.slice(0, 10).split("-")
    datetime(year: int(parts.at(0)), month: int(parts.at(1)), day: int(parts.at(2)))
  }
}

/// Format a date as `YYYY-MM-DD` (for terminal lists).
#let format-iso-date(value) = as-date(value).display("[year]-[month]-[day]")

/// Format a date as `Month DD, YYYY` (for post headers).
#let format-long-date(value) = as-date(value).display("[month repr:long] [day padding:zero], [year]")

/// The decoded site-root route a source publishes at.
#let source-route(source) = {
  if source.meta.permalink == none {
    join-route(source.route-segments.map(segment => slugify(segment, language: site.language.lang)))
  } else {
    source.meta.permalink
  }
}

/// Select all published blog posts under `content/blog/`, sorted newest-first.
///
/// - sources (array): complete source records from `all-sources()`.
/// -> array of `(source:, output:, published-ts:)` records
#let select-posts(sources) = {
  let blog-sources = sources.filter(source => (
    source.route-segments.len() >= 2 and source.route-segments.first() == "blog"
  ))
  parse-sources(blog-sources, post-schema)
    .filter(source => not source.meta.draft)
    .map(source => (
      source: source,
      output: output-of(source-route(source)),
      published-ts: as-timestamp(source.meta.published),
    ))
    .sorted(key: post => (-post.published-ts.unix-seconds, post.source.id))
}
