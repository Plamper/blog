#import "@tola/site:0.0.0": site
#import "@tola/source:0.0.0": all-sources
#import "site/blog-index.typ": blog-index-page
#import "site/home.typ": home-page
#import "site/not-found.typ": not-found-page
#import "site/post.typ": post-page
#import "site/selection.typ": select-posts
#import "site/seo.typ": feed-output, sitemap-output

#set text(
  lang: site.language.lang,
  script: site.language.script,
  region: site.language.region,
)

#let posts = select-posts(all-sources())

#home-page(posts)
#blog-index-page(posts)
#for post in posts { post-page(post) }
#not-found-page()

#feed-output("atom.xml", posts)
#sitemap-output("sitemap.xml", posts)
