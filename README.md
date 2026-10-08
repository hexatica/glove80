# MoErgo Glove80 Custom Configuration for ZMK

![MoErgo Logo](moergo_logo.png)

This repo is the official ZMK configuration of the MoErgo Glove80 wireless split contoured keyboard. Use it to develop your own keymap and easily build your own ZMK firmware to run on your Glove80.

**NOTE: You can also customize the layout of your Glove80 keyboard with the Glove80 Layout Editor webapp. For most users Glove80 Layout Editor is the recommended and simpler option. More information is available at the official MoErgo Glove80 Support site (see resources below).**

These steps will get you using your keymap on your keyboard in the fastest time possible. It uses the GitHub Actions feature to build your firmware online.

If you are looking to dig deeper into ZMK and develop new functionality, it is recommended to follow the steps of installing ZMK as found on the official ZMK documentation site (linked below).

## Resources
- The [official MoErgo Glove80 Support](https://moergo.com/glove80-support) web site. Glove80 documentation and other technical resources.
- The [official MoErgo Discord Server](https://moergo.com/discord). Instant conversations with other Glove80 users.

- The [official ZMK Documentation](https://zmk.dev/docs) web site. Find the answers to many of your questions about ZMK Firmware.
- The [official ZMK Discord Server](https://discord.gg/8cfMkQksSB). Instant conversations with other ZMK developers and users. Great technical resource!

- The [official Glove80 ZMK Distribution](https://github.com/moergo-sc/zmk). Repositiory for ZMK firmware customized for Glove80. 
 
## Instructions
1. Log into, or sign up for, your personal GitHub account.
2. Create your own repository using this repository as a template ([instructions](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template)) and check it out on your local computer.
3. Edit the keymap file(s) to suit your needs
4. Commit and push your changes to your personal repo. Upon pushing it, GitHub Actions will start building a new version of your firmware with the updated keymap.

## Firmware Files
To locate your firmware files and reflash your Glove80...
1. log into GitHub and navigate to your personal config repository you just uploaded your keymap changes to.
2. Click "Actions" in the main navigation, and in the left navigation click the "Build" link.
3. Select the desired workflow run in the centre area of the page (based on date and time of the build you wish to use). You can also start a new build from this page by clicking the "Run workflow" button.
4. After clicking the desired workflow run, you should be presented with a section at the bottom of the page called "Artifacts". This section contains the results of your build, in a file called "glove80.uf2"
5. Download the glove80.uf2
6. Flash the firmware to Glove80 according to the user documentation on the official Glove80 Glove80 Support website (linked above)

Your keyboard is now ready to use.

## KeyPeek build

This configuration enables [KeyPeek](https://github.com/srwi/keypeek) on the left
(central) half. It retains the existing keymap and Bluetooth battery reporting
for both halves. **Hold Magic, press F2** to unlock Studio access, on a previously
unused position in the Magic layer. The third layer provides mouse controls.

The build uses MoErgo **v26.09** (`ce69e85f585c724142aae37ddf8a7e019ff19e93`).
`config/default.nix` pins the Raw HID and KeyPeek notifier modules by commit and
content hash. `config/keypeek.conf`, the `raw_hid_adapter` shield, and the
`studio-rpc-usb-uart` snippet apply only to the left half. The Studio app is
optional; KeyPeek uses the Studio protocol directly.

Nanopb's Studio generators are copied and their Python interpreter paths are
patched by `config/nanopb.nix`, so they run inside the GitHub Actions Nix sandbox
without a host `/usr/bin/env`. CI checks both Python protobuf generation and
the Nanopb C generator with `checks/nanopb.nix` before building the firmware.

With Docker running, build locally from this directory:

```sh
./build.sh
```

The result is `glove80.uf2`, a combined image for **both halves**. The local build
also exports each half's binary, effective Kconfig and device tree to
`build/left/` and `build/right/` for inspection. `build/` and firmware binaries
are ignored by Git. `build.bat` provides the equivalent Windows build.

### First connection

1. Keep the working firmware in `backups/glove80-before-keypeek-2026-10-08.uf2`.
2. Flash the newly built `glove80.uf2` to the right half, then the left half,
   following [MoErgo's flashing instructions](https://docs.moergo.com/glove80-user-guide/customizing-key-layout/).
   Switch both halves off and back on after flashing.
3. Connect the left half to the computer using a USB data cable and select USB
   output. In this keymap, hold Lower, then hold left Shift to access Magic,
   and tap the left thumb Magic key (`&out OUT_USB` on the Magic layer).
4. Open [KeyPeek](https://github.com/srwi/keypeek/releases), select the Glove80,
   and hold Magic while pressing F2 if it asks to unlock the keyboard.
5. Check ordinary typing from both halves and verify the overlay changes when
   holding Lower or Magic, or tapping the right thumb mouse-layer key.

Test USB first. Adding Raw HID changes Bluetooth services, so Bluetooth may
need re-pairing. Studio access locks again after inactivity or disconnect;
Magic + F2 unlocks it. Saved Studio/KeyPeek edits can override the compiled
keymap; use Studio's Restore Stock Settings when returning to file-based
keymap changes.

### Mouse and scrolling layer

The third layer (ZMK index 2) is named **Mouse**. Tap the existing right thumb
layer key to toggle it on, then tap the same key again to toggle it off. Press
Escape while Mouse is active to return to the base layer immediately.

Tap **E** for **2× pointer speed** or **R** for **3× pointer speed**. Press the
active speed's key again to return to normal; pressing the other key switches
directly to that speed. KeyPeek reports **Mouse Fast** for 2× and **Mouse Faster**
for 3×.
Click and scroll speed stay unchanged. Exiting Mouse using the right thumb
layer key, Escape, or the left thumb return-to-Base key clears both speed modes,
so entering Mouse again starts at normal speed.

| Base-layer key position | Action on Mouse layer |
| --- | --- |
| I / J / K / L | Move pointer up / left / down / right |
| S / D / F | Hold left / middle / right mouse button (release to let go) |
| U / O | Scroll down / up |
| E | Toggle normal / 2× pointer speed |
| R | Toggle normal / 3× pointer speed |
| Left thumb top row | Command / Option / Control |
| Left thumb bottom row | Backspace / Delete / return to Base |
| Right thumb layer key | Toggle Mouse off |
| Escape | Return to Base |

Hold movement or scrolling keys for continuous output. Other positions pass
through to the underlying layer, including modifiers for modified clicks.
Horizontal scrolling has no bindings. The left thumb cluster matches Lower.
Mouse Fast (index 4) and Mouse Faster (index 5) enable built-in XY scaling on the
pointer listener only, retaining the same Mouse controls and normal acceleration.
Their E/R bindings switch between the two modes without combining multipliers.
`CONFIG_ZMK_POINTING=y` enables ZMK's built-in mouse support; no extra module is
needed. Build and flash both halves as above, then reconnect the left USB cable
to refresh its mouse interface. For Bluetooth, forget/re-pair the keyboard if
the host has cached the old HID descriptor. See [ZMK's mouse documentation](https://zmk.dev/docs/keymaps/behaviors/mouse-emulation).

If bindings were saved through KeyPeek or Studio, use Studio's **Restore Stock
Settings** to load this newly compiled keymap; this replaces those saved edits.

### Rollback

Flash `backups/glove80-before-keypeek-2026-10-08.uf2` onto both halves. Its SHA-256
is `a9552b65c81bfdc4f450dd3b493d0267b834ff9d0dbe234250903e9dfa637e78`.
If a half is unresponsive, use MoErgo's power-on bootloader procedure instead of
the running firmware's bootloader key. Re-pair Bluetooth if necessary; do not
perform a settings reset unless it is needed to recover the connection.
