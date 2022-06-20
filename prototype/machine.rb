class Drum
  
  STATE_STOPPED = "stoped"
  STATE_RUNNING = "running"
  STATE_STOPPING = "stopping"
  STATE_ABOUT_TO_STOP = "about to stop"
  
  attr_reader :state
  attr_reader :speed

  def initialize patterns, prev_drum = nil
    @patterns = patterns
    @ptn_idx = 0
    @prev_drum = prev_drum
    @state = STATE_STOPPED
    @stop_idx = nil
  end

  def pattern
    @patterns[@ptn_idx]
  end

  def next_pattern
    c = @patterns.size
    i = (@ptn_idx + 1) % c
    @patterns[i]
  end

  def prev_pattern
    c = @patterns.size
    i = (@ptn_idx - 1 + c) % c
    @patterns[i]
  end

  def increment
    c = @patterns.size
    @ptn_idx = (@ptn_idx + 1) % c
  end

  def start
    @state = STATE_RUNNING
    @speed = @patterns.size
    @stop_idx = nil
    @count = @patterns.size - 1
  end

  def stop
    if @state == STATE_RUNNING
      @state = STATE_STOPPING
    end
  end

  def update
    case @state
    when STATE_STOPPED
      return
    when STATE_RUNNING
      if @prev_drum&.state == STATE_STOPPED
        stop
      end
    end

    @count -= @speed
    if @count < 0
      @ptn_idx = (@ptn_idx + 1) % @patterns.size
      @count += @patterns.size

      case @state
      when STATE_STOPPING
        if @speed == 1
          @state = STATE_ABOUT_TO_STOP
        else
          @speed -= 1
        end
      when STATE_ABOUT_TO_STOP
        @stop_idx ||= rand(@patterns.size)
        if @stop_idx == @ptn_idx
          @state = STATE_STOPPED
        end
      end
    end
  end

end

class Machine

  def initialize
    patterns = [
      ["ね"] * 6, #["ね", "　"] * 3,
      ["ね", "る", "れ"] * 2, #["ね"] * 6, #["ね", "　"] * 3,
      ["ね", "が", "ど", "ば", "よ", "　"],
    ]
    prev = nil
    @drums = 3.times.map{|i| d = Drum.new(patterns[i], prev); prev = d; d }
    @interval = 0.8 / patterns.first.size
  end

  def pattern
    @drums.map{|d| d.pattern}.join("")
  end

  def next_pattern
    @drums.map{|d| d.next_pattern}.join("")
  end

  def prev_pattern
    @drums.map{|d| d.prev_pattern}.join("")
  end

  def increment
    @drums.each{|d| d.increment}
  end

  def start
    @time = 3.0
    @drums.each{|d| d.start}
  end

  def stop
    @drums.first.stop
  end

  def stopped?
    @drums.find{|d| d.stopped?}
  end

  def update
    @drums.each{|d| d.update }
  end

  def wait
    sleep @interval
    if @time > 0
      @time -= @interval
    else
      stop
    end
  end

  def state
    case @drums[0].state
    when Drum::STATE_RUNNING
      Drum::STATE_RUNNING
    when Drum::STATE_STOPPED
      case @drums[1].state
      when Drum::STATE_STOPPED
        @drums[2].state
      when Drum::STATE_ABOUT_TO_STOP
        Drum::STATE_ABOUT_TO_STOP
      else
        Drum::STATE_STOPPING
      end
    else
      Drum::STATE_STOPPING
    end
  end

  def state_string
    @drums.map{|d| d.state + ":" + d.speed.to_s}.join(" | ")
  end

end
