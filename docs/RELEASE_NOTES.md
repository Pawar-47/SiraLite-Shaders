# SiraLite Shaders 1.7.1

Documentation only. **The shader content is identical to 1.7.0** - if you already
have 1.7.0 installed, there is nothing to update for.

## Why this release exists

The previous release's work included reducing a third-party reference pack
(MakeUp - Ultra Fast, LGPL-3.0) to its cheapest configuration and then reading its
code to see what else could go. That work lived in an ignored local folder, so it
never reached the repository and could not be reviewed.

It is now written down in [MAKEUP-TUNING.md](MAKEUP-TUNING.md): the method, the
five findings that stopped the cuts (which pass produces the fog texture every
pixel samples, which passes already guard themselves, which "expensive" call only
runs underwater), and the settings that actually move framerate on an i3 with
integrated graphics.

That pack's own code is not redistributed here and stays out of git: it is LGPL,
this project is MIT, and it ships its own textures.

## Unchanged guarantees

- Ultra Performance stays the default; Potato is still the floor.
- Every effect has an option, and every profile is one click.
- Releases are additive: v1.7.0 and everything earlier stay published with their
  downloads untouched.
