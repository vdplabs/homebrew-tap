# vdplabs/homebrew-tap

Homebrew formulas for [VDP Labs](https://github.com/vdplabs) open-source tools.

## Install pantry

[pantry](https://github.com/vdplabs/pantry) is a local model host for Apple Silicon.

```bash
brew tap vdplabs/tap
brew install pantry

pantry init
pantry pull vdplabs.qwen25-0.5b.compact.v1
pantry serve
```

- Formula: [`Formula/pantry.rb`](Formula/pantry.rb)
- Project docs: [vdplabs/pantry](https://github.com/vdplabs/pantry)
- Install guide: [Docs/Install.md](https://github.com/vdplabs/pantry/blob/main/Docs/Install.md)

This tap is the **only** Homebrew distribution path. The pantry application repo does not vendor the formula.
