local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.automatically_reload_config = true
config.font = wezterm.font("MesloLGS Nerd Font Mono", { weight = "Bold" })
config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.default_cursor_style = "BlinkingBar"
config.color_scheme = "Nord (Gogh)"
config.window_background_opacity = 1.0
config.macos_window_background_blur = 0

config.background = {
  {
    source = { File = '/Users/egt/Documents/1315150.jpg' },
    hsb = { brightness = 0.05, saturation = 0.8 },
    opacity = 0.9,
  },
}

return config
