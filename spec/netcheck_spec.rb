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

      describe 'failure' do
        let(:failed_ping) { PingParser.new(non_ping_output) }

        it 'is marked as unsuccessful' do
          expect(failed_ping.success?).to be false
        end

        it 'has an error set' do
          expect(failed_ping.err).to match(/error processing ping response/)
        end
      end

      describe 'success' do
        let(:ping) {  PingParser.new(ping_output) }

        it 'is marked as successful' do
          expect(ping.success?).to be true
        end

        it 'has no error set' do
          expect(ping.err).to be nil
        end

        describe ('reading stats') do
          it 'reads the min value successfully' do
            expect(ping.min).to eq(14.886)
          end

          it 'reads the avg value successfully' do
            expect(ping.avg).to eq(33.055)
          end

          it 'reads the max value successfully' do
            expect(ping.max).to eq(66.590)
          end

          it 'reads the stddev value successfully' do
            expect(ping.stddev).to eq(23.740)
          end

          it 'reads the packet loss percentage successfully' do
            expect(ping.packet_loss_percent).to eq(0.0)
          end
        end
      end
    end
  end
end
