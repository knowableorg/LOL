require 'serialport'
require 'sinatra/base'

port_str       = "/dev/ttyACM0"
baud_rate      = 9600
$serial        = SerialPort.open(port_str, baud_rate)
$current_state = Array.new(14) { Array.new(9) { 0 } }

sleep 2
puts "Serial port ready"

class KnowableLOL < Sinatra::Base
  get '/' do
    erb :index
  end

  post '/submit' do
    map_array = blank_map_array

    params['led'].each do |row, cols|
      cols.each do |col, _|
        map_array[col.to_i][row.to_i] = '#'
      end
    end

    map = map_array.map { |row| row.join('') }.join("\n")
    puts params['led'].inspect
    puts map

    write_map(map)

    redirect to('/')
  end

  private

  def blank_map_array
    Array.new(14) { Array.new(9) { '.' } }
  end

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
          $serial.puts("#{row_index} #{col_index} #{value}")
          sleep 0.05
        end
      end
    end
  end
end
