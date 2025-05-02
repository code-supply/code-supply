+++
title = "Voron Trident 300 Build: Part 7"
date = 2025-05-01
+++

It's printing! But it will never be done.

As is the case with many of these build logs, the last few steps are
undocumented because it's too exciting at the end.

The wiring stage of the project went surprisingly well, and I think this is
largely due to the quality of the LDO kit. All the wires were pre-crimped and
at appropriate, generous lengths.

I got a little stuck obsessing over getting KlipperScreen to work on NixOS, but
eventually decided to forego that in favour of getting a first print.

My enthusiasm *did* result in a printhead crash, but only because I'd forgotten
to put the metal build surface onto the bed, so the inductive probe couldn't
activate. Of course, I should've tested the probe before running the Trident
levelling macro, but I found that out afterwards.

Since then, I've figured out the BTT 43 TFT screen that comes with the LDO kit
and it's running with the Raspberry Pi 4b on NixOS nicely. I have some
upstreaming work to do before there's an out-of-box experience for Nix users,
but I hope to get there someday soon. I think it'd be *really* nice to have a
web GUI that configures an SD card image for Raspberry Pi Vorons, and that's
totally doable with Nix.

My initial serial request video hasn't resulted in a serial yet, but I'm hoping
with some more visuals of the full printer it'll be accepted.

Now, about that MMU...
