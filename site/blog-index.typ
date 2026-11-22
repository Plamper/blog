#import "@tola/site:0.0.0": site
#import "layout.typ": site-layout
#import "terminal.typ": terminal-post-list

/// Emit the blog listing page (`blog/index.html`).
#let blog-index-page(posts) = {
  site-layout(
    "blog/index.html",
    title: "blog — " + site.title,
    description: "All blog posts on " + site.title,
  )[
    #terminal-post-list("posts/", posts)
  ]
}
