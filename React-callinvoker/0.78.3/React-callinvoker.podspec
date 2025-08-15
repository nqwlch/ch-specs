# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

# require "json" - 已替换为硬编码值

# package = JSON.parse(File.read(File.join(__dir__, "..", "..", "package.json"))) - 已替换为硬编码值
version = "0.78.3"

source = { :git => 'https://github.com/nqwlch/React-callinvoker' }
source[:tag] = "v#{version}"

Pod::Spec.new do |s|
  s.name                   = "React-callinvoker"
  s.version                = version
  s.summary                = "-"  # TODO
  s.homepage               = "https://reactnative.dev/"
  s.license                = "MIT" # package["license"] - 已替换为硬编码值
  s.author                 = "Meta Platforms, Inc. and its affiliates"
  s.platforms              = { :ios => '15.1' } # min_supported_versions - 已替换为硬编码值
  s.source                 = source
  s.source_files           = "**/*.{cpp,h}"
  s.header_dir             = "ReactCommon"
end
