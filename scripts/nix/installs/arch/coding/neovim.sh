#!/usr/bin/env bash
# Define the branch you want to build
BRANCH="release-0.12"  # Change this to your desired branch
NEOVIM_DIR="/tmp/neovim-${BRANCH}"
REPO="https://github.com/neovim"
# Function to print error messages and exit
function error() {
  echo "Error: $1"
  exit 1
}

update_pynvim() {
  echo "Updating/Installing pynvim"
  if [[ ! -x $(command -v pip3) ]]; then
      printf "\n==X Please install python-pip3\n"
      return 1
  fi
  local venv_loc="${XDG_DATA_HOME:=$HOME/.local/share}/pyvenv"
  local venv_name="nvim"

  mkdir -p "$venv_loc"
  python -m venv "$venv_loc/$venv_name" \
    --symlinks --clear || error "Failed to create python virtual environment"
  source "$venv_loc/$venv_name/bin/activate" || error "Failed to activate python virtual environment"
  pip3 install --ignore-installed --upgrade pynvim pip || error "Failed to activate python virtual environment"
  deactivate || error "Failed to deactivate python virtual environment"
}

# Install needed dependencies (adjust as necessary)
paru -Syu --needed git cmake make gcc pkg-config unzip ninja libtool curl gettext \
  tree-sitter-cli ripgrep fd inotify-tools

[[ -d "$NEOVIM_DIR" ]] && $NEOVIM_DIR="$NEOVIM_DIR-`date +%s`"

# Clone the specific branch of Neovim
echo "Cloning Neovim repository..."
git clone --depth 1 --branch "$BRANCH" --single-branch ${REPO}/neovim.git "$NEOVIM_DIR" || error "Failed to clone Neovim repository"
# Navigate to the directory
cd "$NEOVIM_DIR" || error "Failed to navigate to Neovim directory"
# Build Neovim
echo "Building Neovim..."
make CMAKE_BUILD_TYPE=Release || error "Failed to build Neovim"
# Install Neovim
echo "Installing Neovim..."
sudo make install || error "Failed to install Neovim"
# Clean up
echo "Cleaning up..."
rm -rf "$NEOVIM_DIR"
echo "Neovim has been successfully installed from branch '$BRANCH'."

update_pynvim

echo "Press any key to exit..."
read -n 1 -s  # Wait for a single key press
echo  # Print a new line for better readability
