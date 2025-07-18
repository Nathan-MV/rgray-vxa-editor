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
        save: { label: 'Save', action: :save, x: 0, y: 0.95 },
        reset: { label: 'Reset', action: :reset, x: 0.822, y: 0.57 },
        delete_blank: { label: 'Delete Blank', action: :delete_blank, x: 0.822, y: 0.53 },
        delete: { label: 'Delete', action: :delete, x: 0.822, y: 0.49 },
        redo: { label: 'Redo', action: :redo, x: 0.822, y: 0.45 },
        undo: { label: 'Undo', action: :undo, x: 0.822, y: 0.41 },
        paste: { label: 'Paste', action: :paste, x: 0.822, y: 0.37 },
        copy: { label: 'Copy', action: :copy, x: 0.822, y: 0.33 },
        move_down: { label: 'Move Down', action: :move_down, x: 0.822, y: 0.29 },
        move_up: { label: 'Move Up', action: :move_up, x: 0.822, y: 0.25 },
        new_below: { label: 'Insert Below', action: :new_below, x: 0.822, y: 0.21 },
        new_above: { label: 'Insert Above', action: :new_above, x: 0.822, y: 0.17 },
        duplicate: { label: 'Duplicate', action: :duplicate, x: 0.822, y: 0.13 },
        new: { label: 'New', action: :new, x: 0.822, y: 0.09 }
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
      DATA_CONTROLS[:list_view][:editor][:value_index] = Editor.index
      @previous_editor_index = DATA_CONTROLS[:list_view][:editor][:value_index]
      initialize_items
      @autosave = false
      @search_query = ''
      @undo_stack = []
      @redo_stack = []
      @quantity = 1
      @edit_modes = Hash.new(false)
    end

    def update(dt)
      super
      Editor.select(DATA_CONTROLS[:list_view][:editor][:value_index]) if selected_editor_index_changed?
      update_items
      update_keyboard
      update_search_items
    end

    def selected_editor_index_changed?
      current_index = DATA_CONTROLS[:list_view][:editor][:value_index]
      changed = current_index != @previous_editor_index
      @previous_editor_index = current_index
      changed
    end

    def draw
      super
      Gui.group_box(DATA_CONTROLS[:group_box][:commands][:label], DATA_CONTROLS[:group_box][:commands][:rect])
      draw_list_view(:editor, Editor.list)
      #draw_control(:list_view, :editor, special_value: Editor.list)
      result_search, @search_query = Gui.text_box(@search_query, DATA_CONTROLS[:text_box][:search][:rect],
                                                  DATA_CONTROLS[:text_box][:search][:length], @edit_modes[:search])
      @edit_modes[:search] = !@edit_modes[:search] if result_search
      @item_scroll_index, @item_index = Gui.list_view(@item_names, DATA_CONTROLS[:list_view][:item][:rect],
                                                      @item_scroll_index, @item_index)
      @autosave = Gui.check_box(DATA_CONTROLS[:check_box][:autosave][:label],
                                DATA_CONTROLS[:check_box][:autosave][:rect], @autosave)
      DATA_CONTROLS[:button].each do |symbol, properties|
        send(:"action_item_#{symbol}") if Gui.button(properties[:label], properties[:rect]) && properties[:action]
      end
      result_quantity, @quantity = Gui.value_box('', DATA_CONTROLS[:value_box][:quantity][:rect], @quantity,
                                                 DATA_CONTROLS[:value_box][:quantity][:min], DATA_CONTROLS[:value_box][:quantity][:max], @edit_modes[:quantity])
      @edit_modes[:quantity] = !@edit_modes[:quantity] if result_quantity
    end

    def draw_list_view(key, text, _accessor = nil)
      DATA_CONTROLS[:list_view][key][:scroll_index], DATA_CONTROLS[:list_view][key][:value_index] = Gui.list_view(
        text || [], DATA_CONTROLS[:list_view][key][:rect], DATA_CONTROLS[:list_view][key][:scroll_index], DATA_CONTROLS[:list_view][key][:value_index]
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
      @file_path = File.join("Project/Data/#{Editor.filename(DATA_CONTROLS[:list_view][:editor][:value_index])}")
      @klass = Editor.rpg_klass(DATA_CONTROLS[:list_view][:editor][:value_index])
      @items = load_items.compact
      @items = [@klass.new] if @items.empty?
      @item_names = @items.map do |item|
        safe_attribute(item, :id, @items.index(item) + 1, true)
        safe_attribute(item, :name, "Item #{item.id}")
        "#{item.id} - #{item.name}"
      end
      # @items.each do |item|
      # unless item.effects.empty? || item.effects.nil?
      #   item.effects.each do |effect|
      #     if effect.value1.to_s.start_with?('0.') || effect.value1.to_s.start_with?('1.0')
      #       effect.value1 = (effect.value1 * 100).to_i
      #     end
      #   end
      # end
      # item.features.each do |feature|
      #   if feature.value.to_s.start_with?('0.') || feature.value.to_s.start_with?('1.0')
      #     feature.value = (feature.value * 10).to_i
      #   end
      # end
      # end
      @item_name_cache = @items.map { |item| item.name.downcase }
      @item = @items.first
      @item_scroll_index = 0
      @item_index = 0
      @items_changed = false
    end

    def safe_attribute(obj, attribute, default, force = false)
      obj.send("#{attribute}=", default) if force || obj.send(attribute).nil?
    end

    def load_items
      if File.exist?(@file_path) && File.size(@file_path).positive?
        load_data(@file_path)
      else
        puts 'INFO: File does not exist or is empty. Initializing with default template.'
        begin
          save_data([nil, @klass.new], @file_path)
          load_data(@file_path)
        rescue StandardError => e
          puts "ERROR: Failed to initialize items at #{@file_path}: #{e.message}"
          [nil, @klass.new]
        end
      end
    end

    def update_items
      if @items_changed
        @item_names = @items.map { |item| "#{item.id} - #{item.name}" }
        @item_name_cache = @items.map { |item| item.name.downcase }
        @items_changed = false
      end
      @item = @items[@item_index]
      DATA_CONTROLS[:button][:quantity][:label] = "Quantity - #{@items.length}"
    end

    def update_keyboard
      if Mouse.button_down?(Mouse::BUTTON_LEFT)
        action_item_undo if Input.released?(:special)
        action_item_copy if Input.released?(:confirm)
        action_item_paste if Input.released?(:menu)
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
      return unless Keyboard.released?(Keyboard::DELETE)

      action_item_delete
      @item_scroll_index -= 1
    end

    def update_search_items
      return if @search_query.empty?
      if Mouse.button_released?(Mouse::BUTTON_LEFT) && !DATA_CONTROLS[:text_box][:search][:rect].point?(Mouse.position)
        @search_query = ''
      end
      @item_index = action_item_search(@search_query.downcase) || 0
      @item_scroll_index = @item_index.clamp(0, [@items.size - 20, 0].max)
      @item = @items[@item_index]
    end

    def action_item_search(query)
      @item_name_cache.each_with_index do |name, index|
        return index if partial_match(query, name)
      end
      0
    end

    def partial_match(query, item_name, threshold = 0.7)
      return true if item_name.include?(query)
      @levenshtein_cache ||= {}
      cache_key = "#{query}-#{item_name}"
      distance = @levenshtein_cache[cache_key] ||= Text.levenshtein_distance(query, item_name)
      (1.0 - (distance.to_f / [query.length, item_name.length].max)) >= threshold
    end

    def action_item_save
      items = @items.dup
      items.each_with_index { |item, index| item.id = index + 1 }
      save_data(items.unshift(nil), @file_path)
      puts "INFO: Items have been saved to #{@file_path}."
    end

    def action_item_new
      save_item_state(@undo_stack)
      @quantity.times { @items << @klass.new }
      @items.each_with_index { |item, index| item.id = index + 1 }
      @item_index = @items.size - @quantity
      @item = @items.last
      @items_changed = true
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
      pasted_item = @copied_item.dup
      @items[@item_index] = pasted_item
      @items_changed = true
      update_selected_item
      puts "INFO: Copied item has been pasted at the current index. Click 'Save' to persist changes."
    end

    def action_item_duplicate
      return if @item.nil?
      save_item_state(@undo_stack)
      duplicated_item = @item.dup
      @items.insert(@item_index + 1, duplicated_item)
      @items.each_with_index { |item, index| item.id = index + 1 }
      @item_index += 1
      @items_changed = true
      update_selected_item
      puts "INFO: Item has been duplicated. Click 'Save' to persist changes."
    end

    def action_item_new_above
      save_item_state(@undo_stack)
      new_item = @klass.new
      @items.insert(@item_index, new_item)
      @items.each_with_index { |item, index| item.id = index + 1 }
      @items_changed = true
      update_selected_item
      puts "INFO: Item has been added above. Click 'Save' to persist changes."
    end

    def action_item_new_below
      save_item_state(@undo_stack)
      new_item = @klass.new
      @items.insert(@item_index + 1, new_item)
      @items.each_with_index { |item, index| item.id = index + 1 }
      @items_changed = true
      update_selected_item
      puts "INFO: Item has been added below. Click 'Save' to persist changes."
    end

    def action_item_move_up
      return unless @item_index.positive?
      save_item_state(@undo_stack)
      item = @items.delete_at(@item_index)
      @items.insert(@item_index - 1, item)
      @items.each_with_index { |item, index| item.id = index + 1 }
      @item_index -= 1
      @items_changed = true
      update_selected_item
      puts "INFO: Item has been moved up. Click 'Save' to persist changes."
    end

    def action_item_move_down
      return unless @item_index < @items.size - 1
      save_item_state(@undo_stack)
      item = @items.delete_at(@item_index)
      @items.insert(@item_index + 1, item)
      @items.each_with_index { |item, index| item.id = index + 1 }
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
        @items.each_with_index { |item, index| item.id = index + 1 }
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
      @items.each_with_index { |item, index| item.id = index + 1 }
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
      export_path = File.join(export_dir, "#{Editor.name(DATA_CONTROLS[:list_view][:editor][:value_index])}s.json")
      data = @items.map(&:to_h)
      begin
        File.write(export_path, JSON.pretty_generate(data))
        puts "INFO: Items exported to #{export_path} in JSON format."
      rescue StandardError => e
        puts "ERROR: Failed to export JSON to #{export_path}: #{e.message}"
      end
    end

    def action_export_csv
      export_dir = 'Project/Export'
      FileUtils.mkdir_p(export_dir) unless Dir.exist?(export_dir)
      export_path = File.join(export_dir, "#{Editor.name(DATA_CONTROLS[:list_view][:editor][:value_index])}s.csv")
      data = @items.map(&:to_h)
      begin
        CSV.open(export_path, 'wb') do |csv|
          csv << data.first.keys unless data.empty?
          data.each { |item| csv << item.values }
        end
        puts "INFO: Items exported to #{export_path} in CSV format."
      rescue StandardError => e
        puts "ERROR: Failed to export CSV to #{export_path}: #{e.message}"
      end
    end

    def action_sort(attribute)
      save_item_state(@undo_stack)
      @items.sort_by! { |item| item.send(attribute) }
      @items_changed = true
      update_items
      puts "INFO: Items sorted by '#{attribute}'. Click 'Save' to persist changes."
    end

    def action_replace(attribute, old_value, new_value)
      save_item_state(@undo_stack)
      @items.each do |item|
        item.send("#{attribute}=", new_value) if item.send(attribute) == old_value
      end
      @items_changed = true
      update_items
      puts "INFO: Replaced '#{old_value}' with '#{new_value}' in '#{attribute}' across all items."
    end

    def save_item_state(stack)
      stack.push(@items.map(&:dup))
    end

    def update_selected_item
      return if @items.empty?
      @item_index = 0 if @item_index.negative?
      @item_index = @items.size - 1 if @item_index >= @items.size
      @item_scroll_index = @item_index.clamp(0, [@items.size - 20, 0].max)
      @item = @items[@item_index]
    end

    def action_item_copy_value(controls)
      process_item_value(controls) { |key, _properties| Keyboard.clipboard_text = @item[key] }
    end

    def action_item_paste_value(controls)
      process_item_value(controls) do |key, _properties|
        save_item_state(@undo_stack)
        @item[key] = Keyboard.clipboard_text
        @items_changed = true
      end
    end

    def process_item_value(controls)
      %i[text_box value_box].each do |box_type|
        controls[box_type]&.each do |key, properties|
          if properties[:edit_mode]
            yield(key, properties)
            return
          end
        end
      end
    end
  end
end
