# frozen_string_literal: true

# @!method random
#   Get a random value between min and max (both included)
#   @param min [Integer]
#   @param max [Integer]
#   @return [Integer]

# @!method fib
#   Get a random value between min and max (both included)
#   @param number [Integer]
#   @return [Integer]

def load_data(fn)
  data = nil
  File.open(fn, 'rb') do |f|
    data = Marshal.load(f)
  end
  force_utf8_encode(data)
  data
end

def save_data(obj, fn)
  File.open(fn, 'wb') do |f|
    Marshal.dump(obj, f)
  end
end

def force_utf8_encode(obj)
  case obj
  when Array
    obj.each { |item| force_utf8_encode(item) }
  when Hash
    obj.each_value { |item| force_utf8_encode(item) }
  when String
    obj.force_encoding('utf-8')
  else
    if obj.class.name.start_with?('RPG::')
      obj.instance_variables.each do |name|
        item = obj.instance_variable_get(name)
        force_utf8_encode(item)
      end
    end
  end
end

def snake_to_pascal(snake_str)
  # Split the snake_case string by underscores
  words = snake_str.split('_')

  # Capitalize each word
  capitalized_words = words.map(&:capitalize)

  # Join the words with spaces
  capitalized_words.join(' ')
end
