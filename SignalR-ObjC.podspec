Pod::Spec.new do |s|
  s.name         = "SignalR-ObjC"
  s.version      = "2.0.0.alpha1"
  s.summary      = "Objective-C Client for the SignalR Project works with iOS and Mac."
  s.homepage     = "https://github.com/yesnoyes/SignalR-ObjC"
  s.license      = 'MIT'
  s.author       = { "Jenis" => "shahid.iqbal1090@gmail.com" }
  s.source   	 = { :git => 'https://github.com/yesnoyes/SignalR-ObjC.git', :tag => '2.0.0.alpha1' }
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.8'
  s.source_files = 'SignalR.Client/**/*.{h,m}'
  s.requires_arc = true
  s.dependency 'AFNetworking', '~>2.0'
  s.dependency 'SocketRocket', '0.3.1-beta2'
end