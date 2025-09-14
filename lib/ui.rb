class Ui
  # Cache for Rect objects to avoid per-frame allocations
  RECT_CACHE = Hash.new { |h, k| h[k] = Rect.new(*k) }
  # Sizes
  ITEM_HEIGHT = 24
  ITEM_SPACING = 4
  BORDER_WIDTH = 2
  SCROLL_WIDTH = 12
  FONT_SIZE = 10
  TEXT_OFFSET_X = 0
  TEXT_OFFSET_Y = 8

  # Colors
  COLOR_BG = COLORS[:white_smoke] # background
  COLOR_BG_ACTIVE = COLORS[:light_blue_raygui] # item hover/selected background
  COLOR_BORDER = COLORS[:dark_gray] # item border lines
  COLOR_BORDER_ACTIVE = COLORS[:blue_raygui] # item border when selected
  COLOR_SCROLL = COLORS[:light_gray] # scrollbar track
  COLOR_SCROLL_THUMB = COLORS[:dark_gray] # scrollbar thumb normal
  COLOR_SCROLL_THUMB_HOVER = COLORS[:light_blue_raygui] # thumb hover
  COLOR_SCROLL_THUMB_ACTIVE = COLORS[:blue_raygui] # thumb dragging

  # Text colors
  COLOR_TEXT_NORMAL = COLORS[:dark_gray]
  COLOR_TEXT_HOVER = COLORS[:blue_raygui]
  COLOR_TEXT_SELECTED = COLORS[:blue_raygui]

  attr_accessor :scroll_dragging, :scroll_drag_offset

  def initialize
    @font = Font.new("KAISG.ttf")
    @scroll_dragging = false
    @scroll_drag_offset = 0
  end

  # Draw text clipped to a maximum width
  def draw_text_clipped(text, x, y, size, color, max_width)
    # fast exit
    if @font.measure_ex(text, size, 2).x <= max_width
      @font.draw(text, x, y, size, color)
      return
    end

    # binary search to find max substring that fits
    low, high = 0, text.length
    while low < high
      mid = (low + high + 1) / 2
      width = @font.measure_ex(text[0...mid], size, 2).x
      if width <= max_width
        low = mid
      else
        high = mid - 1
      end
    end

    # draw truncated string
    @font.draw(text[0...low], x, y, size, color)
  end

  # Simple button method, returns true if clicked
  def button(rect, label, color: COLOR_SCROLL, text_color: COLOR_TEXT_NORMAL)
    mouse = Mouse.position
    clicked = rect.point?(mouse) && Mouse.button_pressed?(Mouse::BUTTON_LEFT)
    rect.draw(color)
    draw_text_clipped(label, rect.x + 4, rect.y + 4, FONT_SIZE, text_color, rect.width - 8)
    clicked
  end

  # List view with scrolling
  def list_view(items, bounds, scroll_index, active, focus = -1)
    count = items.size
    return [scroll_index, active, focus] if count == 0
    step = ITEM_HEIGHT + ITEM_SPACING
    use_scrollbar = step * count > bounds.height
    visible = [(bounds.height / step).to_i, count].min
    max_scroll = [count - visible, 0].max
    scroll_index = scroll_index.clamp(0, max_scroll)
    end_index = [scroll_index + visible, count].min
    mouse = Mouse.position

    # Handle hovering and selection
    hovered = -1
    if bounds.point?(mouse)
      y0 = bounds.y + ITEM_SPACING + BORDER_WIDTH
      y1 = bounds.y + visible * step + ITEM_SPACING + BORDER_WIDTH
      if mouse.y.between?(y0, y1)
        hovered = scroll_index + ((mouse.y - y0) / step).to_i
        if hovered.between?(scroll_index, end_index - 1)
          focus = hovered
          active = (active == hovered ? -1 : hovered) if Mouse.button_pressed?(Mouse::BUTTON_LEFT)
        end
      end
      if use_scrollbar && Mouse.wheel_move != 0
        scroll_index = (scroll_index - Mouse.wheel_move.to_i).clamp(0, max_scroll)
        end_index = [scroll_index + visible, count].min
      end
    end

    # Draw background
    bounds.draw(COLOR_BG)
    bounds.draw_lines(COLOR_BORDER)

    # Precompute item rects and colors, cache Rects
    item_rects = []
    y = bounds.y + ITEM_SPACING + BORDER_WIDTH
    w = bounds.width - 2 * ITEM_SPACING - BORDER_WIDTH - (use_scrollbar ? SCROLL_WIDTH : 0) + 4
    visible.times do |i_offset|
      i = scroll_index + i_offset
      break if i >= end_index
      rect_key = [bounds.x + ITEM_SPACING - 2, y - 2, w, ITEM_HEIGHT + 2]
      item_rects << RECT_CACHE[rect_key]
      y += step
    end

    # Draw visible items
    y = bounds.y + ITEM_SPACING + BORDER_WIDTH
    item_rects.each_with_index do |item_rect, i_offset|
      i = scroll_index + i_offset
      break if i >= end_index
      bg_color = (i == active || (i == focus && !@scroll_dragging)) ? COLOR_BG_ACTIVE : nil
      border_color = (i == active || (i == focus && !@scroll_dragging)) ? COLOR_BORDER_ACTIVE : nil
      text_color = if i == active
                     COLOR_TEXT_SELECTED
                   elsif i == focus && !@scroll_dragging
                     COLOR_TEXT_HOVER
                   else
                     COLOR_TEXT_NORMAL
                   end
      item_rect.draw(bg_color) if bg_color
      item_rect.draw_lines(border_color) if border_color
      draw_text_clipped(items[i], bounds.x + ITEM_SPACING + TEXT_OFFSET_X, y + TEXT_OFFSET_Y, FONT_SIZE, text_color,
                        bounds.width - 2 * ITEM_SPACING - BORDER_WIDTH - (use_scrollbar ? SCROLL_WIDTH : 0))
      y += step
    end

    # Draw scrollbar
    if use_scrollbar
      sx = bounds.x + bounds.width - BORDER_WIDTH - SCROLL_WIDTH
      sy = bounds.y + BORDER_WIDTH
      sh = bounds.height - 2 * BORDER_WIDTH
      scroll_rect_key = [sx, sy, SCROLL_WIDTH, sh]
      RECT_CACHE[scroll_rect_key].draw(COLOR_SCROLL)

      thumb_h = [(sh * visible.to_f / count).to_i, ITEM_HEIGHT].max
      thumb_y = sy + (sh - thumb_h) * (scroll_index.to_f / max_scroll)
      thumb_key = [sx, thumb_y, SCROLL_WIDTH, thumb_h]
      thumb = RECT_CACHE[thumb_key]
      color = COLOR_SCROLL_THUMB

      if !@scroll_dragging && thumb.point?(mouse) && Mouse.button_pressed?(Mouse::BUTTON_LEFT)
        @scroll_dragging = true
        @scroll_drag_offset = mouse.y - thumb_y
      end

      if @scroll_dragging
        if Mouse.button_down?(Mouse::BUTTON_LEFT)
          scroll_index = (((mouse.y - sy - @scroll_drag_offset) / (sh - thumb_h)) * max_scroll).round.clamp(0, max_scroll)
          color = COLOR_SCROLL_THUMB_ACTIVE
        else
          @scroll_dragging = false
        end
      elsif RECT_CACHE[scroll_rect_key].point?(mouse) && Mouse.button_pressed?(Mouse::BUTTON_LEFT)
        scroll_index += mouse.y < thumb_y ? -visible : (mouse.y > thumb_y + thumb_h ? visible : 0)
        scroll_index = scroll_index.clamp(0, max_scroll)
      elsif thumb.point?(mouse)
        color = COLOR_SCROLL_THUMB_HOVER
      end

      thumb.draw(color)
    end

    # Clear per-frame text width cache
    @text_width_cache = nil

    [scroll_index, active, focus]
  end
end
