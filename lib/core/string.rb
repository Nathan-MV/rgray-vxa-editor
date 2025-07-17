# frozen_string_literal: true

module Text
  module_function

  def min3(a, b, c)
    if a < b && a < c
      a
    else
      [b, c].min
    end
  end

  def levenshtein_distance(str1, str2)
    n = str1.length
    m = str2.length
    return m if n.zero?
    return n if m.zero?

    d = (0..m).to_a
    x = nil

    # to avoid duplicating an enumerable object, create it outside of the loop
    str2_codepoints = str2.codepoints

    str1.each_codepoint.with_index(1) do |char1, i|
      j = 0
      while j < m
        char1 == str2_codepoints[j] ? cost = 0 : cost = 1
        x = min3(
          d[j + 1] + 1, # insertion
          i + 1,        # deletion
          d[j] + cost   # substitution
        )
        d[j] = i
        i = x

        j += 1
      end
      d[m] = x
    end

    x
  end

  def snake_to_pascal(snake_str)
    # Split the snake_case string by underscores
    words = snake_str.split('_')

    # Capitalize each word
    capitalized_words = words.map(&:capitalize)

    # Join the words with spaces
    capitalized_words.join(' ')
  end
end
