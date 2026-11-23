#import "@tola/address:0.0.0": asset-url, output-url, route-url
#import "@tola/code:0.0.0": code-stylesheet, render-code
#import "@tola/site:0.0.0": site
#import "seo.typ": head-entries

/// Path to the bundled Kanagawa Dragon syntax theme.
#let kanagawa-dragon = path("/static/themes/kanagawa-dragon.tmTheme")

/// Helper to build a feather-style 24x24 stroke SVG icon.
#let stroke-icon(children) = html.elem(
  "svg",
  attrs: (
    width: "18",
    height: "18",
    viewBox: "0 0 24 24",
    fill: "none",
    stroke: "currentColor",
    "stroke-width": "2",
    "stroke-linecap": "round",
    "stroke-linejoin": "round",
    "aria-hidden": "true",
  ),
  children,
)

#let github-icon = stroke-icon(
  html.elem(
    "path",
    attrs: (
      d: "M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22",
    ),
  ),
)

#let linkedin-icon = stroke-icon[
  #html.elem(
    "path",
    attrs: (
      d: "M16 8a6 6 0 0 1 6 6v7h-4v-7a2 2 0 0 0-2-2 2 2 0 0 0-2 2v7h-4v-7a6 6 0 0 1 6-6z",
    ),
  )
  #html.elem("rect", attrs: (x: "2", y: "9", width: "4", height: "12"))
  #html.elem("circle", attrs: (cx: "4", cy: "4", r: "2"))
]

#let mail-icon = stroke-icon[
  #html.elem(
    "path",
    attrs: (
      d: "M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z",
    ),
  )
  #html.elem("polyline", attrs: (points: "22,6 12,13 2,6"))
]

#let feed-icon = stroke-icon[
  #html.elem("path", attrs: (d: "M4 11a9 9 0 0 1 9 9"))
  #html.elem("path", attrs: (d: "M4 4a16 16 0 0 1 16 16"))
  #html.elem("circle", attrs: (cx: "5", cy: "19", r: "1"))
]

/// Copy-button + language-header enhancement script for `.prose pre` code blocks.
#let copy-code-script = ```js
document.addEventListener("DOMContentLoaded", () => {
  const copyIcon = `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect width="14" height="14" x="8" y="8" rx="2" ry="2"/><path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"/></svg>`;
  const checkIcon = `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="20 6 9 17 4 12"></polyline></svg>`;

  document.querySelectorAll(".prose pre").forEach((pre) => {
    if (pre.parentNode.classList.contains("code-block")) return;

    const codeTag = pre.querySelector("code");
    const lang =
      (codeTag ? codeTag.getAttribute("data-lang") : null) ||
      pre.getAttribute("data-lang") ||
      "";

    const wrapper = document.createElement("div");
    wrapper.className = "code-block";

    const header = document.createElement("div");
    header.className = "code-header";

    const langSpan = document.createElement("span");
    langSpan.className = "code-lang";
    langSpan.textContent = lang.toLowerCase();

    const copyBtn = document.createElement("button");
    copyBtn.type = "button";
    copyBtn.className = "code-copy";
    copyBtn.innerHTML = copyIcon;
    copyBtn.setAttribute("aria-label", "Copy code");

    copyBtn.addEventListener("click", () => {
      const codeText = codeTag ? codeTag.innerText : pre.innerText;
      if (!navigator.clipboard) return;
      navigator.clipboard.writeText(codeText).then(() => {
        copyBtn.innerHTML = checkIcon;
        copyBtn.classList.add("copied");
        setTimeout(() => {
          copyBtn.innerHTML = copyIcon;
          copyBtn.classList.remove("copied");
        }, 2000);
      });
    });

    header.appendChild(langSpan);
    header.appendChild(copyBtn);
    pre.parentNode.insertBefore(wrapper, pre);
    wrapper.appendChild(header);
    wrapper.appendChild(pre);
  });
});
```.text

/// Shared HTML document shell used by every page on the site.
#let site-layout(
  output,
  title: site.title,
  description: auto,
  author: (),
  keywords: (),
  include-code: false,
  scripts: none,
  body,
) = {
  let feed-href = output-url("atom.xml")
  document(
    output,
    format: "html",
    title: title,
    description: if description == auto { site.description } else { description },
    author: author,
    keywords: keywords,
  )[
    #set raw(theme: kanagawa-dragon)
    #show raw: render-code
    #html.html(lang: site.language.tag)[
      #html.head[
        #for entry in head-entries(title, description: description) { entry }
        #html.link(rel: "preconnect", href: "https://fonts.googleapis.com")
        #html.link(rel: "preconnect", href: "https://fonts.gstatic.com", crossorigin: "anonymous")
        #html.link(
          rel: "stylesheet",
          href: "https://fonts.googleapis.com/css2?family=Alegreya:ital,wght@0,400;0,500;1,400&family=Inconsolata:wght@400;500&display=swap",
        )
        #if include-code { code-stylesheet() }
        #html.link(rel: "stylesheet", href: asset-url("/assets/css/style.css"))
        #html.link(
          rel: "alternate",
          type: "application/atom+xml",
          title: site.title + " — Atom Feed",
          href: feed-href,
        )
      ]
      #html.body[
        #html.div(class: "site-wrap")[
          #html.nav(class: "site-nav", aria-label: "Primary")[
            #html.a(class: "name", href: route-url("/"))[#site.title]
            #html.div(class: "nav-right")[
              #html.ul(class: "nav-links")[
                #html.li[#html.a(href: route-url("/blog/"))[blog]]
              ]
              #html.ul(class: "social-links")[
                #html.li[
                  #html.a(
                    href: "https://github.com/plamper",
                    aria-label: "GitHub",
                    title: "GitHub",
                  )[#github-icon]
                ]
                #html.li[
                  #html.a(
                    href: "https://linkedin.com/in/felix-plamper",
                    aria-label: "LinkedIn",
                    title: "LinkedIn",
                  )[#linkedin-icon]
                ]
                #html.li[
                  #html.a(
                    href: "mailto:felix@plamper.org",
                    aria-label: "Email",
                    title: "Email",
                  )[#mail-icon]
                ]
                #html.li[
                  #html.a(
                    href: feed-href,
                    aria-label: "Atom Feed",
                    title: "Atom Feed",
                  )[#feed-icon]
                ]
              ]
            ]
          ]

          #html.main[#body]

          #html.footer(class: "site-footer")[
            built with #html.a(href: "https://github.com/tola-rs/tola-ssg")[tola]
          ]
        ]

        #if include-code {
          html.script(copy-code-script)
        }
        #if scripts != none { scripts }
      ]
    ]
  ]
}
