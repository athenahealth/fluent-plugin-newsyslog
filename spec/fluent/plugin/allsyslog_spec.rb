require 'spec_helper'

describe Fluent::TextParser::AllsyslogParser do

  before(:each) { subject.configure(Hash.new) }

  it { should respond_to(:parse)}
  it { should respond_to(:configure)}

  it 'returns [nil, nil] with no matches' do
    expect(subject.parse('')).to eq([nil, nil])
  end

  it 'parses syslog message with priority' do
    expect(subject.parse("<34>Oct 11 22:14:15 mymachine su[10] 'su root' failed for lonvick on /dev/pts/8")).to eq('blah')
  end

end
