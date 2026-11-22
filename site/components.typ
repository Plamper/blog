// Reusable content components (replacing Zola shortcodes).

#import "@tola/address:0.0.0": asset-url
#import "@tola/image:0.0.0": resize-image

/// Display a static asset image inside a framed figure, with optional width, caption, and full-size link.
#let img-box(asset-path, width: auto, alt: "", caption: none, link-full: true) = {
  let href = asset-url(asset-path)
  let figure-attrs = (class: "image-box")
  if width != auto {
    let css-width = if type(width) == int or type(width) == float {
      str(width) + "px"
    } else {
      str(width)
    }
    figure-attrs.insert("style", "max-width: min(100%, " + css-width + ");")
  }
  let img-el = html.elem(
    "img",
    attrs: (
      src: href,
      alt: alt,
      loading: "lazy",
      decoding: "async",
    ),
  )
  let media = if link-full {
    html.a(
      class: "image-link",
      href: href,
      target: "_blank",
      rel: ("noopener", "noreferrer"),
      title: "Open full size",
    )[#img-el]
  } else {
    img-el
  }
  html.elem("figure", attrs: figure-attrs)[
    #html.div(class: "image-frame")[#media]
    #if caption != none {
      html.elem("figcaption", attrs: (class: "image-caption"))[#caption]
    }
  ]
}

/// Generate and display a resized WebP/PNG/JPEG derivative inside the same framed figure.
#let resized-img(
  source,
  width: none,
  height: none,
  op: "fit-width",
  format: "webp",
  quality: 90,
  alt: "",
  caption: none,
  link-full: true,
) = {
  let derived = resize-image(
    source,
    width: width,
    height: height,
    op: op,
    format: format,
    quality: quality,
  )
  let figure-attrs = (
    class: "image-box",
    style: "max-width: min(100%, " + str(derived.width) + "px);",
  )
  let img-el = html.elem(
    "img",
    attrs: (
      src: derived.url,
      width: str(derived.width),
      height: str(derived.height),
      alt: alt,
      loading: "lazy",
      decoding: "async",
    ),
  )
  let media = if link-full {
    html.a(
      class: "image-link",
      href: derived.url,
      target: "_blank",
      rel: ("noopener", "noreferrer"),
      title: "Open full size",
    )[#img-el]
  } else {
    img-el
  }
  html.elem("figure", attrs: figure-attrs)[
    #html.div(class: "image-frame")[#media]
    #if caption != none {
      html.elem("figcaption", attrs: (class: "image-caption"))[#caption]
    }
  ]
}

/// Framed, horizontally scrollable monospace table card with an optional header caption.
#let table-wrap(caption: none, body) = html.elem("figure", attrs: (class: "table-card"))[
  #if caption != none {
    html.elem("figcaption", attrs: (class: "table-header"))[#caption]
  }
  #html.div(class: "table-scroll")[#body]
]

/// Responsive 16:9 YouTube embed.
#let youtube(id, title: "YouTube video") = html.div(class: "video-wrapper")[
  #html.elem(
    "iframe",
    attrs: (
      src: "https://www.youtube.com/embed/" + id,
      title: title,
      loading: "lazy",
      allow: "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share",
      allowfullscreen: "",
    ),
  )
]
