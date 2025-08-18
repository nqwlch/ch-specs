# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

version = "0.78.3"

Pod::Spec.new do |spec|
  spec.name        = "hermes-engine"
  spec.version     = version
  spec.summary     = "Hermes is a small and lightweight JavaScript engine optimized for running React Native."
  spec.description = "Hermes is a JavaScript engine optimized for fast start-up of React Native apps. It features ahead-of-time static optimization and compact bytecode."
  spec.homepage    = "https://hermesengine.dev"
  spec.license     = "MIT"
  spec.author      = "Facebook"
  spec.source      = { 
    :http => "https://repo1.maven.org/maven2/com/facebook/react/react-native-artifacts/0.78.3/react-native-artifacts-0.78.3-hermes-ios-debug.tar.gz",
    :sha256 => "b01aa16ee0b007c6ebbda68b2bf4bfb460e51ad0028a3cee2972cd22a00b3c00"
  }
  spec.platforms   = { :osx => "10.13", :ios => "15.1", :visionos => "1.0", :tvos => "15.1" }

  spec.preserve_paths      = '**/*.*'
  spec.source_files        = ''

  spec.pod_target_xcconfig = {
                    "CLANG_CXX_LANGUAGE_STANDARD" => "c++20",
                    "CLANG_CXX_LIBRARY" => "compiler-default",
                    "GCC_WARN_INHIBIT_ALL_WARNINGS" => "YES" # Disable warnings because we don't control this library
                  }

  spec.ios.vendored_frameworks = "destroot/Library/Frameworks/ios/hermes.framework"
  spec.tvos.vendored_frameworks = "destroot/Library/Frameworks/tvos/hermes.framework"
  spec.osx.vendored_frameworks = "destroot/Library/Frameworks/macosx/hermes.framework"
  spec.visionos.vendored_frameworks = "destroot/Library/Frameworks/xros/hermes.framework"


  spec.subspec 'Pre-built' do |ss|
    ss.preserve_paths = ["destroot/bin/*"].concat(["**/*.{h,c,cpp}"])
    ss.source_files = "destroot/include/hermes/**/*.h"
    ss.header_mappings_dir = "destroot/include"
    ss.ios.vendored_frameworks = "destroot/Library/Frameworks/universal/hermes.xcframework"
    ss.visionos.vendored_frameworks = "destroot/Library/Frameworks/universal/hermes.xcframework"
    ss.tvos.vendored_frameworks = "destroot/Library/Frameworks/universal/hermes.xcframework"
    ss.osx.vendored_frameworks = "destroot/Library/Frameworks/macosx/hermes.framework"
  end
  spec.script_phase = {
    :name => "[Hermes] Replace Hermes for the right configuration, if needed",
    :execution_position => :before_compile,
    :script => <<-EOS
    . "$REACT_NATIVE_PATH/scripts/xcode/with-environment.sh"

    CONFIG="Release"
    if echo $GCC_PREPROCESSOR_DEFINITIONS | grep -q "DEBUG=1"; then
      CONFIG="Debug"
    fi

    "$NODE_BINARY" "$REACT_NATIVE_PATH/sdks/hermes-engine/utils/replace_hermes_version.js" -c "$CONFIG" -r "#{version}" -p "$PODS_ROOT"
    EOS
  }
end
