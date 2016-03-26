require_relative '../helper'
require 'fluent/test'
require 'fluent/plugin/parser_newsyslog'

module ParserTest
  include Fluent

  def str2time(str_time, format = nil)
    if format
      Time.strptime(str_time, format).to_i
    else
      Time.parse(str_time).to_i
    end
  end

  class SyslogParserTest < ::Test::Unit::TestCase
    include ParserTest

    def setup
      @parser = create_driver
      @expected = {
          'host'    => '192.168.0.1',
          'ident'   => 'fluentd',
          'pid'     => '11111',
          'message' => '[error] Syslog test'
      }
    end

    def create_driver(conf={})
      Fluent::Test::ParserTestDriver.new(Fluent::TextParser::NewSyslogParser)
    end

    def configure(conf)
      @parser.configure({}.merge(conf))
    end


    def test_parse
      configure({})
      @parser.parse('Feb 28 12:00:00 192.168.0.1 fluentd[11111]: [error] Syslog test') { |time, record|
        assert_equal(str2time('Feb 28 12:00:00', '%b %d %H:%M:%S'), time)
        assert_equal(@expected, record)
      }
    end

    def test_parse_with_time_format
      configure('time_format' => '%b %d %M:%S:%H')
      @parser.parse('Feb 28 00:00:12 192.168.0.1 fluentd[11111]: [error] Syslog test') { |time, record|
        assert_equal(str2time('Feb 28 12:00:00', '%b %d %H:%M:%S'), time)
        assert_equal(@expected, record)
      }
    end

    def test_parse_with_priority
      configure('with_priority' => true)
      @parser.parse('<6>Feb 28 12:00:00 192.168.0.1 fluentd[11111]: [error] Syslog test') { |time, record|
        assert_equal(str2time('Feb 28 12:00:00', '%b %d %H:%M:%S'), time)
        assert_equal(@expected.merge('pri' => 6), record)
      }
    end

    def test_parse_payload_message
      configure('with_priority' => true, 'payload_message' => true)
      @parser.parse('<6>Feb 28 12:00:00 192.168.0.1 fluentd[11111]: [error] Syslog test') { |time, record|
        assert_equal(str2time('Feb 28 12:00:00', '%b %d %H:%M:%S'), time)
        assert_equal({ 'host'    => '192.168.0.1',
                       'ident'   => 'fluentd',
                       'message' => '<6>Feb 28 12:00:00 192.168.0.1 fluentd[11111]: [error] Syslog test',
                       'pid'     => '11111'}.merge('pri' => 6), record)
      }
    end

    def test_parse_without_colon
      configure({})
      @parser.parse('Feb 28 12:00:00 192.168.0.1 fluentd[11111] [error] Syslog test') { |time, record|
        assert_equal(str2time('Feb 28 12:00:00', '%b %d %H:%M:%S'), time)
        assert_equal(@expected, record)
      }
    end
  end
end
