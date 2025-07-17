# frozen_string_literal: true

module Zeitwerk
  module Registry
    class Loaders # :nodoc:
      # : () -> void
      def initialize
        @loaders = [] # : Array[Zeitwerk::Loader]
      end

      # : ({ (Zeitwerk::Loader) -> void }) -> void
      def each(&)
        @loaders.each(&)
      end

      # : (Zeitwerk::Loader) -> void
      def register(loader)
        @loaders << loader
      end

      # : (Zeitwerk::Loader) -> Zeitwerk::Loader?
      def unregister(loader)
        @loaders.delete(loader)
      end

      # : (Zeitwerk::Loader) -> bool
      # for tests
      def registered?(loader)
        @loaders.include?(loader)
      end

      # : () -> void
      # for tests
      def clear
        @loaders.clear
      end
    end
  end
end
