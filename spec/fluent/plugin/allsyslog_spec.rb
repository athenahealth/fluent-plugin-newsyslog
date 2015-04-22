require 'spec_helper'

describe Fluent::Plugin::Allsyslog do
  it 'has a version number' do
    expect(Fluent::Plugin::Allsyslog::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
