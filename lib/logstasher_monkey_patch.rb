require 'logstasher'

module LogStasher
  extend self

  SEVERITY_COLOR_MAP = {'debug'=>'32', 'info'=>'36', 'warn'=>'33', 'error'=>'31', 'fatal'=>'41'} #debug=green, info=blue, warn=yellow, error=red, fatal=red background

  def new_logger(path)
    if path.is_a? String
      FileUtils.touch path # prevent autocreate messages in log
      Logger.new path
    elsif path.is_a? Array
      log_file, logs_files_to_keep, log_files_max_size, * = path
      FileUtils.touch log_file # prevent autocreate messages in log
      Logger.new(log_file, logs_files_to_keep, log_files_max_size)
    end
  end

  def log(severity, message, additional_fields={})

    if logger && logger.send("#{severity}?")

      data = {'level' => severity}
      if message.respond_to?(:to_hash)
        data.merge!(message.to_hash)
      else
        data['message'] = message
      end

      # tags get special handling
      tags = Array(additional_fields.delete(:tags) || 'log')

      data.merge!(additional_fields)
      logstash_event =  (build_logstash_event(data, tags).to_json)
      if (defined? (Settings) == "constant") && (Settings.colored_logs)
        color = SEVERITY_COLOR_MAP[severity]
        logger << "\e[#{color}m#{logstash_event} + \n\e[0m"
      else
        logger << logstash_event + "\n"
      end
    end
  end
end
