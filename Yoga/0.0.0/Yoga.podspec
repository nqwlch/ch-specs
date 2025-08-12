# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

version = "0.0.0"

source = { :git => 'https://github.com/nqwlch/Yoga.git' }
source[:tag] = "v#{version}"

Pod::Spec.new do |spec|
  spec.name = 'Yoga'
  spec.version = version
  spec.license =  { :type => 'MIT' }
  spec.homepage = 'https://yogalayout.dev'
  spec.documentation_url = 'https://yogalayout.dev/docs/'

  spec.summary = 'Yoga is a cross-platform layout engine which implements Flexbox.'
  spec.description = 'Yoga is a cross-platform layout engine enabling maximum collaboration within your team by implementing an API many designers are familiar with, and opening it up to developers across different platforms.'

  spec.authors = 'Facebook'
  spec.source = source

  spec.module_name = 'yoga'
  spec.header_dir = 'yoga'
  spec.requires_arc = false
  spec.pod_target_xcconfig = {
      'DEFINES_MODULE' => 'YES'
  }.merge!(ENV['USE_FRAMEWORKS'] != nil ? {
      'HEADER_SEARCH_PATHS' => '"$(PODS_TARGET_SRCROOT)"'
  } : {})
  spec.compiler_flags = [
      '-fno-omit-frame-pointer',
      '-fexceptions',
      '-Wall',
      '-Werror',
      '-std=c++20',
      '-fPIC'
  ]

  # Pinning to the same version as React.podspec.
  spec.platforms = { :ios => '15.1' }

  # Set this environment variable when *not* using the `:path` option to install the pod.
  # E.g. when publishing this spec to a spec repo.
  csource_files = 'yoga/**/*.{cpp,h}'
  spec.source_files = csource_files
  spec.header_mappings_dir = 'yoga'

  cpublic_header_files = 'yoga/*.h'
  spec.public_header_files = cpublic_header_files

  # Fabric must be able to access private headers (which should not be included in the umbrella header)
  call_header_files = 'yoga/**/*.h'
  spec.private_header_files = Dir.glob(call_header_files) - Dir.glob(cpublic_header_files)
  spec.preserve_paths = [call_header_files]
end
