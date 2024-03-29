Pod::Spec.new do |spec|
  spec.name         = 'MIAHydrogenKit'
  spec.version = '1.0.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/7factory/MIA-HydrogenKit'
  spec.authors      = { 'CMPS' => 'cmps@sevenventures.de' }
  spec.summary      = 'Swift networking framework.'
  spec.source       = { :git => 'https://github.com/7factory/mia-HydrogenKit.git', :tag => spec.version.to_s }
  spec.ios.deployment_target = '8.0'
  spec.watchos.deployment_target = '2.0'
  spec.tvos.deployment_target = '9.0'
  spec.source_files = 'HydrogenKit/*.swift'
end
