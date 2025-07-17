# encoding: utf-8
# frozen_string_literal: false

module Parser
  # Constants
  FILE_LOADERS = {
    '.rxdata' => :ruby_data,
    '.rvdata2' => :ruby_data,
    '.bin' => :binary,
    '.yml' => :yaml,
    '.csv' => :csv,
    '.json' => :json
  }.freeze

  module_function

  # Get
  def get(filepath)
    loader_method = FILE_LOADERS[File.extname(filepath)]
    Game.debug("Loaded #{filepath}")
    send(loader_method, filepath) if loader_method
  end

  # Ruby Data
  def ruby_data(filename, _raw = false)
    File.open(filename, 'rb') { |file| Marshal.load(file.read) }
  rescue StandardError => e
    Game.error(e)
  end

  # Binary
  def binary(filename)
    Marshal.load(File.binread(filename))
  rescue StandardError => e
    Game.error(e)
  end

  # YAML
  def yaml(filename)
    YAML.unsafe_load(File.read(filename), symbolize_names: true)
  rescue StandardError => e
    Game.error(e)
  end

  # CSV
  def csv(filename)
    CSV.parse(File.read(filename), headers: true, header_converters: :symbol)
  rescue StandardError => e
    Game.error(e)
  end

  # JSON
  def json(filename)
    JSON.load(File.read(filename), symbolize_names: true)
  rescue StandardError => e
    Game.error(e)
  end

  # Symbolize Names
  def symbolize_names(collection)
    if collection.is_a?(Hash)
      collection.transform_keys!(&:to_sym)
      collection.each { |key, value| collection[key] = symbolize_names(value) if value.is_a?(Enumerable) }
    elsif collection.is_a?(Array)
      collection.map! { |value| symbolize_names(value) if value.is_a?(Enumerable) }
    end
    collection
  end
end
