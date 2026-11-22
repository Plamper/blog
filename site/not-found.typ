#import "@tola/address:0.0.0": route-url
#import "@tola/site:0.0.0": site
#import "layout.typ": site-layout

/// Emit `404.html` inside the shared site shell.
#let not-found-page() = {
  site-layout(
    "404.html",
    title: "404 — " + site.title,
    description: "Page not found",
  )[
    #html.div(class: "post-header")[
      #html.h1[404 — Page not found]
      #html.p(class: "post-meta")[The page you requested could not be found.]
    ]
    #html.a(class: "post-back", href: route-url("/"))[← back home]
  ]
}
