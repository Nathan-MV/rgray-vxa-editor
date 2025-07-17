# frozen_string_literal: false

module Graphics
  class << self
    attr_reader :width
    attr_reader :height
    attr_reader :default_width
    attr_reader :default_height
    attr_reader :scale
    attr_reader :brightness

    def setup
      config_flags
      setup_window
      setup_icon
    end

    def update
      update_fadeout if @fadeout_elapsed_time && @fadeout_elapsed_time < @fadeout_duration
      update_fadein if @fadein_elapsed_time && @fadein_elapsed_time < @fadein_duration
      update_transition if @transitioning
      @fps = !@fps if Input.released?(:f2)
    end

    def draw
      @rect.draw(Color.new(255, 255, 255, 255 - @brightness)) unless @brightness == 255
      draw_fps(0, 0) if @fps
    end

    def scale=(scale)
      @scale = scale.clamp(1, 16)
      @width = @default_width * @scale
      @height = @default_height * @scale
      # @rect.set(0, 0, @width, @height)
      size(@width, @height)
    end

    # Returns the X-coordinate of the center of the window.
    def center_x = @width / 2

    # Returns the Y-coordinate of the center of the window.
    def center_y = @height / 2

    def brightness=(value)
      @brightness = [[value, 0].max, 255].min
    end

    def fadeout(duration)
      @fadeout_duration = duration.to_f
      @fadeout_brightness = @brightness
      @fadeout_elapsed_time = 0.0
    end

    def fadein(duration)
      @fadein_duration = duration.to_f
      @fadein_brightness = @brightness
      @fadein_elapsed_time = 0.0
    end

    # Set up the transition state and start the transition
    def transition(duration = 10, filename = nil, vague = 40)
      @transition_duration = duration
      filename ? @transition_image = Sprite.new(filename) : @transition_image = nil
      @transition_vague = vague
      @transitioning = true
      @transition_elapsed = 0.0
    end

    def snap_to_bitmap
      bmp = Bitmap.new(@width, @height)
      bmp.from_screen
    end
    alias snap snap_to_bitmap

    private

    def config_flags
      flags = 0
      flags |= VSYNC if Settings::WINDOW[:vsync]
      flags |= FULLSCREEN if Settings::WINDOW[:fullscreen]
      flags |= RESIZABLE if Settings::WINDOW[:resizable]
      flags |= MAXIMIZED if Settings::WINDOW[:maximized]
      flags |= ALWAYS_RUN if Settings::WINDOW[:always_run]
      flags |= BORDERLESS_WINDOWED if Settings::WINDOW[:borderless]
      flags |= MSAA_4X if Settings::WINDOW[:msaa_4x]
      self.config_flags = flags
    end

    def setup_icon
      bmp = Bitmap.new(Settings::WINDOW[:icon])
      self.icon = bmp
    end

    def setup_window
      @default_width = Settings::WINDOW[:width]
      @default_height = Settings::WINDOW[:height]
      @rect = Rect.new(0, 0,
                       @default_width,
                       @default_height)
      self.scale = Settings::WINDOW[:integer_scale]
      @brightness = 255
      @fps = true
      init(@width, @height, Settings::WINDOW[:title])
      # self.target_fps = refresh_rate(current_monitor)
      self.exit_key = 0
    end

    def update_fadeout
      @fadeout_elapsed_time += delta * refresh_rate(current_monitor)
      t = [@fadeout_elapsed_time / @fadeout_duration, 1.0].min
      @brightness = Math.lerp(@fadeout_brightness, 0, t)
      @fadeout_elapsed_time = nil if t >= 1.0
    end

    def update_fadein
      @fadein_elapsed_time += delta * refresh_rate(current_monitor)
      t = [@fadein_elapsed_time / @fadein_duration, 1.0].min
      @brightness = Math.lerp(@fadein_brightness, 255, t)
      @fadein_elapsed_time = nil if t >= 1.0
    end

    # Update the transition state every frame if a transition is active
    def update_transition
      return unless @transitioning

      @transition_elapsed += delta * refresh_rate(current_monitor)
      progress = [@transition_elapsed / @transition_duration, 1.0].min
      if @transition_image
        @transition_image.brightness = (255 * (1.0 - progress)).to_i
      else
        @brightness = 255 * (1.0 - progress)
      end

      return unless progress >= 1.0

      @transitioning = false
      @transition_image&.dispose
      @brightness = 255
    end
  end
end

# # frozen_string_literal: true

# Graphics = Window
# module Graphics
#   @default_width = 544
#   @default_height = 416
#   @width = 0
#   @height = 0
#   @scale = 1
#   @previous_scale = 0
#   @sprites = [].freeze
#   @viewports = [].freeze
#   @brightness = 255
#   @frame_rate = 40

#   class << self
#     attr_accessor :frame_count
#     attr_reader :width
#     attr_reader :height
#     attr_accessor :frame_rate
#     attr_reader :brightness

#     def update
#       update_scaled_dimensions if @scale != @previous_scale
#       Draw.begin do
#         Draw.clear(COLORS[:black])
#         draw
#       end
#     end

#     alias wait wait_time

#     def fadeout(duration)
#       step_size = 255 / duration.to_f
#       duration.times do |elapsed|
#         @brightness = [255 - (elapsed * step_size).to_i, 0].max
#       end
#       @brightness = 0
#     end

#     def fadein(duration)
#       step_size = 255 / duration.to_f
#       duration.times do |elapsed|
#         @brightness = [(elapsed * step_size).to_i, 255].min
#       end
#       @brightness = 255
#     end

#     alias freeze enable_event_waiting

#     def transition; end

#     alias snap_to_bitmap to_image


#     def frame_reset; end

#     alias resize_screen size

#     def play_movie(filename); end

#     def brightness=(value)
#       @brightness = [[value, 0].max, 255].min
#     end

#     # =================================
#     # Extra
#     # =================================

#     def start
#       @width = @default_width * @scale
#       @height = @default_height * @scale
#       @rect = Rect.new(0, 0, @width, @height)
#       init(@width, @height, 'Game')
#       0
#     end

#     def add_sprite(sprite)
#       @sprites << sprite
#     end

#     def remove_sprite(sprite)
#       @sprites.delete(sprite)
#     end

#     def add_viewport(viewport)
#       @viewports << viewport
#     end

#     def remove_viewport(viewport)
#       @viewports.delete(viewport)
#     end

#     def scale=(scale)
#       @previous_scale = @scale
#       @scale = scale.clamp(1, 16)
#     end

#     def center_x
#       @width / 2
#     end

#     def center_y
#       @height / 2
#     end

#     private

#     def update_scaled_dimensions
#       @width = @default_width * @scale
#       @height = @default_height * @scale
#       size(@width, @height)
#     end

#     def draw
#       @sprites.each(&:draw)
#       @viewports.each(&:draw)
#       @rect.draw(Color.new(0, 0, 0, 255 - @brightness)) unless @brightness == 255
#     end
#   end
# end
