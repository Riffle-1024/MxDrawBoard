Pod::Spec.new do |spec|

  spec.name         = "MeshSDK"
  spec.version      = "1.0.0"
  spec.summary      = "A short description of MeshSDK."

  spec.description  = "mxchip mesh sdk"
  spec.homepage     = "https://rd.mxchip.com/mx/mx_sdk_ios"

  spec.license      = ""

  spec.author       = { "laixm" => "laixm@mxchip.com" }

  spec.source       = { :git => "https://rd.mxchip.com/mx/mx_sdk_ios.git", :tag => "#{spec.version}" }
  
  spec.ios.deployment_target  = '10.0'
  
  spec.static_framework = true

  spec.source_files  = "MeshSDK/MeshSDK/*"
  spec.subspec 'Mesh_Network' do |s|
    s.source_files = 'MeshSDK/MeshSDK/Mesh Network/**/*.{h,m,swift}'
  end
  spec.subspec 'Utils' do |s|
    s.source_files = 'MeshSDK/MeshSDK/Utils/**/*.{h,m,swift}'
  end
  
  spec.dependency 'nRFMeshProvision'

end
