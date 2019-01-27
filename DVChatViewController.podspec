Pod::Spec.new do |s|
  s.name                = "DVChatViewController"
  s.version             = "0.0.4"
  s.summary             = "UIViewController for simple chat."
  s.homepage            = 'https://github.com/denis-vashkovski/DVChatViewController'
  s.license             = { :type => 'MIT', :file => 'LICENSE' }
  s.authors             = { 'Denis Vashkovski' => 'denis.vashkovski.vv@gmail.com' }
  s.platform            = :ios, "7.1"
  s.source              = { :git => 'https://github.com/denis-vashkovski/DVChatViewController.git', :tag => s.version.to_s }
  s.ios.source_files    = 'DVChatViewController/*.{h,m}'
  s.requires_arc        = true
end
