{ firmware ? import ../src {} }:

let
  nanopb = firmware.callPackage ../config/nanopb.nix {
    module = firmware.zephyr.modules.nanopb;
  };
in firmware.callPackage ({ runCommand }:
  runCommand "glove80-nanopb-generator-check" {} ''
    # A generator must run without relying on /usr/bin/env or PATH's Python.
    for script in protoc protoc-gen-nanopb; do
      IFS= read -r shebang < ${nanopb.modulePath}/generator/$script
      case "$shebang" in
        '#!/nix/store/'*/bin/python*) ;;
        *) echo "Non-hermetic interpreter in $script: $shebang" >&2; exit 1 ;;
      esac
    done

    # Match CMake's writable generator copy; the plugin may refresh nanopb_pb2.py.
    cp -R ${nanopb.modulePath}/generator ./generator
    chmod -R u+w generator
    generator=$PWD/generator
    "$generator/protoc" --version
    mkdir -p python generated
    "$generator/protoc" -I "$generator/proto" --python_out=python \
      "$generator/proto/nanopb.proto"
    test -s python/nanopb_pb2.py

    cat > smoke.proto <<'EOF'
    syntax = "proto2";
    message Smoke { required uint32 value = 1; }
    EOF
    "$generator/protoc" -I . --nanopb_out=generated smoke.proto
    test -s generated/smoke.pb.c
    test -s generated/smoke.pb.h
    mkdir -p $out
    cp python/nanopb_pb2.py generated/smoke.pb.* $out/
  ''
) {}
