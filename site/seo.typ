#import "@tola/feed:0.0.0": feed
#import "@tola/head:0.0.0": head-metadata
#import "@tola/site:0.0.0": site
#import "@tola/sitemap:0.0.0": sitemap

/// Head metadata entries (`charset`, `viewport`, `title`, `description`).
#let head-entries(title, description: auto) = {
  head-metadata(site, title: title, description: description)
}

/// Declare `atom.xml` containing all published blog posts with `feed: true`.
#let feed-output(output, posts) = {
  if site.origin == none or site.title == "" { return }
  feed(
    format: "atom",
    output: output,
    entries: posts
      .filter(post => post.source.meta.feed)
      .map(post => {
        let meta = post.source.meta
        (
          id: meta.id,
          target: post.output,
          title: meta.title,
          published: post.published-ts.rfc3339,
          updated: if meta.updated == none {
            none
          } else if type(meta.updated) == dictionary {
            meta.updated.rfc3339
          } else {
            meta.updated
          },
          summary: meta.feed-summary,
          content: if meta.feed-content == none {
            (document: post.output, id: "post-body")
          } else {
            meta.feed-content
          },
        )
      }),
  )
}

/// Declare `sitemap.xml` covering home, blog index, and all published posts with `sitemap: true`.
#let sitemap-output(output, posts) = {
  if site.origin == none { return }
  let static-targets = ("index.html", "blog/index.html")
  let post-targets = posts
    .filter(post => post.source.meta.sitemap)
    .map(post => {
      let updated = post.source.meta.updated
      (
        target: post.output,
        lastmod: if updated == none {
          post.published-ts.rfc3339
        } else if type(updated) == dictionary {
          updated.rfc3339
        } else {
          updated
        },
      )
    })
  sitemap(output: output, targets: static-targets + post-targets)
}
