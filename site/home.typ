#import "@tola/site:0.0.0": site
#import "layout.typ": site-layout
#import "terminal.typ": terminal-post-list

#let hero-typewriter-script = ```js
(() => {
  const el = document.getElementById("typewriter");
  if (!el) return;

  if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
    return;
  }

  const phrases = [
    "hi, i'm Felix.",
    "i write about things i find interesting.",
    "welcome!",
  ];

  let pi = 0;
  let ci = 0;
  let deleting = false;

  const cursor = document.createElement("span");
  cursor.className = "cursor";
  cursor.setAttribute("aria-hidden", "true");

  function render(slice) {
    el.textContent = slice;
    el.appendChild(cursor);
  }

  function tick() {
    const text = phrases[pi];
    if (!deleting) {
      ci++;
      render(text.slice(0, ci));
      if (ci === text.length) {
        deleting = true;
        setTimeout(tick, 2000);
        return;
      }
      setTimeout(tick, 65);
    } else {
      ci--;
      render(text.slice(0, ci));
      if (ci === 0) {
        deleting = false;
        pi = (pi + 1) % phrases.length;
        setTimeout(tick, 350);
        return;
      }
      setTimeout(tick, 38);
    }
  }

  tick();
})();
```.text

/// Emit the home page (`index.html`).
#let home-page(posts) = {
  let recent = posts.slice(0, calc.min(5, posts.len()))
  site-layout(
    "index.html",
    title: site.title,
    scripts: html.script(hero-typewriter-script),
  )[
    #html.div(class: "hero")[
      #html.h1(id: "typewriter")[hi, i\'m Felix.]
      #html.p[
        Just a computer engineering student writing about random things. Mostly Linux, Nix,
        Photography and maybe drones.
      ]
    ]

    #html.hr()

    #terminal-post-list("recent/", recent)
  ]
}
