Pod::Spec.new do |s|
  s.name         = "Dopamine"
  s.version      = "0.1.0"
  s.summary      = "A Swift client for http://usedopamine.com/"

  s.description  = <<-DESC
                    Dopamine eases connection to the Dopamine API
                    which helps you make your user's actions habitual.
                   DESC

  s.homepage     = "http://usedopamine.com/"
  s.license      = { :type => "MIT", :file => "LICENSE.MD" }
  s.author             = { "Ramsay Brown" => "ramsay@usedopamine.com" }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source       = { :git => "https://github.com/DopamineLabs/DopamineAPI_Swift-Client.git", :tag => "v#{s.version}"}
  s.source_files  = "Dopamine/*.swift"

  s.requires_arc = true

  s.dependency "Alamofire", "~> 1.2.3"
  s.dependency "CryptoSwift", "~> 0.0.11"
  s.dependency "SwiftyJSON", "~> 2.2.0"
end
