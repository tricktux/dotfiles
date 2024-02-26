{ inputs
, outputs
, lib
, config
, pkgs
, ...
}:

let
  pythonPackages = pkgs.python311Packages;

  # venvDir = "./env";

  # runPackages = [
  #   pythonPackages.python
  #   pythonPackages.venvShellHook
  # ];

  # devPackages = runPackages ++ [
  #   pythonPackages.pylint
  #   pythonPackages.flake8
  #   pythonPackages.black
  # ];

  # # This is to expose the venv in PYTHONPATH so that pylint can see venv packages
  # postShellHook = ''
  #   PYTHONPATH=\$PWD/\${venvDir}/\${pythonPackages.python.sitePackages}/:\$PYTHONPATH
  #   # pip install -r requirements.txt
  # '';

in
# {
#   runShell = pkgs.mkShell {
#     inherit venvDir;
#     name = "pythonify-run";
#     packages = runPackages;
#     postShellHook = postShellHook;
#   };
#   developmentShell = pkgs.mkShell {
#     inherit venvDir;
#     name = "pythonify-dev";
#     packages = devPackages;
#     postShellHook = postShellHook;
#   };
# }
{
  home.packages = with pkgs; [
    pythonPackages.pylint
    pythonPackages.flake8
    pythonPackages.black
    python3
  ];


}
