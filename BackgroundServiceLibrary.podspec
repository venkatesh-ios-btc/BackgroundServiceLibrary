Pod::Spec.new do |s|
  s.name         = "BackgroundServiceLibrary"
  s.version      = "1.0.0"
  s.summary      = "A library for running background services in iOS"
  s.description  = "This library enables React Native to run tasks in the background on iOS."
  s.homepage     = "https://github.com/venkatesh-ios-btc/BackgroundServiceLibrary"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Venkatesh" => "your-email@example.com" }
  s.source       = { :git => "https://github.com/venkatesh-ios-btc/BackgroundServiceLibrary.git", :tag => "#{s.version}" }
  s.ios.deployment_target = "12.0"
  s.source_files  = "Sources/**/*.{swift,h,m}"
  s.swift_version = "5.0"
end
