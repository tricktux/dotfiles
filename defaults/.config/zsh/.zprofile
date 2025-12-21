#
# ~/.zprofile
#

# GPU Detection and Environment Setup
detect_gpu_and_set_env() {
    local gpu_info=$(lspci | grep -i 'vga\|3d\|display')
    local has_nvidia=false
    local has_amd=false
    local has_intel=false

    # Detect all GPU types present
    if echo "$gpu_info" | grep -qi nvidia; then
        has_nvidia=true
        echo "Detected NVIDIA GPU"
        fi
    
    if echo "$gpu_info" | grep -qi 'amd\|ati\|radeon'; then
        has_amd=true
        echo "Detected AMD GPU"
    fi
    
    if echo "$gpu_info" | grep -qi intel; then
        has_intel=true
        echo "Detected Intel GPU"
    fi
    
    # Set environment variables based on detected GPUs
    # Handle hybrid setups first
    if $has_intel && $has_nvidia; then
        echo "Detected Intel + NVIDIA hybrid setup"
        # NVIDIA variables for dGPU
        export GBM_BACKEND=nvidia-drm
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export WLR_NO_HARDWARE_CURSORS=1
        export LIBVA_DRIVER_NAME=nvidia
        # Intel variables for iGPU (fallback)
        export INTEL_LIBVA_DRIVER_NAME=iHD
        # For hybrid graphics switching
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __VK_LAYER_NV_optimus=NVIDIA_only
        
    elif $has_amd && $has_nvidia; then
        echo "Detected AMD + NVIDIA hybrid setup"
        # NVIDIA variables for dGPU
        export GBM_BACKEND=nvidia-drm
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export WLR_NO_HARDWARE_CURSORS=1
        export LIBVA_DRIVER_NAME=nvidia
        # AMD variables for iGPU (fallback)
        export AMD_LIBVA_DRIVER_NAME=radeonsi
        export AMD_VDPAU_DRIVER=radeonsi
        # For hybrid graphics
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __VK_LAYER_NV_optimus=NVIDIA_only
        
    elif $has_intel && $has_amd; then
        echo "Detected Intel + AMD hybrid setup"
        # Prefer AMD for dedicated graphics
        export LIBVA_DRIVER_NAME=radeonsi
        export VDPAU_DRIVER=radeonsi
        export AMD_VULKAN_ICD=RADV
        # Intel as fallback
        export INTEL_LIBVA_DRIVER_NAME=iHD
        
    # Single GPU setups
    elif $has_nvidia; then
        echo "Detected NVIDIA GPU only"
        export GBM_BACKEND=nvidia-drm
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export WLR_NO_HARDWARE_CURSORS=1
        export LIBVA_DRIVER_NAME=nvidia
        
    elif $has_amd; then
        echo "Detected AMD GPU only"
        export LIBVA_DRIVER_NAME=radeonsi
        export VDPAU_DRIVER=radeonsi
        export AMD_VULKAN_ICD=RADV
        
    elif $has_intel; then
        echo "Detected Intel GPU only"
        export LIBVA_DRIVER_NAME=iHD
        export VDPAU_DRIVER=va_gl
        
    else
        echo "No dedicated GPU detected"
    fi
}

exec_sway() {
  # Wayland/Sway specific variables (moved from .zshenv)
  export XDG_SESSION_TYPE=wayland
  export XDG_CURRENT_DESKTOP=sway
  export XDG_SESSION_DESKTOP=sway

  # Application-specific wayland variables
  export QT_QPA_PLATFORM=wayland
  export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
  export GDK_BACKEND=wayland
  export MOZ_ENABLE_WAYLAND=1
  export SDL_VIDEODRIVER=wayland
  export CLUTTER_BACKEND=wayland
  export _JAVA_AWT_WM_NONREPARENTING=1

  if $has_nvidia; then
      exec sway --unsupported-gpu > /tmp/sway_debug.log 2>&1
  else
      exec sway > /tmp/sway_debug.log 2>&1
  fi
}

# Tue May 19 2020 06:32: Since using a desktop manager this file is not sourced
# Sun Oct 26 2025 18:16 Not using a desktop manager again
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
    # Detect GPU and set environment variables
    detect_gpu_and_set_env

    exec_sway
fi
