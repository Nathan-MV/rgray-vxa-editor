# frozen_string_literal: true

module Zeitwerk
  module Registry
    class Autoloads # :nodoc:
      # : () -> void
      def initialize
        @autoloads = {} # : Hash[String, Zeitwerk::Loader]
      end

      # : (String, Zeitwerk::Loader) -> Zeitwerk::Loader
      def register(abspath, loader)
        @autoloads[abspath] = loader
      end

      # : (String) -> Zeitwerk::Loader?
      def registered?(path)
        @autoloads[path]
      end

      # : (String) -> Zeitwerk::Loader?
      def unregister(abspath)
        @autoloads.delete(abspath)
      end

      # : (Zeitwerk::Loader) -> void
      def unregister_loader(loader)
        @autoloads.delete_if { _2 == loader }
      end

      # : () -> bool
      # for tests
      def empty?
        @autoloads.empty?
      end

      # : () -> void
      # for tests
      def clear
        @autoloads.clear
      end
    end
  end
end
