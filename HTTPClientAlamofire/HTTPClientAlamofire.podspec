Pod::Spec.new do |s|
  s.name                   = 'HTTPClientAlamofire'
  s.module_name            = 'HTTPClientAlamofire'
  s.version                = '1.0'
  s.summary                = 'HTTPClientAlamofire'
  s.homepage               = 'https://github.com/vkaltyrin'
  s.license                = 'MIT'
  s.author                 = { 'Vladimir Kaltyrin' => 'vkasci@gmail.com' }
  s.source                 = { :path => './' }
  s.platform               = :ios, '9.0'
  s.ios.deployment_target = '9.0'
  s.requires_arc = true
  s.source_files = '**/*.{swift,h,m}'
  s.dependency 'Alamofire'
  s.dependency 'HTTPClient'
end
