{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    cmake
    cmake-format
    cmake-language-server
    gdb
    
    gcc
    # llvmPackages
    clang-tools # for clangd to find the correct headers

    # zig
    zig
    zls
  ];
}
