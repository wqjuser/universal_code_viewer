Pod::Spec.new do |s|
  s.name             = 'universal_code_viewer'
  s.version          = '1.0.3+1'
  s.summary          = 'A universal code viewer plugin for macOS.'
  s.description      = 'This plugin provides code viewing capabilities for macOS.'
  s.homepage         = 'https://example.com'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Your Name' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.platform         = :osx, '10.15'
  s.source_files     = 'Classes/**/*'
end
