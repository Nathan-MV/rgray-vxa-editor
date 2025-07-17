# frozen_string_literal: true

module Editor
  class CommonEvent < Data
    COMMON_EVENT_CONTROLS = {
      group_box: {
        common_event: { label: 'Common Events', x: 0.085, y: 0.01, width: 0.914, height: 0.98 },
        general: { label: 'General', x: 0.09, y: 0.03, width: 0.71, height: 0.07 },
        commands: { label: 'Commands', x: 0.090, y: 0.12, height: 0.86 },
        contents: { label: 'Contents', x: 0.27, y: 0.12, width: 0.53, height: 0.86 }
      },
      text_box: {
        name: { label: 'Name', length: 999_999_999, x: 0.15, y: 0.05 },
      },
      list_view: {
        list: { label: '', x: 0.28, y: 0.14, width: 0.51, height: 0.83 }
      },
      dropdown_box: {
        trigger: { label: 'Trigger', text: 'None;Autorun;Parallel Process', x: 0.32, y: 0.05 },
        switch_id: { label: 'Switch', text: "None;" + $data_system.switches.compact.join(';'), x: 0.49, y: 0.05 }
      }
    }

    CODE = {
      101 => 'Text Properties:',
      102 => 'Show Choices:',
      401 => 'Text: ',
      402 => '  When',
      404 => 'Branch End'
    }.freeze

    TEXT_PARAMETER_2 = %w[Normal Dark Transparent].freeze
    TEXT_PARAMETER_3 = %w[Top Middle Bottom].freeze

    def initialize
      super
      initialize_properties(COMMON_EVENT_CONTROLS)
      @display = []
    end

    def update(dt)
      super
      @display = @item.list.map { |list| format_event(list) }
    end

    def draw
      super
      [:common_event, :general, :commands, :contents].each { |key| draw_control(:group_box, key) }
      [:name].each { |key| draw_control(:text_box, key, accessor: @item) }
      draw_control(:list_view, :list, special_value: @display)
      if draw_control(:dropdown_box, :trigger, accessor: @item) >= 1
        draw_control(:dropdown_box, :switch_id, accessor: @item)
      end
    end

    def format_event(list)
      case list.code
      when 101 then "#{CODE[list.code]} #{list.parameters[0]}, #{list.parameters[1]}, #{TEXT_PARAMETER_2[list.parameters[2]]}, #{TEXT_PARAMETER_3[list.parameters[3]]}"
      when 102 then "#{CODE[list.code]} #{list.parameters[0][0]}, #{list.parameters[0][1]}"
      when 401 then "#{CODE[list.code]} #{list.parameters[0]}"
      when 402 then "#{CODE[list.code]} [#{list.parameters[1]}]"
      else
        CODE[list.code] || ""
      end
    end

    def current_code
      return if @item.list.empty? || @item.list[list_index].nil?

      @item.list[list_index].code
    end

    def list_index
      COMMON_EVENT_CONTROLS[:list_view][:list][:value_index]
    end

    def action_event_new
      #save_item_state(@undo_stack)
      @item.list << RPG::EventCommand.new(CODE.keys[COMMON_EVENT_CONTROLS[:list_view][:list][:value_index]], 0, [])
      puts "INFO: Event has been created. Click 'Save' to persist changes."
    end

    def action_event_delete
      #save_item_state(@undo_stack)
      @item.list.delete_at(list_index)
      puts "INFO: Event has been deleted. Click 'Save' to persist changes."
    end
  end
end
