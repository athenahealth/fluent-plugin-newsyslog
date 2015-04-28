require 'spec_helper'

describe Fluent::TextParser::NewSyslogParser do
  include Fluent

  #subject { TextParser::TEMPLATE_REGISTRY.lookup('newsyslog').call }

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
    expect(subject.parse("<34>Oct 11 22:14:15 mymachine su[10] 'su root' failed for lonvick on /dev/pts/8")).
        to eq([1444616055,
               {'pri'     => 34,
                'host'    => 'mymachine',
                'ident'   => 'su',
                'pid'     => '10',
                'message' => "'su root' failed for lonvick on /dev/pts/8"
               }
              ])
  end

  it 'parses syslog message in rfc5424 format with no STRUCTURED-DATA and time in UTC format' do

    expect(subject.parse('<34>1 2003-10-11T22:14:15.003Z mymachine.example.com'\
                         " su - ID47 - BOM'su root' failed for lonvick on /dev/pts/8")).
        to eq([1065910455,
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
    expect(subject.parse("<165>1 2003-08-24T05:14:15.000003-07:00 192.0.2.1"\
                         " myproc 8710 - - %% It's time to make the do-nuts.")).
               to eq([1061727255,
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
    expect(subject.parse('<165>1 2003-10-11T22:14:15.003Z mymachine.example.com'\
                          ' evntslog - ID47 [exampleSDID@32473 iut="3" eventSource='\
                          '"Application" eventID="1011"] BOMAn application'\
                          ' event log entry...')).
        to eq([1065910455,
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
      expect(subject.parse("Oct 11 22:14:15 mymachine su[10] 'su root' failed for lonvick on /dev/pts/8")).
          to eq([1444616055,
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
      expect(subject.parse("<165>1 2003-08-24T05:14:15.000003-07:00 192.0.2.1"\
                         " myproc 8710 - - %% It's time to make the do-nuts.")).
          to eq([1061727255,
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
