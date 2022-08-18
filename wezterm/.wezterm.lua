local w = require 'wezterm'

return {

  font = w.font_with_fallback {
    'Cascadia Code',
    'Fira Code',
    'DengXian',
  },
  -- harfbuzz_features = {"calt=1", "clig=1", "liga=1"},
  window_close_confirmation = "NeverPrompt",

  hide_tab_bar_if_only_one_tab = true,

  -- The font size, measured in points
  font_size = 9.0,

  -- (available starting in version 20210203-095643-70a364eb)
  -- Scale the effective cell height.
  -- The cell height is computed based on your selected font_size
  -- and dpi and then multiplied by line_height.  Setting it to
  -- eg: 1.2 will result in the spacing between lines being 20%
  -- larger than the distance specified by the font author.
  -- Setting it to eg: 0.9 will make it 10% smaller.
  line_height = 1.0,

  -- When true (the default), text that is set to ANSI color
  -- indices 0-7 will be shifted to the corresponding brighter
  -- color index (8-15) when the intensity is set to Bold.
  --
  -- This brightening effect doesn't occur when the text is set
  -- to the default foreground color!
  --
  -- This defaults to true for better compatibility with a wide
  -- range of mature software; for instance, a lot of software
  -- assumes that Black+Bold renders as a Dark Grey which is
  -- legible on a Black background, but if this option is set to
  -- false, it would render as Black on Black.
  bold_brightens_ansi_colors = true,
}
