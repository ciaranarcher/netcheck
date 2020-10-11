require 'csv'
require 'time'

module Netcheck
  class Error < StandardError; end

  class Check
    DOMAIN_REGEX = /\A[a-zA-Z0-9]*\.[a-zA-Z]{2,4}\z/.freeze
    SLEEP_SECONDS = 30

    def run_forever(domain)
      loop do
        puts "Pinging #{domain}..."
        run(domain)
        sleep SLEEP_SECONDS
      end
    end

    def run(domain)

      unless domain =~ DOMAIN_REGEX
        STDERR.puts "#{domain} is not a valid domain"
        return 0
      end

      result = ping(domain)
      write_to_csv(PingParser.new(result), "./output/#{domain}.csv")

      return $?.exitstatus
    end

    def ping(addr)
      return `ping -c 3 #{addr}`
    end

    def write_to_csv(ping, file)
      headers = ['ts', 'success', 'pkt_loss_percent', 'min', 'avg', 'max', 'stddev']

      CSV.open(file, 'a+', {force_quotes: true}) do |csv|
        csv << headers if csv.count.eql? 0

        if ping.success?
          csv << [
            Time.now.utc.iso8601,
            ping.success?,
            ping.packet_loss_percent,
            ping.min,
            ping.avg,
            ping.max,
            ping.stddev
          ]
        else
          csv << [
            Time.now.utc.iso8601,
            ping.success?,
            "-",
            "-",
            "-",
            "-",
            "-"
          ]
        end
      end
    end
  end

  class PingParser
    attr_reader :packet_loss_percent, :min, :avg, :max, :stddev, :err

    MIN_ROWS       = 6
    MIN_STATS_ROWS = 2
    NUM_STATS      = 4
    NUM_REGEX      = /(\d{1,3}\.\d{1,3})/
    PKT_LOSS_REGEX = Regexp.compile(NUM_REGEX).freeze
    STATS_REGEX    = Regexp.compile(([NUM_REGEX.source] * NUM_STATS).join("\/"))

    def initialize(output)
      @output = output
      parse
    end

    def success?; !!@success; end

    private

    def parse
      begin

        # First grab the stats rows like so:
        # 3 packets transmitted, 3 packets received, 0.0% packet loss
        # round-trip min/avg/max/stddev = 14.886/33.055/66.590/23.740 ms

        rows = @output.split("\n")
        stat_rows = rows.last(MIN_STATS_ROWS)
        if stat_rows.length < MIN_STATS_ROWS
          @err = 'no stats rows found'
          @success = false
        end

        # Store the packet loss figure
        @packet_loss_percent = stat_rows[0].match(PKT_LOSS_REGEX)[1].to_f

        # Store the min/avg/max/stddev
        numbers = stat_rows.last.match(STATS_REGEX)
        @min    = numbers[1].to_f
        @avg    = numbers[2].to_f
        @max    = numbers[3].to_f
        @stddev = numbers[4].to_f

        @success = true
      rescue => e
        @err = "error processing ping response: #{e}"
        @success = false
      end
    end
  end
end
