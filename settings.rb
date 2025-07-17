# frozen_string_literal: true

module Settings
  WINDOW = {
    title: 'VXA Editor',
    icon: 'icon.png',
    fullscreen: false,
    width: 320 * 4, # Default width of the game window in pixels.
    height: 180 * 4, # Default height of the game window in pixels.
    integer_scale: 1, # Default scale of the resolution: 1: (320x180), 2: (640x360), 4: (1280x720) (HD), 6: (1920x1080) (UHD), 8: (3840x2160) (4K).
    vsync: true, # Enable or disable vertical synchronization.
    resizable: false, # Can the game window be resized by the user?
    texture_filter: 0, # Texture filtering: 0: (None), 1: (Linear), 2: (Trilinear), 3: (Anisotropic 4x),  4: (Anisotropic 8x), 5: (Anisotropic 16x).
    msaa_4x: false, # Multisample anti-aliasing: true: (4x), false: (None).
    borderless: false, # Should the window be borderless?
    maximized: false, # Should the window be maximized on startup?
    always_run: false # Should the game run when minimized?
  }
end
