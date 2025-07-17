# frozen_string_literal: true

module Editor
  class Base
    DEFAULTS = {
      group_box: { width: 0.17, height: 0.22 },
      text_box: { width: 0.1, height: 0.03 },
      check_box: { width: 0.02, height: 0.03 },
      value_box: { width: 0.06, height: 0.03 },
      value_box_float: { width: 0.06, height: 0.03 },
      dropdown_box: { width: 0.1, height: 0.03 },
      combo_box: { width: 0.1, height: 0.03 },
      button: { width: 0.08, height: 0.03 },
      list_view: { width: 0.080, height: 0.1 }
    }

    def initialize(*args)
      Gui.enable_tooltip
      @last_screen_width = Graphics.screen_width
      @last_screen_height = Graphics.screen_height
    end

    def update(dt)
      update_properties_on_resize if window_resized?
      %i[TEXTBOX VALUEBOX DROPDOWNBOX LISTVIEW].each do |control|
        Gui.set_style(Gui.const_get(control), Gui::TEXT_ALIGNMENT, Gui::TEXT_ALIGN_LEFT)
      end
    end

    def draw
    end

    private

    def initialize_properties(controls)
      @controls = controls
      @controls.each { |control_type, elements| setup_element_properties(control_type, elements) }
    end

    def setup_element_properties(control_type, elements)
      elements.each_value do |properties|
        properties[:scroll_index] = 0
        properties[:value_index] = 0
        properties[:recursive] = true
        set_control_dimensions(control_type, properties)
      end
    end

    def set_control_dimensions(control_type, properties)
      width = Graphics.screen_width * (properties[:width] || DEFAULTS[control_type][:width])
      height = Graphics.screen_height * (properties[:height] || DEFAULTS[control_type][:height])
      properties[:rect] = Rect.new(
        Graphics.screen_width * properties[:x],
        Graphics.screen_height * properties[:y],
        width, height
      )
    end

    def window_resized?
      resized = Graphics.screen_width != @last_screen_width || Graphics.screen_height != @last_screen_height
      @last_screen_width, @last_screen_height = Graphics.screen_width, Graphics.screen_height if resized
      resized
    end

    def update_properties_on_resize
      @controls.each { |control_type, elements| elements.each_value { |properties| set_control_dimensions(control_type, properties) } }
    end

    def draw_control(control_type, key, accessor: nil, special_value: nil, items: nil, sort: nil, index: nil)
      properties = @controls[control_type][key]
      properties[:value_index] = accessor ? get_accessor(accessor, key, special_value, items, sort, index) : properties[:value_index]

      new_value = draw_gui_control(control_type, properties[:value_index], properties, special_value)
      draw_label_for_gui_controls(control_type, properties) unless control_type == :label

      if new_value.is_a?(Array)
        properties[:scroll_index] = new_value[0] if control_type == :list_view
        result, new_value = control_type == :list_view ? [false, new_value[1]] : new_value
        properties[:value_index] = new_value
      else
        result = false
        properties[:value_index] = new_value
      end

      if result
        properties[:edit_mode] = !properties[:edit_mode]
        properties[:edit_mode] ? Gui.lock : Gui.unlock if control_type == :dropdown_box
      end

      editable_controls = [:text_box, :value_box, :value_box_float]
      clickable_controls = [:check_box, :dropdown_box, :list_view, :combo_box, :text_input_box, :button]

      if (editable_controls.include?(control_type) && properties[:edit_mode]) || clickable_controls.include?(control_type)
        accessor ? set_accessor(accessor, key, new_value, special_value, items, sort, index) : new_value
      end
    end

    def recursive_draw_control(controls, accessor = nil)
      results = []
      controls.each do |control_type, control_data|
        control_data.each do |key, properties|
          next unless properties[:recursive]
          result = properties[:accessor] ? draw_control(control_type, key, accessor: accessor) : draw_control(control_type, key)

          results << { result: result, key: key } if result && control_type == :button
        end
      end
      results.empty? ? nil : results
    end

    # def update_selected_item
    #   if @item_index < 0
    #     @item_index = @items.size - 1
    #   elsif @item_index >= @items.size
    #     @item_index = 0
    #   end
    #   @item_scroll_index = @item_index.clamp(0, @items.size - 20)
    #   @item = @items[@item_index]
    # end

    def draw_gui_control(control_type, key, properties, special_value)
      Gui.tooltip = properties[:tooltip] || '' if properties[:tooltip]
      case control_type
      when :label then Gui.label(properties[:label], properties[:rect])
      when :text_box then Gui.text_box(key, properties[:rect], properties[:length], properties[:edit_mode])
      when :value_box then Gui.value_box(properties[:original_label] || '', properties[:rect], key, properties[:min], properties[:max], properties[:edit_mode])
      when :value_box_float then Gui.value_box_float('', properties[:rect], properties[:text_value], key, properties[:edit_mode])
      when :check_box then Gui.check_box(properties[:original_label] || '', properties[:rect], key)
      when :group_box then Gui.group_box(properties[:label], properties[:rect])
      when :list_view then Gui.list_view(properties[:text] || special_value, properties[:rect], properties[:scroll_index], properties[:value_index])
      when :combo_box then Gui.combo_box(properties[:text] || special_value, properties[:rect], key)
      when :text_input_box then Gui.text_input_box(properties[:rect], properties[:title], properties[:message], properties[:buttons], properties[:text] || key, properties[:length], properties[:secret_view_active])
      when :button then Gui.button(properties[:label], properties[:rect])
      when :dropdown_box then Gui.dropdown_box(properties[:text] || special_value, properties[:rect], key, properties[:edit_mode])
      end
    end

    def draw_label_for_gui_controls(control_type, properties)
      if properties[:label_beside]
        Gui.label(properties[:label] || '', Rect.new(properties[:rect].x - 35, properties[:rect].y, 80, properties[:rect].height)) unless [:group_box, :button].include?(control_type) || control_type == :list_view && properties[:label].empty?
      else
        Gui.label(properties[:label] || '', Rect.new(properties[:rect].x - 65, properties[:rect].y, 80, properties[:rect].height)) unless [:group_box, :button].include?(control_type) || control_type == :list_view && properties[:label].empty?
      end
    end

    def get_accessor(data, key, special_value = nil, items = nil, sort = nil, index = nil)
      accessor = format_klass_accessors(key)
      value = data.send(accessor[:method])
      target = index ? value[index] : value
      target = value[accessor[:index]] if accessor[:index]
      #target = value[index, 1] if index && value.is_a?(Table)

      # Translate value using sort and items
      if items && sort
        sort.each_with_index do |sort_item, idx|
          return items.compact[idx].id if sort_item.id == target
        end
      end

      if accessor[:sub_method]
        target.send(accessor[:sub_method])
      elsif accessor[:index] && value.is_a?(Table)
        value[accessor[:index], 1]
      else
        target
      end
    end

    def set_accessor(data, key, new_value, special_value = nil, items = nil, sort = nil, index = nil)
      accessor = format_klass_accessors(key)
      value = data.send(accessor[:method])
      target = index ? value[index] : value
      #target = value[index, 1] if index && value.is_a?(Table)

      # Handle items and sort for setting the correct value
      if items && sort
        sort.each_with_index do |sort_item, idx|
          next unless sort_item.id == target

          target = items.compact[idx].id
        end
      end

      if accessor[:sub_method]
        target.send("#{accessor[:sub_method]}=", new_value)
      elsif accessor[:index] && value.is_a?(Table)
        value[accessor[:index], 1] = new_value
      else
        index ? target = new_value : data.send("#{accessor[:method]}=", new_value)
      end
    end

    def format_klass_accessors(key)
      key_str = key.to_s
      if key_str.start_with?('damage_')
        { method: 'damage', sub_method: key_str.split('damage_')[1] }
      elsif key_str.start_with?('effects_')
        { method: 'effects', sub_method: key_str.split('effects_')[1] }
      elsif key_str.start_with?('features_')
        { method: 'features', sub_method: key_str.split('features_')[1] }
      elsif key_str.start_with?('learnings_')
        { method: 'learnings', sub_method: key_str.split('learnings_')[1] }
      elsif key_str.start_with?('params_')
        { method: 'params', sub_method: nil, index: key_str.split('params_')[1].to_i }
      elsif key_str.start_with?('equips_')
        { method: 'equips', sub_method: nil }
      else
        { method: key_str, sub_method: nil }
      end
    end
  end
end
