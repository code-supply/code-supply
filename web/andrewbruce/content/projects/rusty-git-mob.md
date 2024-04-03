+++
title = "Rusty git-mob"
date = 2024-04-03
+++

See it [on GitHub](https://github.com/code-supply/rusty-git-mob)

If you work in a team that pairs or mobs, you really need a git-mob
implementation. There are loads of them, but mine is clearly the best.

Why? It's:

- Written in Rust, which is the *lingua franca* of side projects
- Compatible with a read-only git config, which is useful if you control your
  git config with nix.
- Starting to grow statistics features, so you can see how biased your team
  members are towards each other. This is useful in an XP environment, where
  pairs are meant to rotate frequently and evenly.
