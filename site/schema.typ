// Metadata schema for blog posts; unknown fields fail validation.

#import "@tola/schema:0.0.0": (
  date, describe, literal, non-empty, nullable, one-or-many, optional, schema, timestamp, trim, union, url-path,
)
#import "@tola/site:0.0.0": site

/// One author entry: a `name`, with optional `email` and `url`.
#let author = schema(
  (
    name: str,
    email: optional(nullable(str)),
    url: optional(nullable(str)),
  ),
  unknown: "keep",
)

/// Blog post metadata schema.
#let post-schema = schema((
  title: describe(
    non-empty(trim(str)),
    "the post title, shown in the browser tab, post header, and post lists",
  ),
  description: describe(
    optional(nullable(trim(str)), default: none),
    "optional post summary for search engines and link previews",
  ),
  published: describe(
    union(date, timestamp),
    "publication date (`YYYY-MM-DD`, native `datetime`, or RFC 3339 timestamp)",
  ),
  updated: describe(
    optional(nullable(union(date, timestamp)), default: none),
    "optional last modification date or timestamp",
  ),
  authors: describe(
    optional(nullable(one-or-many(union(str, author))), default: site.authors),
    "post authors; defaults to `site.authors`",
  ),
  tags: describe(
    optional(one-or-many(str), default: ()),
    "topics this post belongs to",
  ),
  draft: describe(
    optional(bool, default: false),
    "exclude from the published site when true",
  ),
  permalink: describe(
    optional(nullable(url-path), default: none),
    "optional route override such as `/blog/custom-slug/`",
  ),
  feed: describe(
    optional(bool, default: true),
    "include in `atom.xml`",
  ),
  sitemap: describe(
    optional(bool, default: true),
    "include in `sitemap.xml`",
  ),
  id: describe(
    optional(union(str, literal(auto)), default: auto),
    "stable Atom entry identifier; `auto` derives one from the post URL",
  ),
  feed-summary: describe(
    optional(nullable(union(trim(str), content)), default: none),
    "optional Atom entry summary",
  ),
  feed-content: describe(
    optional(nullable(union(str, content, dictionary)), default: none),
    "optional Atom entry body override",
  ),
))
