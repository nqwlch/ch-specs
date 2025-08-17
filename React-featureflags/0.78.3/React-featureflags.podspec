# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

# require "json" - 已替换为硬编码值

# package = JSON.parse(File.read(File.join(__dir__, "..", "..", "..", "package.json"))) - 已替换为硬编码值
version = "0.78.3"

source = { :git => 'https://github.com/nqwlch/React-featureflags.git' }
if version == '1000.0.0'
  # This is an unpublished version, use the latest commit hash of the react-native repo, which we're presumably in.
  source[:commit] = `git rev-parse HEAD`.strip if system("git rev-parse --git-dir > /dev/null 2>&1")
else
  source[:tag] = "v#{version}"
end

# folly_config = get_folly_config() - 已替换为硬编码值
folly_compiler_flags = "-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -DFOLLY_CFG_NO_COROUTINES=1 -DFOLLY_HAVE_CLOCK_GETTIME=1 -Wno-comma -Wno-shorten-64-to-32"
folly_version = "2024.11.18.00"

Pod::Spec.new do |s|
  s.name                   = "React-featureflags"
  s.version                = version
  s.summary                = "React Native internal feature flags"
  s.homepage               = "https://reactnative.dev/"
  s.license                = "MIT" # package["license"] - 已替换为硬编码值
  s.author                 = "Meta Platforms, Inc. and affiliates"
  s.platforms              = { :ios => '15.1' } # min_supported_versions - 已替换为硬编码值
  s.source                 = source
  
  # 明确指定所有源文件
  s.source_files           = "**/*.{cpp,h}"
  s.header_dir             = "ReactFeatureflags"
  s.compiler_flags         = folly_compiler_flags

  s.pod_target_xcconfig    = { 
    "CLANG_CXX_LANGUAGE_STANDARD" => "c++20", # rct_cxx_language_standard() - 已替换为硬编码值
    "DEFINES_MODULE" => "YES"
  }
  s.libraries = "stdc++"

  s.dependency "RCT-Folly", folly_version

  # Framework 支持配置
  if ENV['USE_FRAMEWORKS']
    s.module_name            = "ReactFeatureflags"
    s.header_mappings_dir  = "ReactFeatureflags"
  end
end
