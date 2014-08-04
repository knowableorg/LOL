require 'serialport'
require 'sinatra/base'

port_str       = "/dev/ttyACM0"
baud_rate      = 9600
$serial        = SerialPort.open(port_str, baud_rate)
$current_state = Array.new(15) { Array.new(9) { 0 } }

sleep 2
puts "Serial port ready"

class KnowableLOL < Sinatra::Base
  get '/' do
    erb :index
  end

  get '/left' do
    map = File.read('data/left')
    write_map(map)
    "<pre>#{map}</pre>"
  end

  get '/right' do
    map = File.read('data/right')
    write_map(map)
    "<pre>#{map}</pre>"
  end

  private

  def write_map(map)
    map.split("\n").each_with_index do |row, row_index|
      row.split(//).each_with_index do |character, col_index|
        case character
        when '.'
          value = 0
        when '#'
          value = 1
        end

        if value != $current_state[col_index][row_index]
          $current_state[col_index][row_index] = value
          $serial.puts("#{col_index} #{row_index} #{value}")
          sleep 0.05
        end
      end
    end
  end
end
