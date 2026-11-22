#import "@tola/address:0.0.0": output-url
#import "selection.typ": format-iso-date

/// Terminal-styled post list shared by the home page and blog index.
#let terminal-post-list(dir-label, posts) = {
  let count = posts.len()
  let unit = if count == 1 { "post" } else { "posts" }
  html.div(class: "terminal")[
    #html.div(class: "terminal-body")[
      #html.div(class: "terminal-line")[
        #html.span(class: "t-prompt")[\~ \$]
        #html.span(class: "t-cmd")[
          #html.span(class: "bash-cmd")[ls]
          #html.span(class: "bash-flag")[-laHt]
          #html.span(class: "bash-arg")[#dir-label]
        ]
      ]
      #html.div(class: "t-total")[total #count #unit]
      #for post in posts [
        #html.div(class: "t-row")[
          #html.span(class: "t-date")[#format-iso-date(post.source.meta.published)]
          #html.a(href: output-url(post.output), class: "t-title")[#post.source.meta.title]
        ]
      ]
      #html.div(class: "terminal-line t-end")[
        #html.span(class: "t-prompt")[\~ \$]
        #html.span(class: "t-cursor")[]
      ]
    ]
  ]
}
