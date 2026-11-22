#import "@tola/address:0.0.0": route-url
#import "@tola/site:0.0.0": site
#import "layout.typ": site-layout
#import "selection.typ": as-date, format-long-date

#let post-title-script = ```js
(() => {
  const el = document.getElementById("post-title");
  if (!el) return;

  if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
    return;
  }

  const text = el.textContent;
  let i = 0;

  const cursor = document.createElement("span");
  cursor.className = "cursor";
  cursor.setAttribute("aria-hidden", "true");

  function type() {
    if (i <= text.length) {
      el.textContent = text.slice(0, i);
      el.appendChild(cursor);
      i++;
      setTimeout(type, 50);
    }
  }

  type();
})();
```.text

/// Emit one blog post page (`blog/<slug>/index.html`).
#let post-page(post) = {
  let meta = post.source.meta
  let authors = if meta.authors == none {
    ()
  } else {
    meta.authors.map(author => if type(author) == dictionary { author.name } else { author })
  }
  site-layout(
    post.output,
    title: meta.title + " — " + site.title,
    description: if meta.description == none { auto } else { meta.description },
    author: authors,
    keywords: meta.tags,
    include-code: true,
    scripts: html.script(post-title-script),
  )[
    #html.a(class: "post-back", href: route-url("/blog/"))[← all posts]

    #html.div(class: "post-header")[
      #html.h1(id: "post-title")[#meta.title]
      #html.p(class: "post-meta")[
        #html.time(datetime: as-date(meta.published))[#format-long-date(meta.published)]
      ]
    ]

    #html.article(id: "post-body", class: "prose")[
      #include post.source.file
    ]
  ]
}
