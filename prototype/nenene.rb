require './machine'
require 'yaml'


@m = Machine.new
@m.start

def read_dict
  @akitaben = YAML.load(File.read("akitaben.yml"))
end
read_dict

# --- color support
def color?
  case @m.state
  when Drum::STATE_RUNNING
    :red
  when Drum::STATE_STOPPED
    :green
  else
    :red
  end
end

def bgcolor?
  return nil
end

def blink?
  case @m.state
  when Drum::STATE_ABOUT_TO_STOP
    true
  else
    false
  end
end

def esc_code color, bgcolor, blink
  ec = ""
  colors = [:black, :red, :green, :yellow, :blue, :magenta, :cyan, :white]
  cc = colors.index(color)
  ec += "\e[3#{cc}m" if cc
  bc = colors.index(bgcolor)
  ec += "\e[4#{bc}m" if bc
  ec += "\e[5m" if blink
  ec
end

def esc_reset
  "\e[0m"
end



# --- run the machine

def display
  print("\e[2J")

  puts " #{@m.next_pattern} "
  puts  esc_code(color?, bgcolor?, blink?) + 
        "[#{@m.pattern}]" +
        esc_reset
  puts " #{@m.prev_pattern} "

  description
end

def description
  if @m.state == Drum::STATE_STOPPED
    s = @m.pattern
    d = @akitaben[s]
    c = d ? :blue : :red

    puts
    puts  esc_code(c, nil, nil) + 
          (d ? "#{s}: #{@akitaben[s]}" : "ハズレ") + 
          esc_reset
  else
    puts; puts
  end
end

loop do
  display
  @m.update
  @m.wait

  if @m.state == Drum::STATE_STOPPED
    display
    sleep 5.0
    @m.start
  end
end
