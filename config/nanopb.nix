{ buildPackages, module }:

let
  python = buildPackages.python3.withPackages (ps: [ ps.protobuf ps.grpcio-tools ]);
in module.overrideAttrs (old: {
  nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ python ];
  # The upstream module symlinks its immutable source, leaving /usr/bin/env
  # shebangs intact. Copy it so its generators can use a Nix store interpreter.
  installPhase = ''
    mkdir -p $out/nanopb
    cp -R ${old.src}/. $out/nanopb/
    chmod -R u+w $out/nanopb
    patchShebangs --build $out/nanopb/generator
  '';
})
