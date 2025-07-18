# frozen_string_literal: true

#--------------------------------------------------------------------------
# * Editor
#--------------------------------------------------------------------------

module Editor
  @registered = []
  @index = nil

  class << self
    attr_accessor :registered
    attr_accessor :index

    def register(type, klass, rpg, filename)
      registered << { type:, klass:, rpg:, filename:, method: nil }
      puts "Registered new editor: #{name(type)}"
    end

    def select(arg)
      self.index = resolve_index(arg)

      if index
        Scene.unload
        Scene.goto(registered[index][:klass])
        puts "Selecting editor: #{registered[index][:type]}, resolved index: #{index}"
      elsif arg.is_a?(Integer)
        puts "Invalid index: #{arg}"
      end
    end

    def current?(type)

      registered[index][:type] == type
    end

    def inspect
      if registered.empty?
        puts 'No editors registered.'
      else
        registered.each_with_index do |editor, idx|
          puts "Index: #{idx}, Type: #{name(editor[:type])}"
        end
      end
    end

    def list
      registered.map { |editor| name(editor[:type]) }
    end

    def type(arg)
      find_registered(arg)&.dig(:type)
    end

    def klass(arg)
      find_registered(arg)&.dig(:klass)
    end

    def rpg_klass(arg)
      find_registered(arg)&.dig(:rpg)
    end

    def filename(arg)
      find_registered(arg)&.dig(:filename)
    end

    def rpg_method(arg)
      find_registered(arg)&.dig(:method)
    end

    def name(arg)
      case arg
      when Symbol then snake_to_pascal(arg.to_s)
      when Integer then snake_to_pascal(type(arg).to_s)
      end
    end

    private

    def resolve_index(arg)
      case arg
      when Symbol then registered.index { |data| data[:type] == arg }
      when Integer then arg if arg.between?(0, registered.size - 1)
      end
    end

    def find_registered(arg)
      case arg
      when Symbol then registered.find { |data| data[:type] == arg }
      when Integer then registered[arg] if arg.between?(0, registered.size - 1)
      end
    end
  end

  register(:actor, Actor, RPG::Actor, 'Actors.rvdata2')
  register(:classes, Class, RPG::Class, 'Classes.rvdata2')
  register(:skill, Skill, RPG::Skill, 'Skills.rvdata2')
  register(:item, Item, RPG::Item, 'Items.rvdata2')
  register(:weapons, Weapon, RPG::Weapon, 'Weapons.rvdata2')
  register(:armors, Armor, RPG::Armor, 'Armors.rvdata2')
  register(:enemies, Enemy, RPG::Enemy, 'Enemies.rvdata2')
  register(:states, State, RPG::State, 'States.rvdata2')
  register(:common_event, CommonEvent, RPG::CommonEvent, 'CommonEvents.rvdata2')
  # register(:elements, Element, RPG::System, 'System.rvdata2', 'elements.compact')
end
