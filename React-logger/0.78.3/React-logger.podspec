# coding: utf-8
# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

# require "json" - 已替换为硬编码值

# package = JSON.parse(File.read(File.join(__dir__, "..", "..", "package.json"))) - 已替换为硬编码值
version = "0.78.3"

source = { :git => 'https://github.com/nqwlch/React-logger' }
source[:tag] = "v#{version}"


# folly_config = get_folly_config() - 已替换为硬编码值
folly_compiler_flags = "-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -DFOLLY_CFG_NO_COROUTINES=1 -DFOLLY_HAVE_CLOCK_GETTIME=1 -Wno-comma -Wno-shorten-64-to-32"
folly_version = "2024.11.18.00"
# boost_config = get_boost_config() - 已替换为硬编码值
boost_compiler_flags = "-Wno-documentation" 

Pod::Spec.new do |s|
  s.name                   = "React-logger"
  s.version                = version
  s.summary                = "-"  # TODO
  s.homepage               = "https://reactnative.dev/"
  s.license                = "MIT" # package["license"] - 已替换为硬编码值
  s.author                 = "Meta Platforms, Inc. and its affiliates"
  s.platforms              = { :ios => '15.1' } # min_supported_versions - 已替换为硬编码值
  s.source                 = source
  s.source_files           = "*.{cpp,h}"
  s.compiler_flags         = folly_compiler_flags + ' ' + boost_compiler_flags
  s.pod_target_xcconfig    = { "HEADER_SEARCH_PATHS" => "" }
  s.header_dir             = "logger"

  s.dependency "glog"
end
