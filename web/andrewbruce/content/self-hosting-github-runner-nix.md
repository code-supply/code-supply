+++
title = "Self-hosted GitHub Runners with Nix"
date = 2024-01-14
draft = true
+++

- We moved to nix
- It helped us standardise versions
- Eventually the GH workflow was running into 30 min
- Copying nix dependencies across the network with magic-nix-cache, getting rate-limited
- Custom runner would let us preinstall nix and all dependencies 
- Not a straightforward translation
- Remove nix actions
- Deal with systemd
- Deal with with database flakes
- Worth it for a 10-20min speedup!
