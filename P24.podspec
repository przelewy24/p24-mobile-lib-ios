Pod::Spec.new do |s|  
    s.name              = 'P24'
    s.version           = '3.5.47'
    s.summary           = 'Przelewy24 mobile SDK for iOS'
    s.homepage          = 'https://github.com/przelewy24/p24-mobile-lib-doc/blob/master/README_pl.md'

    s.author            = { 'Przelewy24' => 'serwis@przelewy24.pl' }
    s.license           = { :type => 'Apache License Version 2.0', :text => <<-LICENSE
                            Apache License Version 2.0
                            LICENSE
                          }

    s.platform          = :ios
    s.source            = { :git => 'https://github.com/przelewy24/p24-mobile-lib-ios.git', :tag => s.version.to_s }

    s.ios.deployment_target = '12.0'
    s.ios.vendored_frameworks = 'P24.xcframework'
end