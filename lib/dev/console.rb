# encoding: utf-8
# frozen_string_literal: false

module Console
  class << self
    def update
      print_prompt unless @shown
      handle_command($stdin.gets.chomp) if $stdin.ready?
    end

    def print_prompt
      print('INPUT: ')
      @shown = true
    end

    def handle_command(command)
      case command
      when 'help' then Game.debug('Available commands: eval, help, exit')
      when 'exit' then exit
      else
        evaluate_command(command)
      end

      @shown = false
    end

    def evaluate_command(command)
      eval(command)
    rescue StandardError => e
      Game.error(e)
    end
  end
end
