# frozen_string_literal: true

module Editor
  class Class < Data
    CLASS_CONTROLS = {
      group_box: {
        classes: { label: 'Classes', x: 0.085, y: 0.01, width: 0.914, height: 0.98 },
        general: { label: 'General', x: 0.090, y: 0.12 },
        learning: { label: 'Learning', x: 0.27, y: 0.36, width: 0.24, height: 0.62 }
      },
      text_box: {
        name: { label: 'Name', length: 999_999_999, x: 0.15, y: 0.03 }
      },
      value_box: {
        learnings_level: { label: 'Level', label_beside: true, min: 1, max: 999_999_999, x: 0.44, y: 0.94 }
      },
      list_view: {
        learnings: { label: '', x: 0.28, y: 0.38, width: 0.12, height: 0.51 },
        learnings_skill_id: { label: '', x: 0.41, y: 0.38, width: 0.090, height: 0.55 }
      },
      button: {
        learnings_new: { label: 'New', x: 0.28, y: 0.90, width: 0.1 },
        learnings_remove: { label: 'Delete', x: 0.28, y: 0.94, width: 0.1 }
      }
    }

    def initialize
      super
      @features = Features.new(@item)
      @parameter = Parameter.new(@item)
      initialize_properties(CLASS_CONTROLS)
    end

    def update(dt)
      super
      update_group(dt)
      update_group_item
      action_learning_sort if @previous_item != @item
    end

    def draw
      super
      @features.draw
      @parameter.draw
      %i[classes general learning].each { |key| draw_control(:group_box, key) }
      %i[name].each { |key| draw_control(:text_box, key, accessor: @item) }
      draw_control(:list_view, :learnings, special_value: skills_from_learnings)
      if @item.learnings.any?
        draw_control(:list_view, :learnings_skill_id, accessor: @item,
                                                      special_value: ['None'] + $data_skills.compact.map(&:name), index: learnings_list_index)
        draw_control(:value_box, :learnings_level, accessor: @item, index: learnings_list_index)
      end
      if draw_control(:button, :learnings_new)
        action_learning_new
        action_learning_sort
      end
      action_learning_delete if draw_control(:button, :learnings_remove)
    end

    private

    def update_group(dt)
      @features.update(dt)
      @parameter.update(dt)
    end

    def update_group_item
      @features.item = @item
      @parameter.item = @item
    end

    def skills_from_learnings
      @item.learnings.map do |learning|
        skill = $data_skills.compact.find { |skill| skill.id == learning.skill_id }
        skill ? "Lv. #{learning.level} - #{skill.name}" : 'Unknown Skill'
      end
    end

    def learnings_list_index
      CLASS_CONTROLS[:list_view][:learnings][:value_index]
    end

    def action_learning_new
      # save_item_state(@undo_stack)
      new_learning = RPG::Class::Learning.new
      @item.learnings << new_learning
      action_learning_sort
      CLASS_CONTROLS[:list_view][:learnings][:value_index] = @item.learnings.index(new_learning)
      puts "INFO: Effect has been created. Click 'Save' to persist changes."
    end

    def action_learning_delete
      # save_item_state(@undo_stack)
      @item.learnings.delete_at(learnings_list_index)
      CLASS_CONTROLS[:list_view][:learnings][:value_index] = [learnings_list_index - 1, 0].max
      puts "INFO: Effect has been deleted. Click 'Save' to persist changes."
    end

    def action_learning_sort
      @item.learnings.sort_by!(&:level)
    end
  end
end
