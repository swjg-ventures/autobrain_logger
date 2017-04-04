require 'test_helper'

class AutobrainLoggerTest < Minitest::Test
#  def test_that_it_has_a_version_number
#    refute_nil ::AutobrainLogger::VERSION
#  end

#  def test_it_does_something_useful
#    assert false
#  end
   def setup
     Log.debug("test_debug", "test_tag")
     Log.info("test_info", "test_tag")
     Log.warn("test_warn", "test_tag")
     Log.error("test_error", "test_tag")
     Log.fatal("test_fatal", "test_tag")
   end

  def test_logs
    path_to_file = "#{Rails.root}/log/logstash_#{Rails.env}.log"
    result = true
    first_line_number = 6
    if File.exist?(path_to_file)
       IO.readlines(path_to_file)[-5..-1].each do |log_line|
         line = JSON.parse(log_line)
         result &= line['message'] == "test_#{line['level']}"
         result &= line['tags'].last == "test_tag"
         result &= line['caller_file'] == "log_test.rb"
         result &= line['caller_line'] == first_line_number.to_s
         first_line_number += 1
       end
     else
       result = false
    end
    assert result
  end

end
