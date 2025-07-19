# frozen_string_literal: true

#--------------------------------------------------------------------------
# * Editor data
#--------------------------------------------------------------------------

module Editor
  class Data < Base
    DATA_CONTROLS = {
      group_box: {
        commands: { label: 'Commands', x: 0.812, y: 0.03, width: 0.183, height: 0.95 }
      },
      button: {
        quantity: { label: 'Quantity', action: nil, x: 0.910, y: 0.94 },
        save: { label: 'Save', x: 0, y: 0.95 },
        reset: { label: 'Reset', x: 0.822, y: 0.57 },
        delete_blank: { label: 'Delete Blank', x: 0.822, y: 0.53 },
        delete: { label: 'Delete', x: 0.822, y: 0.49 },
        redo: { label: 'Redo', x: 0.822, y: 0.45 },
        undo: { label: 'Undo', x: 0.822, y: 0.41 },
        paste: { label: 'Paste', x: 0.822, y: 0.37 },
        copy: { label: 'Copy', x: 0.822, y: 0.33 },
        move_down: { label: 'Move Down', x: 0.822, y: 0.29 },
        move_up: { label: 'Move Up', x: 0.822, y: 0.25 },
        new_below: { label: 'Insert Below', x: 0.822, y: 0.21 },
        new_above: { label: 'Insert Above', x: 0.822, y: 0.17 },
        duplicate: { label: 'Duplicate', x: 0.822, y: 0.13 },
        new: { label: 'New', x: 0.822, y: 0.09 }
      },
      check_box: {
        autosave: { label: 'Autosave', x: 0.005, y: 0.91 }
      },
      text_box: {
        search: { length: 50, x: 0.910, y: 0.90, width: 0.08 }
      },
      value_box: {
        quantity: { min: 1, max: 99_999, x: 0.822, y: 0.05, width: 0.08 }
      },
      list_view: {
        editor: { label: '', x: 0, y: 0.01, height: 0.88 },
        item: { label: '', x: 0.910, y: 0.05, height: 0.84 }
      }
    }

    def initialize
      super
      initialize_properties(DATA_CONTROLS)
      @editor_list_view = DATA_CONTROLS[:list_view][:editor]
      @editor_list_view[:value_index] = Editor.index
      @previous_editor_index = @editor_list_view[:value_index]
      @file_path = File.join("Project/Data/#{Editor.filename(@editor_list_view[:value_index])}")
      @klass = Editor.rpg_klass(@editor_list_view[:value_index])
      initialize_items
      @autosave = false
      @search_query = ''
      @undo_stack = []
      @redo_stack = []
      @quantity = 1
      @edit_modes = {}
      @levenshtein_cache = {}
      @cache_limit = 1000
    end

    def update(dt)
      super
      Editor.select(@editor_list_view[:value_index]) if selected_editor_index_changed?
      update_items
      update_keyboard
      update_search_items if @search_query
    end

    def selected_editor_index_changed?
      current_index = @editor_list_view[:value_index]
      changed = current_index != @previous_editor_index
      @previous_editor_index = current_index
      changed
    end

    def draw
      super
      Gui.group_box(DATA_CONTROLS[:group_box][:commands][:label], DATA_CONTROLS[:group_box][:commands][:rect])
      draw_list_view(:editor, Editor.list)
      result_search, @search_query = Gui.text_box(@search_query, DATA_CONTROLS[:text_box][:search][:rect], DATA_CONTROLS[:text_box][:search][:length], @edit_modes[:search])
      @edit_modes[:search] = !@edit_modes[:search] if result_search
      @item_scroll_index, @item_index = Gui.list_view(@item_names, DATA_CONTROLS[:list_view][:item][:rect], @item_scroll_index, @item_index)
      @autosave = Gui.check_box(DATA_CONTROLS[:check_box][:autosave][:label], DATA_CONTROLS[:check_box][:autosave][:rect], @autosave)

      DATA_CONTROLS[:button].each do |symbol, properties|
        send(:"action_item_#{symbol}") if Gui.button(properties[:label], properties[:rect])
      end
      result_quantity, @quantity = Gui.value_box('', DATA_CONTROLS[:value_box][:quantity][:rect], @quantity,
                                                DATA_CONTROLS[:value_box][:quantity][:min], DATA_CONTROLS[:value_box][:quantity][:max], @edit_modes[:quantity])
      @edit_modes[:quantity] = !@edit_modes[:quantity] if result_quantity
    end

    def draw_list_view(key, text)
      list_view = DATA_CONTROLS[:list_view][key]
      list_view[:scroll_index], list_view[:value_index] = Gui.list_view(
        text || [], list_view[:rect], list_view[:scroll_index], list_view[:value_index]
      )
    rescue StandardError => e
      puts "ERROR: Failed to draw list view for key '#{key}': #{e.message}"
    end

    def unload
      action_item_save if @autosave
    end

    def update_properties_on_resize
      super
      DATA_CONTROLS.each do |control_type, elements|
        elements.each_value { |properties| set_control_dimensions(control_type, properties) }
      end
    end

    def initialize_items
      @items = load_items.compact
      @items = [@klass.new] if @items.empty?
      update_item_names_and_cache
      # @items.each do |item|
      #   unless item.effects.nil? || item.effects.empty?
      #     item.effects.each do |effect|
      #       effect.value1 = (effect.value1 * 100).to_i if effect.value1.is_a?(Float) && (effect.value1 < 1.0 || effect.value1 == 1.0)
      #     end
      #   end
      #   unless item.features.nil? || item.features.empty?
      #     item.features.each do |feature|
      #       feature.value = (feature.value * 10).to_i if feature.value.is_a?(Float) && (feature.value < 1.0 || feature.value == 1.0)
      #     end
      #   end
      # end
      @item = @items.first
      @item_scroll_index = 0
      @item_index = 0
      @items_changed = false
    end

    def safe_attribute(obj, attribute, default, force = false)
      obj.send("#{attribute}=", default) if force || obj.send(attribute).nil?
    end

    def load_items
      return [nil, @klass.new] unless File.exist?(@file_path) && File.size(@file_path).positive?
      load_data(@file_path)
    rescue StandardError => e
      puts "ERROR: Failed to load items from #{@file_path}: #{e.message}"
      [nil, @klass.new]
    end

    def update_item_names_and_cache
      @item_names = []
      @item_name_cache = []
      @items.each_with_index do |item, index|
        name = update_item_name(item, index + 1)
        @item_names << name
        @item_name_cache << name.downcase
      end
      @items_changed = false
    end

    def update_item_name(item, id)
      safe_attribute(item, :id, id, true)
      safe_attribute(item, :name, "Item #{item.id}")
      "#{item.id} - #{item.name}"
    end

    def update_items
      @item = @items[@item_index]
      update_item_names_and_cache
      DATA_CONTROLS[:button][:quantity][:label] = "Quantity - #{@items.length}"
    end

    def update_keyboard
      if Input.down?(:ctrl)
        action_item_undo if Keyboard.released?(Keyboard::Z)
        action_item_redo if Keyboard.released?(Keyboard::Y)
        action_item_copy if Keyboard.released?(Keyboard::C)
        action_item_paste if Keyboard.released?(Keyboard::V)
      end
      if Keyboard.released?(Keyboard::UP)
        @item_index -= 1
        @item_scroll_index -= 1
        update_selected_item
      end
      if Keyboard.released?(Keyboard::DOWN)
        @item_index += 1
        @item_scroll_index += 1
        update_selected_item
      end
      if Keyboard.released?(Keyboard::DELETE)
        action_item_delete
        @item_scroll_index -= 1
      end
    end

    def update_search_items
      return if @search_query.empty?
      if Mouse.button_released?(Mouse::BUTTON_LEFT) && !DATA_CONTROLS[:text_box][:search][:rect].point?(Mouse.position)
        @search_query = ''
        return
      end
      @item_index = action_item_search(@search_query.downcase) || 0
      @item_scroll_index = @item_index.clamp(0, [@items.size - 20, 0].max)
      @item = @items[@item_index]
    end

    def action_item_search(query)
      @item_name_cache.each_with_index.find { |name, index| partial_match(query, name) }&.last || 0
    end

    def partial_match(query, item_name, threshold = 0.7)
      return true if item_name.include?(query)
      cache_key = "#{query}-#{item_name}"
      @levenshtein_cache[cache_key] ||= Text.levenshtein_distance(query, item_name)
      @levenshtein_cache.shift if @levenshtein_cache.size > @cache_limit
      (1.0 - (@levenshtein_cache[cache_key].to_f / [query.length, item_name.length].max)) >= threshold
    end

    def action_item_save
      items = @items.map.with_index { |item, index| item.dup.tap { |i| i.id = index + 1 } }
      save_data([nil, *items], @file_path)
      puts "INFO: Items have been saved to #{@file_path}."
    end

    def action_item_new
      save_item_state(@undo_stack)
      @quantity.times { @items << @klass.new }
      @items_changed = true
      @item_index = @items.size - @quantity
      update_selected_item
      puts "INFO: Item has been created. Click 'Save' to persist changes."
    end

    def action_item_copy
      return if @item.nil?
      @copied_item = @item.dup
      puts "INFO: Item has been copied. Use 'Paste' to insert it."
    end

    def action_item_paste
      return if @copied_item.nil?
      save_item_state(@undo_stack)
      @items[@item_index] = @copied_item.dup
      @items_changed = true
      update_selected_item
      puts "INFO: Copied item has been pasted at the current index. Click 'Save' to persist changes."
    end

    def action_item_duplicate
      return if @item.nil?
      save_item_state(@undo_stack)
      @items.insert(@item_index + 1, @item.dup)
      @item_index += 1
      @items_changed = true
      update_selected_item
      puts "INFO: Item has been duplicated. Click 'Save' to persist changes."
    end

    def action_item_new_above
      save_item_state(@undo_stack)
      @items.insert(@item_index, @klass.new)
      @items_changed = true
      update_selected_item
      puts "INFO: Item has been added above. Click 'Save' to persist changes."
    end

    def action_item_new_below
      save_item_state(@undo_stack)
      @items.insert(@item_index + 1, @klass.new)
      @items_changed = true
      update_selected_item
      puts "INFO: Item has been added below. Click 'Save' to persist changes."
    end

    def action_item_move_up
      return unless @item_index.positive?
      save_item_state(@undo_stack)
      @items[@item_index], @items[@item_index - 1] = @items[@item_index - 1], @items[@item_index]
      @item_index -= 1
      @items_changed = true
      update_selected_item
      puts "INFO: Item has been moved up. Click 'Save' to persist changes."
    end

    def action_item_move_down
      return unless @item_index < @items.size - 1
      save_item_state(@undo_stack)
      @items[@item_index], @items[@item_index + 1] = @items[@item_index + 1], @items[@item_index]
      @item_index += 1
      @items_changed = true
      update_selected_item
      puts "INFO: Item has been moved down. Click 'Save' to persist changes."
    end

    def action_item_undo
      return if @undo_stack.empty?
      save_item_state(@redo_stack)
      @items = @undo_stack.pop
      @items_changed = true
      update_selected_item
      puts 'INFO: Undo operation performed.'
    end

    def action_item_redo
      return if @redo_stack.empty?
      save_item_state(@undo_stack)
      @items = @redo_stack.pop
      @items_changed = true
      update_selected_item
      puts 'INFO: Redo operation performed.'
    end

    def action_item_delete
      save_item_state(@undo_stack)
      if @items.size > 1
        @items.delete_at(@item_index)
        @item_index = [@item_index - 1, 0].max
      else
        @items = [@klass.new]
      end
      @items_changed = true
      update_selected_item
      puts "INFO: Item has been deleted. Click 'Save' to persist changes."
    end

    def action_item_delete_blank
      save_item_state(@undo_stack)
      @items.reject! { |item| item.name.to_s.strip.empty? }
      @items = [@klass.new] if @items.empty?
      @item_index = [@item_index, @items.size - 1].min
      @item_index = 0 if @items[@item_index]&.name.to_s.strip.empty?
      @items_changed = true
      update_selected_item
      puts "INFO: Items with empty names have been deleted. Click 'Save' to persist changes."
    end

    def action_item_reset
      save_item_state(@undo_stack)
      @items = load_items
      @item_index = 0
      @items_changed = true
      update_selected_item
      puts 'INFO: Items have been reset to the original state.'
    end

    def action_export_json
      export_dir = 'Project/Export'
      FileUtils.mkdir_p(export_dir) unless Dir.exist?(export_dir)
      export_path = File.join(export_dir, "#{Editor.name(@editor_list_view[:value_index])}s.json")
      data = @items.map(&:to_h)
      File.write(export_path, JSON.pretty_generate(data))
    rescue StandardError => e
      puts "ERROR: Failed to export JSON to #{export_path}: #{e.message}"
    end

    def action_export_csv
      export_dir = 'Project/Export'
      FileUtils.mkdir_p(export_dir) unless Dir.exist?(export_dir)
      export_path = File.join(export_dir, "#{Editor.name(@editor_list_view[:value_index])}s.csv")
      data = @items.map(&:to_h)
      CSV.open(export_path, 'wb') do |csv|
        csv << data.first.keys unless data.empty?
        data.each { |item| csv << item.values }
      end
    rescue StandardError => e
      puts "ERROR: Failed to export CSV to #{export_path}: #{e.message}"
    end

    def action_sort(attribute)
      save_item_state(@undo_stack)
      @items.sort_by! { |item| item.send(attribute) }
      @items_changed = true
      update_selected_item
      puts "INFO: Items sorted by '#{attribute}'. Click 'Save' to persist changes."
    end

    def action_replace(attribute, old_value, new_value)
      save_item_state(@undo_stack)
      @items.each { |item| item.send("#{attribute}=", new_value) if item.send(attribute) == old_value }
      @items_changed = true
      update_selected_item
      puts "INFO: Replaced '#{old_value}' with '#{new_value}' in '#{attribute}' across all items."
    end

    def save_item_state(stack)
      stack.push(@items.map(&:dup))
      stack.shift if stack.size > 50
    end

    def update_selected_item
      return if @items.empty?
      @item_index = 0 if @item_index.negative?
      @item_index = @items.size - 1 if @item_index >= @items.size
      @item_scroll_index = @item_index.clamp(0, [@items.size - 20, 0].max)
      @item = @items[@item_index]
      update_item_names_and_cache if @items_changed
    end

    def action_item_copy_value(controls)
      process_item_value(controls) { |key, _| Keyboard.clipboard_text = @item[key] }
    end

    def action_item_paste_value(controls)
      process_item_value(controls) do |key, _|
        save_item_state(@undo_stack)
        @item[key] = Keyboard.clipboard_text
        @items_changed = true
      end
    end

    def process_item_value(controls)
      %i[text_box value_box].each do |box_type|
        controls[box_type]&.each do |key, properties|
          yield(key, properties) if properties[:edit_mode]
        end
      end
    end
  end
end
