Gem::Specification.new do |s|
  s.name = 'sms_serial'
  s.version = '0.1.3'
  s.summary = 'Reads SMS messages from a serial connection to an Arduino '+
      'compatible board which uses an SMS module.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/sms_serial.rb']
  s.add_runtime_dependency('c32', '~> 0.2', '>=0.2.0')
  s.add_runtime_dependency('serialport', '~> 1.3', '>=1.3.1')
  s.signing_key = '../privatekeys/sms_serial.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/sms_serial'
end
