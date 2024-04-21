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

    # gcc  # collision with clang
    llvmPackages_latest.clang
    clang-tools # for clangd to find the correct headers

    # zig
    zig
    zls
  ];
}
