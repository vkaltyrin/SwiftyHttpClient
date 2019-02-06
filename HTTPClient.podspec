Pod::Spec.new do |s|
  s.name                   = 'HTTPClient'
  s.module_name            = 'HTTPClient'
  s.version                = '1.0'
  s.summary                = 'HTTPClient'
  s.homepage               = 'https://github.com/vkaltyrin/SwiftyHttpClient'
  s.license                = 'MIT'
  s.author                 = { 'Vladimir Kaltyrin' => 'vkasci@gmail.com' }
  s.source                 = { :path => './' }
  s.platform               = :ios, '9.0'
  s.ios.deployment_target = '9.0'
  s.requires_arc = true
  s.source_files = 'HTTPClient/HTTPClient/Sources/**/*.{swift,h,m}'
end