Pod::Spec.new do |spec|

  spec.name         = "nRFMeshProvision"
  spec.version      = "3.2.0"
  spec.summary      = "A short description of MXMeshProvision."

  spec.description  = "mxchip mesh provision sdk"
  spec.homepage     = "https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library"

  spec.license      = { :type => 'BSD-3-Clause', :file => 'LICENSE' }

  spec.author       = { "laixm" => "laixm@mxchip.com" }

  spec.source       = { :git => "https://rd.mxchip.com/mx/mx_sdk_ios.git", :tag => "#{spec.version}" }
  
  spec.social_media_url = 'https://twitter.com/nordictweets'
  
  spec.ios.deployment_target  = '10.0'

  spec.osx.deployment_target  = '10.15'

  spec.static_framework = true

  spec.swift_versions   = ['4.2', '5.0', '5.1', '5.2', '5.3', '5.4', '5.5']

  spec.source_files  = "nRFMeshProvision/Classes/*"
  
  spec.subspec 'Bearer' do |s|
    s.source_files = 'nRFMeshProvision/Classes/Bearer/*'
    s.subspec 'GATT' do |ss|
      ss.source_files = 'nRFMeshProvision/Classes/Bearer/GATT/**/*.{h,m,swift}'
    end
  end
  spec.subspec 'Crypto' do |s|
    s.source_files = 'nRFMeshProvision/Classes/Crypto/**/*.{h,m,swift}'
  end
  spec.subspec 'Layers' do |s|
    s.source_files = 'nRFMeshProvision/Classes/Layers/*'
    s.subspec 'Access_Layer' do |ss|
      ss.source_files = 'nRFMeshProvision/Classes/Layers/Access Layer/**/*.{h,m,swift}'
    end
    s.subspec 'Foundation_Layer' do |ss|
      ss.source_files = 'nRFMeshProvision/Classes/Layers/Foundation Layer/**/*.{h,m,swift}'
    end
    s.subspec 'Lower_Transport_Layer' do |ss|
      ss.source_files = 'nRFMeshProvision/Classes/Layers/Lower Transport Layer/**/*.{h,m,swift}'
    end
    s.subspec 'Network_Layer' do |ss|
      ss.source_files = 'nRFMeshProvision/Classes/Layers/Network Layer/**/*.{h,m,swift}'
    end
    s.subspec 'Upper_Transport_Layer' do |ss|
      ss.source_files = 'nRFMeshProvision/Classes/Layers/Upper Transport Layer/**/*.{h,m,swift}'
    end
  end
  spec.subspec 'Legacy' do |s|
    s.source_files = 'nRFMeshProvision/Classes/Legacy/**/*.{h,m,swift}'
  end
  spec.subspec 'Mesh_API' do |s|
    s.source_files = 'nRFMeshProvision/Classes/Mesh API/**/*.{h,m,swift}'
  end
  spec.subspec 'Mesh_Model' do |s|
    s.source_files = 'nRFMeshProvision/Classes/Mesh Model/**/*.{h,m,swift}'
  end
  spec.subspec 'Provisioning' do |s|
    s.source_files = 'nRFMeshProvision/Classes/Provisioning/**/*.{h,m,swift}'
  end
  spec.subspec 'Type_Extensions' do |s|
    s.source_files = 'nRFMeshProvision/Classes/Type Extensions/**/*.{h,m,swift}'
  end
  spec.subspec 'Utils' do |s|
    s.source_files = 'nRFMeshProvision/Classes/Utils/**/*.{h,m,swift}'
  end
  spec.subspec 'Mesh_Messages' do |s|
    s.source_files = 'nRFMeshProvision/Classes/Mesh Messages/*'
    s.subspec 'Foundation' do |ss|
      ss.source_files = 'nRFMeshProvision/Classes/Mesh Messages/Foundation/*'
      ss.subspec 'Configuration' do |aa|
        aa.source_files = 'nRFMeshProvision/Classes/Mesh Messages/Foundation/Configuration/**/*.{h,m,swift}'
      end
    end
    s.subspec 'Generic' do |ss|
      ss.source_files = 'nRFMeshProvision/Classes/Mesh Messages/Generic/**/*.{h,m,swift}'
    end
    s.subspec 'Lighting' do |ss|
      ss.source_files = 'nRFMeshProvision/Classes/Mesh Messages/Lighting/**/*.{h,m,swift}'
    end
    s.subspec 'Proxy_Configuration' do |ss|
      ss.source_files = 'nRFMeshProvision/Classes/Mesh Messages/Proxy Configuration/**/*.{h,m,swift}'
    end
    s.subspec 'Sensors' do |ss|
      ss.source_files = 'nRFMeshProvision/Classes/Mesh Messages/Sensors/**/*.{h,m,swift}'
    end
    s.subspec 'Time_and_Scenes' do |ss|
      ss.source_files = 'nRFMeshProvision/Classes/Mesh Messages/Time and Scenes/**/*.{h,m,swift}'
    end
  end
  
  spec.dependency 'CryptoSwift', '= 1.4.0'
  
  spec.frameworks = 'CoreBluetooth'

end
