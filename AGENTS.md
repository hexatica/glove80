# AGENTS.md - MoErgo Glove80 ZMK Configuration

## Build Commands
- **Build locally**: `./build.sh [branch]` (uses Docker + Nix)
- **Build output**: `glove80.uf2` firmware file
- **CI Build**: Triggered automatically on push via GitHub Actions (`.github/workflows/build.yml`)
- **No traditional tests** - validation is via successful firmware compilation
- **Dependencies**: Managed via `config/west.yml` (includes zmk-helpers module)

## Architecture
- **Type**: ZMK keyboard firmware configuration for MoErgo Glove80 split keyboard
- **Build System**: Nix-based build using ZMK fork from `darknao/zmk` (rgb-layer-24.12 branch)
- **Main Config Files**: `config/glove80.keymap` (keymap), `config/glove80.conf` (features)
- **Docker Build**: Uses NixOS container with Cachix for caching dependencies
- **Modules**: Uses `zmk-helpers` for simplified HRM syntax

## Code Style (Device Tree / ZMK)
- **Language**: Device Tree Source (.dts) with C preprocessor macros
- **Layer Definitions**: Use `#define` constants (DEFAULT, LOWER, MAGIC, FACTORY_TEST, CUSTOM)
- **Naming**: SCREAMING_SNAKE_CASE for layer names and macros
- **Comments**: C-style `/* */` for copyright, `//` for inline comments
- **Behaviors**: Define custom behaviors in `/ { behaviors { ... } }` blocks
- **Keymaps**: Structured as `keymap { compatible = "zmk,keymap"; ... }`
- **RGB Underglow**: Use `&ug COLOR` bindings for per-key layer lighting
- **Formatting**: Align key bindings in visual keyboard layout format

## Home Row Mods Configuration
- **Left hand**: A=Shift, S=Ctrl, D=Alt, F=GUI (G is plain tap)
- **Right hand**: J=GUI, K=Alt, L=Ctrl, ;=Shift (H is plain tap)
- **Timings**: tapping-term=280ms, quick-tap=175ms, require-prior-idle=150ms
- **Flavor**: Balanced with positional hold-tap and hold-trigger-on-release
- **Implementation**: Uses `&hml` and `&hmr` behaviors from zmk-helpers
