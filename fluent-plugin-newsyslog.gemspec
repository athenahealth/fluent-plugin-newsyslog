# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-newsyslog"
  spec.version       = "0.1.2"
  spec.authors       = ["Kevin Scheunemann"]
  spec.email         = ["kscheunemann@athenahealth.com"]

  spec.summary       = %q{A better fluentd syslog input and parser plugin}
  spec.description   = %q{A fluent plugin that includes a syslog parser that handles both rfc3164 and rfc5424 formats }
  spec.homepage      = "https://github.com/athenahealth/fluent-plugin-newsyslog"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'fluentd', '>= 0.10.59'
  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'flexmock'
  spec.add_development_dependency 'simplecov', '~> 0.6.4'
  spec.add_development_dependency 'rr', '>= 1.0.0'
  spec.add_development_dependency 'timecop', '>= 0.3.0'
  spec.add_development_dependency 'test-unit', '~> 3.0.2'
  spec.add_development_dependency 'test-unit-rr', '~> 1.0.3'

end
