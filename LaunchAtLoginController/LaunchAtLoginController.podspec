Pod::Spec.new do |s|
  s.name         = "LaunchAtLoginController"
  s.version      = "1.0.0"
  s.summary      = "A simple controller for Objective-C apps to register for launch at login using LSSharedFileList."
  s.homepage     = "https://github.com/jashephe/LaunchAtLoginController"
  s.license      = 'MIT'
  s.author       = 'Ben Clark-Robinson', 'James Shepherdson'
  s.platform     = :osx
  s.source       = { :git => "https://github.com/jashephe/LaunchAtLoginController.git", :tag => "v1.0.0" }
  s.source_files  = '*.{h,m}'
  s.requires_arc = true
end
