# frozen_string_literal: true

# Input-related functions: keyboard
module Keyboard
  # Mapping of symbolic key names to their corresponding key codes for keyboard inputs.
  # @note The key codes for keyboard inputs (e.g., `J`, `INSERT`) are constants defined by Raylib.
  # @example Replace the mapping for the start button
  #   Keyboard::MAPPING[:start] = [Keyboard::J, Keyboard::INSERT]
  MAPPING = {
    # Start and select buttons
    start: [J, INSERT],
    select: [H, PAUSE],
    home: [SEMICOLON, HOME],

    # Action buttons
    confirm: [C, SPACE, ENTER],
    cancel: [X, BACKSPACE, ESCAPE],
    menu: [V, MENU, KP_3],
    special: [B, KP_1, RIGHT_SHIFT],

    # Triggers and bumpers
    left_trigger: [F, ONE, KP_7],
    right_trigger: [G, THREE, KP_9],
    left_bumper: [R],
    right_bumper: [T],

    # Joystick buttons
    left_stick: [FOUR, Y],
    right_stick: [FIVE, U],

    # Directional buttons
    up: [UP, W, KP_8],
    down: [DOWN, S, KP_2],
    left: [LEFT, A, KP_4],
    right: [RIGHT, D, KP_6],

    f1: [F1],
    f2: [F2],
    f3: [F3],
    f4: [F4],
    f5: [F5],
    f6: [F6],
    f7: [F7],
    f8: [F8],
    f9: [F9],
    f10: [F10],
    f11: [F11],
    f12: [F12],

    ctrl: [LEFT_CONTROL, RIGHT_CONTROL]
  }

  # @!parse NULL = 0
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse APOSTROPHE = 39
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse COMMA = 44
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse MINUS = 45
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse PERIOD = 46
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse SLASH = 47
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse ZERO = 48
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse ONE = 49
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse TWO = 50
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse THREE = 51
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse FOUR = 52
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse FIVE = 53
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse SIX = 54
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse SEVEN = 55
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse EIGHT = 56
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse NINE = 57
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse SEMICOLON = 59
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse EQUAL = 61
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse A = 65
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse B = 66
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse C = 67
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse D = 68
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse E = 69
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse F = 70
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse G = 71
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse H = 72
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse I = 73
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse J = 74
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse K = 75
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse L = 76
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse M = 77
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse N = 78
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse O = 79
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse P = 80
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse Q = 81
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse R = 82
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse S = 83
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse T = 84
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse U = 85
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse V = 86
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse X = 87
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse Y = 88
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse Z = 89
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse LEFT_BRACKET = 91
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse BACKSLASH = 92
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse RIGHT_BRACKET = 93
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse GRAVE = 96
  #   Alphanumeric keys
  #   return [Integer]

  # @!parse SPACE = 32
  #   Function keys
  #   return [Integer]

  # @!parse ESCAPE = 256
  #   Function keys
  #   return [Integer]

  # @!parse ENTER = 257
  #   Function keys
  #   return [Integer]

  # @!parse TAB = 258
  #   Function keys
  #   return [Integer]

  # @!parse BACKSPACE = 259
  #   Function keys
  #   return [Integer]

  # @!parse INSERT = 260
  #   Function keys
  #   return [Integer]

  # @!parse DELETE = 261
  #   Function keys
  #   return [Integer]

  # @!parse RIGHT = 262
  #   Function keys
  #   return [Integer]

  # @!parse LEFT = 263
  #   Function keys
  #   return [Integer]

  # @!parse DOWN = 264
  #   Function keys
  #   return [Integer]

  # @!parse UP = 265
  #   Function keys
  #   return [Integer]

  # @!parse PAGE_UP = 266
  #   Function keys
  #   return [Integer]

  # @!parse PAGE_DOWN = 267
  #   Function keys
  #   return [Integer]

  # @!parse HOME = 268
  #   Function keys
  #   return [Integer]

  # @!parse END = 269
  #   Function keys
  #   return [Integer]

  # @!parse CAPS_LOCK = 280
  #   Function keys
  #   return [Integer]

  # @!parse SCROLL_LOCK = 281
  #   Function keys
  #   return [Integer]

  # @!parse NUM_LOCK = 282
  #   Function keys
  #   return [Integer]

  # @!parse PRINT_SCREEN = 283
  #   Function keys
  #   return [Integer]

  # @!parse PAUSE = 284
  #   Function keys
  #   return [Integer]

  # @!parse F1 = 290
  #   Function keys
  #   return [Integer]

  # @!parse F2 = 291
  #   Function keys
  #   return [Integer]

  # @!parse F3 = 292
  #   Function keys
  #   return [Integer]

  # @!parse F4 = 293
  #   Function keys
  #   return [Integer]

  # @!parse F5 = 294
  #   Function keys
  #   return [Integer]

  # @!parse F6 = 295
  #   Function keys
  #   return [Integer]

  # @!parse F7 = 296
  #   Function keys
  #   return [Integer]

  # @!parse F8 = 297
  #   Function keys
  #   return [Integer]

  # @!parse F9 = 298
  #   Function keys
  #   return [Integer]

  # @!parse F10 = 299
  #   Function keys
  #   return [Integer]

  # @!parse F11 = 300
  #   Function keys
  #   return [Integer]

  # @!parse F12 = 301
  #   Function keys
  #   return [Integer]

  # @!parse LEFT_SHIFT = 340
  #   Function keys
  #   return [Integer]

  # @!parse LEFT_CONTROL = 341
  #   Function keys
  #   return [Integer]

  # @!parse LEFT_ALT = 342
  #   Function keys
  #   return [Integer]

  # @!parse LEFT_SUPER = 343
  #   Function keys
  #   return [Integer]

  # @!parse RIGHT_SHIFT = 344
  #   Function keys
  #   return [Integer]

  # @!parse RIGHT_CONTROL = 345
  #   Function keys
  #   return [Integer]

  # @!parse RIGHT_ALT = 346
  #   Function keys
  #   return [Integer]

  # @!parse RIGHT_SUPER = 347
  #   Function keys
  #   return [Integer]

  # @!parse KB_MENU = 348
  #   Function keys
  #   return [Integer]

  # @!parse KP_0 = 320
  #   Keypad keys
  #   return [Integer]

  # @!parse KP_1 = 321
  #   Keypad keys
  #   return [Integer]

  # @!parse KP_2 = 322
  #   Keypad keys
  #   return [Integer]

  # @!parse KP_3 = 323
  #   Keypad keys
  #   return [Integer]

  # @!parse KP_4 = 324
  #   Keypad keys
  #   return [Integer]

  # @!parse KP_5 = 325
  #   Keypad keys
  #   return [Integer]

  # @!parse KP_6 = 326
  #   Keypad keys
  #   return [Integer]

  # @!parse KP_7 = 327
  #   Keypad keys
  #   return [Integer]

  # @!parse KP_8 = 328
  #   Keypad keys
  #   return [Integer]

  # @!parse KP_9 = 329
  #   Keypad keys
  #   return [Integer]

  # @!parse KP_DECIMAL = 330
  #   Keypad keys
  #   return [Integer]

  # @!parse KP_DIVIDE = 331
  #   Keypad keys
  #   return [Integer]

  # @!parse KP_MULTIPLY = 332
  #   Keypad keys
  #   return [Integer]

  # @!parse KP_SUBTRACT = 333
  #   Keypad keys
  #   return [Integer]

  # @!parse KP_ADD = 334
  #   Keypad keys
  #   return [Integer]

  # @!parse KP_ENTER = 335
  #   Keypad keys
  #   return [Integer]

  # @!parse KP_EQUAL = 336
  #   Keypad keys
  #   return [Integer]

  # @!parse BACK = 4
  #   Android key buttons
  #   return [Integer]

  # @!parse MENU = 5
  #   Android key buttons
  #   return [Integer]

  # @!parse VOLUME_UP = 24
  #   Android key buttons
  #   return [Integer]

  # @!parse VOLUME_DOWN = 25
  #   Android key buttons
  #   return [Integer]

  # @!method pressed?
  #   Check if a key has been pressed once
  #   @param key [Integer]
  #   @return [Boolean]

  # @!method repeat?
  #   Check if a key has been pressed again (Only PLATFORM_DESKTOP)
  #   @param key [Integer]
  #   @return [Boolean]

  # @!method down?
  #   Check if a key is being pressed
  #   @param key [Integer]
  #   @return [Boolean]

  # @!method released?
  #   Check if a key has been released once
  #   @param key [Integer]
  #   @return [Boolean]

  # @!method up?
  #   Check if a key is NOT being pressed
  #   @param key [Integer]
  #   @return [Boolean]

  # @!method pressed
  #   Get key pressed (keycode), call it multiple times for keys queued, returns 0 when the queue is empty
  #   @return [Integer]

  # @!method char_pressed
  #   Get char pressed (unicode), call it multiple times for chars queued, returns 0 when the queue is empty
  #   @return [Integer]
end
