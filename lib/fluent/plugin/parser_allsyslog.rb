require 'fluent/parser'

module Fluent
  class TextParser
    class AllsyslogParser < Parser
      # register as allsyslog parser
      Plugin.register_parser("allsyslog", self)

      # default to using the built in ruby time parser rather than specifying a time format
      config_param :time_format, :string, :default => nil #"%b %d %H:%M:%S"
      config_param :payload_message, :bool, :default => false

      def initialize
        super
        @mutex = Mutex.new
      end

      def configure(conf)
        super
        @payload_message = conf[:payload_message]
        @time_parser = TimeParser.new(@time_format)
      end

      def parse(text)

        if /^\<.*\>\d/.match(text)
          #matched rfc5424 syslog format
          regex = /^\<(?<pri>[0-9]+)\>(1)(?<time>[^ ]* {1,2}[^ ]*) (?<host>[^ ]*) (?<ident>[^ ]*) (?<pid>[^ ]*) (?<msgid>[^ ]*) (-|) *(?<message>.*)$/
        elsif /^\<.*>/.match(text)
          regex = /^\<(?<pri>[0-9]+)\>(?<time>[^ ]* {1,2}[^ ]* [^ ]*) (?<host>[^ ]*) (?<ident>[a-zA-Z0-9_\/\.\-]*)(?:\[(?<pid>[0-9]+)\])?(?:[^\:]*\:)? *(?<message>.*)$/
        else
          regex = /^(?<time>[^ ]*\s*[^ ]* [^ ]*) (?<host>[^ ]*) (?<ident>[a-zA-Z0-9_\/\.\-]*)(?:\[(?<pid>[0-9]+)\])?(?:[^\:]*\:)? *(?<message>.*)$/
        end

        m = regex.match(text)
        unless m
          if block_given?
            yield nil, nil
            return
          else
            return nil, nil
          end
        end

        Regexp.union

        time = nil
        record = {}

        m.names.each { |name|
          if value = m[name]
            case name
              when 'pri'
                record['pri'] = value.to_i
              when 'time'
                time = @mutex.synchronize { @time_parser.parse(value.gsub(/ +/, ' ')) }
              when 'message'
                record['message'] = @payload_message? text : value
              else
                record[name] = value
            end
          end
        }

        if @estimate_current_event
          time ||= Engine.now
        end

        if block_given?
          yield time, record
        else
          return time, record
        end


      end

    end
  end
end
