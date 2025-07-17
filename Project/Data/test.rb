require '../rpg_vxa'
require '../table'

def load_data(fn)
  data = nil
  File.open(fn, 'rb') do |f|
    data = Marshal.load(f)
  end
  #force_utf8_encode(data)
  data
end

def save_data(obj, fn)
  File.open(fn, 'wb') do |f|
    Marshal.dump(obj, f)
  end
end

test = load_data('Classes.rvdata2')
puts test[1].params[0, 1]