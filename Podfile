platform :ios, '15.6'

target 'redredvideo' do
  use_frameworks!

  # 网络请求
  pod 'AFNetworking', '~> 4.0'
  # 图片加载
  pod 'SDWebImage', '~> 5.0'
  # 下拉刷新/上拉加载
  pod 'MJRefresh'
  # 视频边播边缓存
  pod 'KTVHTTPCache', '~> 3.0'
  # OpenSSL（修复 LBLelinkKit 依赖）
  pod 'OpenSSL-Universal', '~> 1.1.1'
  # 自动布局
  pod 'Masonry', '~> 1.1.0'
  # JSON 模型转换（自动处理 NULL）
  pod 'MJExtension'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.6'
    end
  end
  
  # 给主 target 的 xcconfig 追加系统库链接（修复 LBLelinkKit 依赖）
  ['debug', 'release'].each do |config_name|
    xcconfig_path = installer.sandbox.root + "Target Support Files/Pods-redredvideo/Pods-redredvideo.#{config_name}.xcconfig"
    xcconfig_content = File.read(xcconfig_path)
    
    # 追加 MediaPlayer 和 OpenSSL framework
    xcconfig_content.gsub!(/^OTHER_LDFLAGS = (.*)$/, 'OTHER_LDFLAGS = \1 -framework "MediaPlayer" -framework "OpenSSL"')
    
    File.write(xcconfig_path, xcconfig_content)
  end
end
