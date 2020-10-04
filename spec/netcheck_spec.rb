module Netcheck
  RSpec.describe Netcheck do
    it "has a version number" do
      expect(VERSION).not_to be nil
    end

    it "does something useful" do
    end

    describe PingParser do
      let(:non_ping_output) { 'rubbish data' }
      let(:ping_output) do
        <<~HEREDOC
          PING google.ie (209.85.203.94): 56 data bytes
          64 bytes from 209.85.203.94: icmp_seq=0 ttl=106 time=14.886 ms
          64 bytes from 209.85.203.94: icmp_seq=1 ttl=106 time=17.690 ms
          64 bytes from 209.85.203.94: icmp_seq=2 ttl=106 time=66.590 ms

          --- google.ie ping statistics ---
          3 packets transmitted, 3 packets received, 0.0% packet loss
          round-trip min/avg/max/stddev = 14.886/33.055/66.590/23.740 ms
        HEREDOC
      end

      it 'raises an error when parsing non-ping output' do
        expect { PingParser.new(non_ping_output) }.to raise_error(RuntimeError, /error processing ping response/)
      end

      it 'succeeds when parsing ping output' do
        expect(PingParser.new(ping_output)).to be_instance_of PingParser
      end

      describe ('reading stats') do
        let(:parser) {  PingParser.new(ping_output) }

        it 'reads the min value successfully' do
          expect(parser.min).to equal 14.886
        end
        # it 'reads the packet loss percentage successfully' do
        #   expect(parser.packet_loss_percent).to equal 0.0
        # end
        # it 'reads the packet loss percentage successfully' do
        #   expect(parser.packet_loss_percent).to equal 0.0
        # end
      end
    end
  end
end
