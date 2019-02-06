Pod::Spec.new do |s|
  s.name                   = 'HTTPClient'
  s.module_name            = 'HTTPClient'
  s.version                = '1.0'
  s.summary                = 'HTTPClient'
  s.homepage               = 'http://domclick.ru'
  s.license                = 'CNS'
  s.author                 = { 'Vladimir Kaltyrin' => 'vkasci@gmail.com' }
  s.source                 = { :path => './HTTPClient' }
  s.platform               = :ios, '9.0'
  s.ios.deployment_target = '9.0'
  s.requires_arc = true
  s.source_files = '**/*.{swift,h,m}'
end
