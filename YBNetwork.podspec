

Pod::Spec.new do |s|


  s.name         = "YBNetwork"
  s.version      = "1.0"
  s.summary      = "基于 AFNetworking 网络中间层，注重性能，设计简洁，易于拓展"
  s.description  = <<-DESC
  					基于 AFNetworking 网络中间层，注重性能，设计简洁，易于拓展。
                   DESC

  s.homepage     = "https://github.com/indulgeIn"

  s.license      = "MIT"

  s.author       = { "杨波" => "1106355439@qq.com" }
 
  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/indulgeIn/YBNetwork.git", :tag => "#{s.version}" }

  s.source_files  = "YBNetwork/**/*.{h,m}"

  s.dependency 'AFNetworking'
  s.dependency 'YYCache', '~>1.0.4'

  s.requires_arc = true

end
