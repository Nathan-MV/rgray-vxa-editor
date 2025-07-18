# frozen_string_literal: true

module Editor
  class Data < Base
    DATA_CONTROLS = {
      group_box: {
        commands: { label: 'Commands', x: 0.812, y: 0.03, width: 0.183, height: 0.95 }
      },
      button: {
        quantity: { label: 'Quantity', action: false, x: 0.910, y: 0.94 },
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
      DATA_CONTROLS[:list_view][:editor][:value_index] != @previous_editor_index.tap do |changed|
        @previous_editor_index = DATA_CONTROLS[:list_view][:editor][:value_index] if changed
      end
    end

    def draw
      super
      Gui.group_box(DATA_CONTROLS[:group_box][:commands][:label], DATA_CONTROLS[:group_box][:commands][:rect])
      draw_list_view(:editor, Editor.list)
      # draw_control(:list_view,
      # :editor,
      # special_value: Editor.list)
      result_search, @search_query = Gui.text_box(@search_query, DATA_CONTROLS[:text_box][:search][:rect],
                                                  DATA_CONTROLS[:text_box][:search][:length], @edit_modes[:search])
      @edit_modes[:search] = !@edit_modes[:search] if result_search
      @item_scroll_index, @item_index = Gui.list_view(@item_names, DATA_CONTROLS[:list_view][:item][:rect],
                                                      @item_scroll_index, @item_index)
      @autosave = Gui.check_box(DATA_CONTROLS[:check_box][:autosave][:label],
                                DATA_CONTROLS[:check_box][:autosave][:rect], @autosave)
      # @autosave = draw_control(:check_box, :autosave)
      DATA_CONTROLS[:button].each do |symbol, properties|
        send(:"action_item_#{symbol}") if Gui.button(properties[:label], properties[:rect]) && properties[:action].nil?
      end
      result_quantity, @quantity = Gui.value_box('', DATA_CONTROLS[:value_box][:quantity][:rect], @quantity,
                                                 DATA_CONTROLS[:value_box][:quantity][:min], DATA_CONTROLS[:value_box][:quantity][:max], @edit_modes[:quantity])
      @edit_modes[:quantity] = !@edit_modes[:quantity] if result_quantity
    end

    def draw_list_view(key, text, _accessor = nil)
      DATA_CONTROLS[:list_view][key][:scroll_index], DATA_CONTROLS[:list_view][key][:value_index] = Gui.list_view(
        text, DATA_CONTROLS[:list_view][key][:rect], DATA_CONTROLS[:list_view][key][:scroll_index], DATA_CONTROLS[:list_view][key][:value_index]
      )
    rescue StandardError => e
      puts "ERROR: Failed to draw list view for key '#{key}': #{e.message}"
    end

    def unload
      action_item_save if @autosave
    end

    def initialize_items
      @file_path = File.join("Project/Data/#{Editor.filename(DATA_CONTROLS[:list_view][:editor][:value_index])}")
      @klass = Editor.rpg_klass(DATA_CONTROLS[:list_view][:editor][:value_index])
      @items = load_items.compact
      @item_names = @items.map do |item|
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
      @item = @items.first
      @item_scroll_index = 0
      @item_index = 0
    end

    def safe_attribute(obj, attribute, default, force = false)
      obj.send("#{attribute}=", default) if force || obj.send(attribute).nil?
    end

    def load_items
      if File.exist?(@file_path) && File.size(@file_path).positive?
        load_data(@file_path)
      else
        puts 'INFO: File does not exist or is empty. Initializing with default template.'
        save_data(@klass.new, @file_path)
        load_items_from_file
      end
    end

    def update_items
      @item_names = @items.map do |item|
        "#{item.id} - #{item.name}"
      end
      @item = @items[@item_index]
      DATA_CONTROLS[:button][:quantity][:label] = "Quantity - #{@items.length}"
    end

    def update_keyboard
      if Mouse.button_down?(Mouse::BUTTON_LEFT)
        action_item_undo if Input.released?(:special)
        # action_item_redo if Input.released?(:y)
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
        @search_query.clear
      end
      @item_index = action_item_search(@search_query.downcase) || 0
      @item_scroll_index = @item_index.clamp(0, [@items.size - 20, 0].max)
      @item = @items[@item_index]
    end

    def action_item_search(query)
      @items.each_with_index do |item, index|
        return index if partial_match(query, item.name.downcase)
      end
      false
    end

    def partial_match(query, item_name, threshold = 0.7)
      return true if item_name.include?(query)

      @levenshtein_cache ||= {}
      cache_key = [query, item_name].sort.join('-')
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
      @item = @items[@item_index]
      puts "INFO: Item has been duplicated. Click 'Save' to persist changes."
    end

    def action_item_new_above
      save_item_state(@undo_stack)
      new_item = @klass.new
      @items.insert(@item_index, new_item)
      @items.each_with_index { |item, index| item.id = index + 1 }
      update_selected_item
      puts "INFO: Item has been added above. Click 'Save' to persist changes."
    end

    def action_item_new_below
      save_item_state(@undo_stack)
      new_item = @klass.new
      @items.insert(@item_index + 1, new_item)
      @items.each_with_index { |item, index| item.id = index + 1 }
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
      update_selected_item
      puts "INFO: Item has been moved down. Click 'Save' to persist changes."
    end

    def action_item_undo
      return if @undo_stack.empty?

      save_item_state(@redo_stack)
      @items = @undo_stack.pop
      update_selected_item
      puts 'INFO: Undo operation performed.'
    end

    def action_item_redo
      return if @redo_stack.empty?

      save_item_state(@undo_stack)
      @items = @redo_stack.pop
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
      @item = @items[@item_index]
      puts "INFO: Item has been deleted. Click 'Save' to persist changes."
    end

    def action_item_delete_blank
      save_item_state(@undo_stack)
      @items.reject! { |item| item.name.to_s.strip.empty? }
      @items = [@klass.new] if @items.empty?
      @items.each_with_index { |item, index| item.id = index + 1 }
      @item_index = [@item_index, @items.size - 1].min
      @item_index -= 1 while @item_index.positive? && @items[@item_index].name.to_s.strip.empty?
      @item = @items[@item_index]
      puts "INFO: Items identical to the template have been deleted. Click 'Save' to persist changes."
    end

    def action_item_reset
      save_item_state(@undo_stack)
      @items = load_items
      @item_index = 0
      @item = @items[@item_index]
      puts 'INFO: Items have been reset to the original state.'
    end

    def action_export_json
      export_path ||= "Project/Export/#{Editor.name(DATA_CONTROLS[:list_view][:editor][:value_index])}s.json"
      data = @items.map(&:to_h)
      File.write(export_path, JSON.pretty_generate(data))
      puts "INFO: Items exported to #{export_path} in JSON format."
    end

    def action_export_csv
      export_path ||= "Project/Export/#{Editor.name(DATA_CONTROLS[:list_view][:editor][:value_index])}s.csv"
      data = @items.map(&:to_h)
      CSV.open(export_path, 'wb') do |csv|
        csv << data.first.keys
        data.each { |item| csv << item.values }
      end
      puts "INFO: Items exported to #{export_path} in CSV format."
    end

    # Sort items by a specified attribute
    def action_sort(attribute)
      save_item_state(@undo_stack)
      @items.sort_by! { |item| item.send(attribute) }
      update_items
      puts "INFO: Items sorted by '#{attribute}'. Click 'Save' to persist changes."
    end

    # Replace an old value with a new value across all items
    def action_replace(attribute, old_value, new_value)
      save_item_state(@undo_stack)
      @items.each do |item|
        item.send("#{attribute}=", new_value) if item.send(attribute) == old_value
      end
      update_items
      puts "INFO: Replaced '#{old_value}' with '#{new_value}' in '#{attribute}' across all items."
    end

    def save_item_state(stack)
      stack.push(@items.map(&:dup))
    end

    def update_selected_item
      if @item_index.negative?
        @item_index = @items.size - 1
      elsif @item_index >= @items.size
        @item_index = 0
      end
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
