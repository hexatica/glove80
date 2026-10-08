{ pkgs ?  import <nixpkgs> {}
, firmware ? import ../src {}
}:

let
  config = ./.;

  # Pin external modules independently of the firmware version.
  rawHid = builtins.fetchTarball {
    url = "https://github.com/zzeneg/zmk-raw-hid/archive/6a37765dfab6197292e7a9f47305dcf87386d56a.tar.gz";
    sha256 = "1cjllz51xv10yx7xsmyz2mhavmcq928a57pqdh8v7i4v184jk0dg";
  };
  keypeek = builtins.fetchTarball {
    url = "https://github.com/srwi/zmk-keypeek-layer-notifier/archive/b600af3bb7d1795073a4ce23e08d6db46371551b.tar.gz";
    sha256 = "05jk7cgnjaraq1g3cizcb9nvkbs8lb2x261b2ma9hs4153l8fg5c";
  };

  glove80_left = firmware.zmk.override {
    board = "glove80_lh";
    keymap = "${config}/glove80-keypeek.keymap";
    kconfig = "${config}/glove80.conf;${config}/keypeek.conf";
    extraModules = [ rawHid keypeek ];
    shield = "raw_hid_adapter";
    snippets = [ "studio-rpc-usb-uart" ];
  };
  glove80_right = firmware.zmk.override { board = "glove80_rh"; keymap = "${config}/glove80.keymap"; kconfig = "${config}/glove80.conf"; };

in (firmware.combine_uf2 glove80_left glove80_right).overrideAttrs (old: {
  # Keep the effective configuration and individual binaries for verification.
  buildCommand = old.buildCommand + ''
    mkdir -p $out/left $out/right
    cp ${glove80_left}/* $out/left/
    cp ${glove80_right}/* $out/right/
  '';
})
