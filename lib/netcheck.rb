module Netcheck
  class Error < StandardError; end

  class Check
    def run
      0 # Successful run
    end
  end

  class PingParser
    attr_reader :packet_loss_percent, :min, :avg, :max, :stddev

    MIN_ROWS       = 6
    MIN_STATS_ROWS = 2
    NUM_STATS      = 4
    NUM_REGEX      = /(\d{1,3}\.\d{1,3})/
    PKT_LOSS_REGEX = Regexp.compile(NUM_REGEX).freeze
    STATS_REGEX    = Regexp.compile(([NUM_REGEX.source] * 3).join("\/"))

    def initialize(output)
      @output = output
      parse
    end

    private

    def parse
      begin

        # First grab the stats rows like so:
        # 3 packets transmitted, 3 packets received, 0.0% packet loss
        # round-trip min/avg/max/stddev = 14.886/33.055/66.590/23.740 ms

        rows = @output.split("\n")
        stat_rows = rows.last(MIN_STATS_ROWS)
        raise "no stats rows found" if stat_rows.length < MIN_STATS_ROWS

        # Store the packet loss figure
        @packet_loss_percent = stat_rows[0].match(PKT_LOSS_REGEX)[1]

        # Store the min/avg/max/stddev
        numbers = stat_rows.last.match(STATS_REGEX)
        @min    = numbers[1].to_f
        @avg    = numbers[2].to_f
        @max    = numbers[3].to_f
        @stddev = numbers[4].to_f
      rescue => e
        raise "error processing ping response: #{e}"
      end
    end
  end
end
