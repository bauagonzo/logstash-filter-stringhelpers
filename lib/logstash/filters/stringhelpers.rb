# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"

#TODO String.include self doesn't work with the jruby version used by logstash
class String
  def volume_to_bytes
    # TODO too permissive regex 4T or 3YTES works
    value, unit = self.scan(/^(\d+\.?\d*)\s*(M|G|T)?B?(ytes)?\s*$/i).first
    size = value.to_f
    case unit
    when /M/i
      size * 1000
    when /G/i
      size * 1000 * 1000
    when /T/i
      size * 1000 * 1000 * 1000
    else
      size
    end
  end

  def to_seconds
    ['d',86400,'h',3600,'m',60,'s',1].each_slice(2).with_object(self.clone).map do |(u,v),s|
      s.sub!(/^(\d+)#{u}\s*/,'') ? v*$1.to_i : 0
    end.inject(0,:+)
  end

end
# This stringhelper filter helps to replace string by specific values
#
class LogStash::Filters::StringHelpers < LogStash::Filters::Base

  config_name "stringhelpers"

  # Convert a string that represents a volume into a float.
  # Convert a string that represents a duration into an int.
  #
  # Example:
  # [source,ruby]
  #     filter {
  #       stringhelpers {
  #         human_readable_volume_to_bytes => [ "fieldname" ]
  #         human_readable_duration_to_int => [ "fieldname" ]
  #       }
  #     }
  config :human_readable_volume_to_bytes, :validate => :array

  config :human_readable_duration_to_int, :validate => :array

  public
  def register
    # Add instance variables
  end # def register

  public
  def filter(event)
    volume_to_bytes(event) if @human_readable_volume_to_bytes
    duration_to_int(event) if @human_readable_duration_to_int

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end

  def volume_to_bytes(event)
    @human_readable_volume_to_bytes.each do |field|
      original = event[field]
      result = case original
               when Array
                 original.map(&:volume_to_bytes)
               when String
                 original.volume_to_bytes
               end
      event[field] = result
    end
  end

  def duration_to_int(event)
    @human_readable_duration_to_int.each do |field|
      original = event[field]
      result = case original
               when Array
                 original.map(&:to_seconds)
               when String
                 original.to_seconds
               end
      event[field] = result
    end
  end
end
