# frozen_string_literal: true

def load_normal_database
  $data_actors        = load_data('Project/Data/Actors.rvdata2')
  $data_classes       = load_data('Project/Data/Classes.rvdata2')
  $data_skills        = load_data('Project/Data/Skills.rvdata2')
  $data_items         = load_data('Project/Data/Items.rvdata2')
  $data_weapons       = load_data('Project/Data/Weapons.rvdata2')
  $data_armors        = load_data('Project/Data/Armors.rvdata2')
  $data_enemies       = load_data('Project/Data/Enemies.rvdata2')
  $data_troops        = load_data('Project/Data/Troops.rvdata2')
  $data_states        = load_data('Project/Data/States.rvdata2')
  $data_animations    = load_data('Project/Data/Animations.rvdata2')
  # $data_tilesets      = load_data("Project/Data/Tilesets.rvdata2")
  $data_common_events = load_data('Project/Data/CommonEvents.rvdata2')
  $data_system        = load_data('Project/Data/System.rvdata2')
  # $data_mapinfos      = load_data("Project/Data/MapInfos.rvdata2")
end
GAME_PATH = './'
module Game
  ROOT_SCRIPTS_DIR = File.join(__dir__, 'lib')
  CORE_SCRIPTS_DIR = File.join(ROOT_SCRIPTS_DIR, 'core')
  DEV_SCRIPTS_DIR  = File.join(ROOT_SCRIPTS_DIR, 'dev')

  @warned_errors = {}

  class << self
    def run
      @loader = Zeitwerk::Loader.new
      @loader.push_dir(ROOT_SCRIPTS_DIR)
      @loader.collapse("#{ROOT_SCRIPTS_DIR}/editor/group")
      @loader.setup
      Graphics.setup
      Editor.select(:item)

      until Graphics.should_close?
        safely('Update') do
          Scene.update(Graphics.frame_time)
        end
        Graphics.update

        Graphics.begin do
          Graphics.clear(Color.new(255, 255, 255))
          safely('Draw') do
            Scene.draw
          end
          Graphics.draw
        end
      end

      shutdown
    rescue StandardError => e
      error('Game Loop', e)
    end

    def safely(stage)
      yield
    rescue StandardError => e
      key = "#{stage}:#{e.class}:#{e.message}"
      return if @warned_errors.key?(key)

      @warned_errors[key] = true
      warning(stage, e)
    end

    def shutdown
      log :info, 'Shutting down gracefully...'
      Scene.unload
      Graphics.close
      log :info, 'Shutdown complete.'
    end

    def warning(stage, e)
      log :warn, "#{stage} failed: #{e.class} - #{e.message}", e
    end

    def error(context, e)
      log :error, "#{context}: #{e.class} - #{e.message}", e
      raise
    end

    private

    def log(level, message, exception = nil)
      timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
      puts "[#{timestamp}] #{level.to_s.upcase}: #{message}"
      return unless exception

      puts exception.backtrace.map { |line| "    #{line}" }.join("\n")
    end
  end
end

# Entry point of the application
begin
  # Ensure that output is flushed immediately to the terminal (no buffering)
  # FIXME: This is a workaround for RGRay Windows attached console output issues
  $stdout.sync = true

  # Replace the default load path with specific directories
  $LOAD_PATH.clear
  $LOAD_PATH.push(
    "#{Game::DEV_SCRIPTS_DIR}/stdlib",
    "#{Game::DEV_SCRIPTS_DIR}/stdlib/x64-mingw-ucrt",
    "#{Game::DEV_SCRIPTS_DIR}/gems",
    Game::CORE_SCRIPTS_DIR.to_s
  )

  # Load ruby gems for development
  %w[zeitwerk].each { |file| require file }

  # Load RGRay core
  %w[gamepad gestures graphics keyboard mouse touch input color string kernel rgss].each { |file| require file }

  # Load game settings
  %w[settings].each { |file| require_relative file }

  load_normal_database

  # Run the main game application
  Game.run
end
