require "autobrain_logger/version"
require "active_support"
require 'active_support/core_ext'
#require "logstasher"
require "logstasher_monkey_patch.rb"

module Log

  APP_TAGS = ["json", Rails.env]

  def self.debug(msg, log_tags = [])
    LogStasher.log("debug", msg, caller_file: self.get_caller_file_name, caller_line: self.get_caller_line_number, tags: self.append_to_tags(log_tags))
    insert_activity(msg)
  end

  def self.info(msg, log_tags = [])
    LogStasher.log("info", msg, caller_file: self.get_caller_file_name, caller_line: self.get_caller_line_number, tags:  self.append_to_tags(log_tags))
    insert_activity(msg)
  end

  def self.warn(msg, log_tags = [])
    LogStasher.log("warn", msg, caller_file: self.get_caller_file_name, caller_line: self.get_caller_line_number, tags:  self.append_to_tags(log_tags))
    insert_activity(msg)
  end

  def self.error(msg, log_tags = [])
    LogStasher.log("error", msg, caller_file: self.get_caller_file_name, caller_line: self.get_caller_line_number, tags:  self.append_to_tags(log_tags))
    insert_activity(msg)
  end

  def self.fatal(msg, log_tags = [])
    LogStasher.log("fatal", msg, caller_file: self.get_caller_file_name, caller_line: self.get_caller_line_number, tags:  self.append_to_tags(log_tags))
    insert_activity(msg)
  end

  def self.payload(msg, log_tags = [])
    LogStasher.log("debug", msg, caller_file: self.get_caller_file_name, caller_line: self.get_caller_line_number, tags:  self.append_to_tags(log_tags))
    insert_activity(msg, true)
  end

  private

  def self.get_caller_file_name
    caller[1].match(/([a-zA-Z0-9_.]*):\d+:in/).captures[0] # The sender file and line exist on stack 1
  end

  def self.get_caller_line_number
    caller[1].match(/[a-zA-Z0-9_.]*:(\d+):in/).captures[0] # The sender file and line exist on stack 1
  end

  def self.append_to_tags(tags_to_add)
    if tags_to_add.blank?
      APP_TAGS
    else
      if tags_to_add.is_a? Array
        APP_TAGS + tags_to_add
      else
        APP_TAGS + [tags_to_add]
      end
    end
  end

  def self.insert_activity(message, payload = false)
    if (defined? (Settings) == "constant") && (Settings.log_to_db)
      Activity.create! data: message ? message : yield, payload: payload
    else
      message.length
    end
  end

end

