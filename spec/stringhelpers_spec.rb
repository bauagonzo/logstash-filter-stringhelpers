# encoding: utf-8

require "logstash/devutils/rspec/spec_helper"
require "logstash/filters/stringhelpers"

describe LogStash::Filters::StringHelpers do
  describe "Convert string with bytes to volume in float" do
    let(:config) do <<-CONFIG
      filter {
        stringhelpers {
          human_readable_volume_to_bytes => "array"
        }
      }
    CONFIG
    end


    sample("array" => ["tot", "3", "3.3", "33B", "33 M", "301.80M", "33gb","33gbytes", "33 TB", "3.3 tb"]) do
      insist { subject['array'] } ==  [0.0, 3.0, 3.3, 33.0, 33000.0, 301800.0, 33000000.0, 33000000.0, 33000000000.0, 3300000000.0]
    end
    sample("array" => "33B") do
      insist { subject['array'] } == 33.0
    end
  end
  describe "Convert duration to int" do
    let(:config) do <<-CONFIG
      filter {
        stringhelpers {
          human_readable_duration_to_int => "array"
        }
      }
    CONFIG
    end


    sample("array" => ["toto", "18m", "18m 20s", "4h 18m", "5d 3m"]) do
      insist { subject['array'] } ==  [0, 1080, 1100, 15480, 432180]
    end
    sample("array" => "18m") do
      insist { subject['array'] } == 1080
    end
  end
end
