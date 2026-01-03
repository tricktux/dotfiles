#!/usr/bin/env bash
# filepath: scripts/nix/installs/arch/coding/neovim.sh
# Define the branch you want to build
BRANCH="release-0.11"  # Change this to your desired branch
NEOVIM_DIR="/tmp/neovim-${BRANCH}"
REPO="https://github.com/neovim"

# Function to print error messages and exit
function error() {
  echo "Error: $1"
  exit 1
}

# Function to uninstall previous Neovim installation
uninstall_previous_neovim() {
  echo "Removing previous Neovim installation..."
  
  # Remove common installation paths
  sudo rm -f /usr/local/bin/nvim
  sudo rm -rf /usr/local/share/nvim
  sudo rm -rf /usr/local/lib/nvim
  sudo rm -f /usr/local/share/man/man1/nvim.1
  sudo rm -rf /usr/local/share/locale/*/LC_MESSAGES/nvim.mo
  sudo rm -rf /usr/local/share/nvim
  sudo rm -f /usr/local/share/applications/nvim.desktop
  # sudo rm -f /usr/local/share/pixmaps/nvim.png
  
  # Also clean up any systemwide installation
  # sudo rm -f /usr/bin/nvim 2>/dev/null || true
  # sudo rm -rf /usr/share/nvim 2>/dev/null || true
  # TODO: Detect systemwide runtime
  
  echo "Previous installation cleaned up."
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
yay -Syu --needed git cmake make gcc pkg-config unzip ninja libtool curl gettext \
  tree-sitter-cli ripgrep fd inotify-tools

# Clean up previous installation first
uninstall_previous_neovim

# Fix syntax error and handle existing directory
if [[ -d "$NEOVIM_DIR" ]]; then
  echo "Removing existing build directory..."
  sudo rm -rf "$NEOVIM_DIR"
fi

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

# Clean up build directory
echo "Cleaning up build directory..."
rm -rf "$NEOVIM_DIR"

echo "Neovim has been successfully installed from branch '$BRANCH'."

update_pynvim

echo "Press any key to exit..."
read -n 1 -s  # Wait for a single key press
echo  # Print a new line for better readability
