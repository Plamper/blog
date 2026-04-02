+++
title = "Under Construction"
date = 2026-04-02
+++

This is a paragraph of text. You can write in plain **Markdown** and Zola handles the rest.

## A code example

Here's some Rust with syntax highlighting — just use fenced code blocks as normal:

```rust
fn main() {
    let message = "hello from zola";
    println!("{}", message);
}
```

And a Nix snippet:

```nix
{ config, pkgs, ... }: {
  networking.hostName = "myhost";
  environment.systemPackages = with pkgs; [ git curl ripgrep ];
  system.stateVersion = "24.11";
}
```

Inline code like `let x = 42;`.

## Youtube test

{{ youtube(id="NOiyDlWl534") }}

## Image Test

{{ resize_image(path="/images/test.png", width=150, height=150, op="fill") }}
