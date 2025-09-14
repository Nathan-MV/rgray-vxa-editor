# frozen_string_literal: true

#--------------------------------------------------------------------------
# * Editor
#--------------------------------------------------------------------------

# Editor module manages registration and selection of editor types.
module Editor
  # @return [Array<Hash>] List of registered editors
  @registered = []
  @index = nil

  class << self
    # @return [Array<Hash>] List of registered editors
    attr_reader :registered
    # @return [Integer, nil] Current selected editor index
    attr_reader :index

    # Register a new editor type
    # @param type [Symbol] Editor type symbol
    # @param klass [Class] Editor class
    # @param rpg [Class] RPG data class
    # @param filename [String] Data filename
    # @return [void]
    def register(type, klass, rpg, filename)
      @registered << { type: type, klass: klass, rpg: rpg, filename: filename, method: nil }
      puts "Registered new editor: #{name(type)}"
    end

    # Select an editor by type or index
    # @param arg [Symbol, Integer]
    # @return [void]
    def select(arg)
      idx = resolve_index(arg)
      if idx
        @index = idx
        Scene.unload
        Scene.goto(@registered[@index][:klass])
        puts "Selecting editor: #{registered[@index][:type]}, resolved index: #{@index}"
      elsif arg.is_a?(Integer)
        puts "Invalid index: #{arg}"
      end
    end

    # Check if current editor matches type
    # @param type [Symbol]
    # @return [Boolean]
    def current?(type)
      return false unless @index && @registered[@index]
      @registered[@index][:type] == type
    end

    # Print all registered editors
    # @return [void]
    def inspect
      if @registered.empty?
        puts 'No editors registered.'
      else
        @registered.each_with_index do |editor, idx|
          puts "Index: #{idx}, Type: #{name(editor[:type])}"
        end
      end
    end

    # List all editor names
    # @return [Array<String>]
    def list
      @registered.map { |editor| name(editor[:type]) }
    end

    # Get type for arg
    # @param arg [Symbol, Integer]
    # @return [Symbol, nil]
    def type(arg)
      find_registered(arg)&.dig(:type)
    end

    # Get klass for arg
    # @param arg [Symbol, Integer]
    # @return [Class, nil]
    def klass(arg)
      find_registered(arg)&.dig(:klass)
    end

    # Get RPG klass for arg
    # @param arg [Symbol, Integer]
    # @return [Class, nil]
    def rpg_klass(arg)
      find_registered(arg)&.dig(:rpg)
    end

    # Get filename for arg
    # @param arg [Symbol, Integer]
    # @return [String, nil]
    def filename(arg)
      find_registered(arg)&.dig(:filename)
    end

    # Get RPG method for arg
    # @param arg [Symbol, Integer]
    # @return [Object, nil]
    def rpg_method(arg)
      find_registered(arg)&.dig(:method)
    end

    # Get display name for type or index
    # @param arg [Symbol, Integer]
    # @return [String, nil]
    def name(arg)
      case arg
      when Symbol then snake_to_pascal(arg.to_s)
      when Integer then snake_to_pascal(type(arg).to_s)
      end
    end

    private

    # Resolve index from type or index
    # @param arg [Symbol, Integer]
    # @return [Integer, nil]
    def resolve_index(arg)
      case arg
      when Symbol then @registered.index { |data| data[:type] == arg }
      when Integer then arg if arg.between?(0, @registered.size - 1)
      end
    end

    # Find registered editor by type or index
    # @param arg [Symbol, Integer]
    # @return [Hash, nil]
    def find_registered(arg)
      case arg
      when Symbol then @registered.find { |data| data[:type] == arg }
      when Integer then @registered[arg] if arg.between?(0, @registered.size - 1)
      end
    end
  end

  # Register all editor types
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
