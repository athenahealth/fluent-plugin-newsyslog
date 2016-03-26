require 'spec_helper'

describe Fluent::TextParser::NewSyslogParser do

  subject { Fluent::Test::ParserTestDriver.new(Fluent::TextParser::NewSyslogParser) }

  before(:each) { subject.configure('with_priority' => true) }

  it { should respond_to(:parse)}
  it { should respond_to(:configure)}

  it 'returns [nil, nil] with no matches' do
    expect(subject.parse('')).to eq([nil, nil])
  end

  it 'returns [nil, nil] with incorrectly formatted syslog message' do
    expect(subject.parse('<>This should not match')).to eq([nil, nil])
  end

  it 'parses syslog message with priority' do
    time = 'Oct 11 22:14:15'
    timestamp = Time.parse(time).to_i
    expect(subject.parse("<34>#{time} mymachine su[10] 'su root' failed for lonvick on /dev/pts/8")).
        to eq([timestamp,
               {'pri'     => 34,
                'host'    => 'mymachine',
                'ident'   => 'su',
                'pid'     => '10',
                'message' => "'su root' failed for lonvick on /dev/pts/8"
               }
              ])
  end

  it 'parses syslog message in rfc5424 format with no STRUCTURED-DATA and time in UTC format' do
    time = '2003-10-11T22:14:15.003Z'
    timestamp = Time.parse(time).to_i
    expect(subject.parse("<34>1 #{time} mymachine.example.com"\
                         " su - ID47 - BOM'su root' failed for lonvick on /dev/pts/8")).
        to eq([timestamp,
              {'pri'     => 34,
               'host'    => 'mymachine.example.com',
               'ident'   => 'su',
               'pid'     => '-',
               'msgid'   => 'ID47',
               'message' => "BOM'su root' failed for lonvick on /dev/pts/8"
              }
              ])
  end

  it 'parses syslog message in rfc5424 format with no STRUCTURED-DATA and time in offset format' do
    time = '2003-08-24T05:14:15.000003-07:00'
    timestamp = Time.parse(time).to_i
    expect(subject.parse("<165>1 #{time} 192.0.2.1"\
                         " myproc 8710 - - %% It's time to make the do-nuts.")).
               to eq([timestamp,
                     {'pri'     => 165,
                      'host'    => '192.0.2.1',
                      'ident'   => 'myproc',
                      'pid'     => '8710',
                      'msgid'   => '-',
                      'message' => "%% It's time to make the do-nuts."
                     }
                     ])
  end

  it 'parses syslog message in rfc5424 format with STRUCTURED-DATA and time in offset format' do
    time = '2003-10-11T22:14:15.003Z'
    timestamp = Time.parse(time).to_i
    expect(subject.parse("<165>1 #{time} mymachine.example.com"\
                          ' evntslog - ID47 [exampleSDID@32473 iut="3" eventSource='\
                          '"Application" eventID="1011"] BOMAn application'\
                          ' event log entry...')).
        to eq([timestamp,
              {'pri'      => 165,
               'host'     => 'mymachine.example.com',
               'ident'    => 'evntslog',
               'pid'      => '-',
               'msgid'    => 'ID47',
               'message'  => '[exampleSDID@32473 iut="3" eventSource="Application" eventID="1011"] BOMAn application event log entry...'
              }
              ])
  end

  context 'when with_priorty set to false' do

    before(:each) { subject.configure('with_priority' => false) }

    it 'parses syslog message without priority' do
      time = 'Oct 11 22:14:15'
      timestamp = Time.parse(time).to_i
      expect(subject.parse("#{time} mymachine su[10] 'su root' failed for lonvick on /dev/pts/8")).
          to eq([timestamp,
                 {'host'    => 'mymachine',
                  'ident'   => 'su',
                  'pid'     => '10',
                  'message' => "'su root' failed for lonvick on /dev/pts/8"
                 }
                ])
    end
  end

  context 'when payload_message set to true' do

    before(:each) { subject.configure('with_priority' => true, 'payload_message' => true) }

    it 'parses syslog message in rfc5424 format with no STRUCTURED-DATA and time in offset format' do
      time = '2003-08-24T05:14:15.000003-07:00'
      timestamp = Time.parse(time).to_i
      expect(subject.parse("<165>1 #{time} 192.0.2.1"\
                         " myproc 8710 - - %% It's time to make the do-nuts.")).
          to eq([timestamp,
                 {'pri'     => 165,
                  'host'    => '192.0.2.1',
                  'ident'   => 'myproc',
                  'pid'     => '8710',
                  'msgid'   => '-',
                  'message' => "<165>1 2003-08-24T05:14:15.000003-07:00 192.0.2.1 myproc 8710 - - %% It's time to make the do-nuts."
                 }
                ])
    end

  end

end
