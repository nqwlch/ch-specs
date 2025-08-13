# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

glog_git_url = "https://github.com/google/glog.git"

Pod::Spec.new do |spec|
  spec.name = 'glog'
  spec.version = '0.3.5'
  spec.license = { :type => 'Google', :file => 'COPYING' }
  spec.homepage = 'https://github.com/google/glog'
  spec.summary = 'Google logging module'
  spec.authors = 'Google'

  
  spec.source = { :git => glog_git_url,
                  :tag => "v#{spec.version}" }
  spec.module_name = 'glog'
  spec.header_dir = 'glog'
  spec.source_files = 'src/glog/*.h',
                      'src/demangle.cc',
                      'src/logging.cc',
                      'src/raw_logging.cc',
                      'src/signalhandler.cc',
                      'src/symbolize.cc',
                      'src/utilities.cc',
                      'src/vlog_is_on.cc'
  # workaround for https://github.com/facebook/react-native/issues/14326
  spec.preserve_paths = 'src/*.h',
                        'src/base/*.h'
  spec.exclude_files       = "src/windows/**/*"
  spec.compiler_flags      = '-Wno-shorten-64-to-32'
  # spec.resource_bundles = {'glog_privacy' => 'glog/PrivacyInfo.xcprivacy'}

  spec.pod_target_xcconfig = {
    "USE_HEADERMAP" => "NO",
    "HEADER_SEARCH_PATHS" => "$(PODS_TARGET_SRCROOT)/src",
    "DEFINES_MODULE" => "YES",
    "GCC_WARN_INHIBIT_ALL_WARNINGS" => "YES" # Disable warnings because we don't control this library
  }

  # Pinning to the same version as React.podspec.
  spec.platforms = { :ios => '15.1' }
    # 安装阶段生成 config.h（只跑一次）
  spec.prepare_command = <<-CMD
    set -e
    # 确保有 autoconf 工具链（autoconf/automake/libtool），若无请先安装
    if [ ! -f "./configure" ] && [ -f "./autogen.sh" ]; then ./autogen.sh || true; fi

    # 选择 SDK 与架构，确保交叉编译时能正确链接
    PLATFORM_NAME="${PLATFORM_NAME:-iphoneos}"
    SDK_PATH="$(xcrun -sdk $PLATFORM_NAME --show-sdk-path 2>/dev/null || xcrun -sdk iphoneos --show-sdk-path)"
    ARCH="$(uname -m)"
    if [[ "$PLATFORM_NAME" == *"simulator"* ]]; then
      MIN_FLAG="-mios-simulator-version-min=11.0"
    else
      MIN_FLAG="-miphoneos-version-min=11.0"
    fi

    export SDKROOT="$SDK_PATH"
    export CC="$(xcrun -find -sdk $PLATFORM_NAME clang) -arch $ARCH -isysroot $SDK_PATH $MIN_FLAG"
    export CXX="$(xcrun -find -sdk $PLATFORM_NAME clang++) -arch $ARCH -isysroot $SDK_PATH $MIN_FLAG"
    export AR="$(xcrun -find -sdk $PLATFORM_NAME ar)"
    export NM="$(xcrun -find -sdk $PLATFORM_NAME nm)"
    export RANLIB="$(xcrun -find -sdk $PLATFORM_NAME ranlib)"
    export LIBTOOL="$(xcrun -find -sdk $PLATFORM_NAME libtool)"
    export CFLAGS="-fembed-bitcode"
    export CXXFLAGS="-fembed-bitcode"
    export CPPFLAGS="-isysroot $SDK_PATH -arch $ARCH $MIN_FLAG"
    export LDFLAGS="-isysroot $SDK_PATH -arch $ARCH $MIN_FLAG"

    # 生成 config.h（为 iOS 规避部分运行时探测）
    if [[ "$ARCH" == arm* ]]; then
      HOST_TRIPLE="arm-apple-darwin"
    else
      HOST_TRIPLE="$ARCH-apple-darwin"
    fi
    ./configure --host="$HOST_TRIPLE" ac_cv_func_malloc_0_nonnull=yes ac_cv_func_calloc_0_nonnull=yes || true

    # glog 源码期望在 src/ 下能找到 config.h
    if [ -f "config.h" ]; then
      cp -f config.h src/config.h
    fi

    # 避免在 iOS 上使用不可用特性（若 configure 未正确识别，可强制关闭）
    sed -i'' -e 's/^#define HAVE_DLADDR 1/\\/\\/ #undef HAVE_DLADDR/' src/config.h || true
    sed -i'' -e 's/^#define HAVE_STACKTRACE 1/\\/\\/ #undef HAVE_STACKTRACE/' src/config.h || true

    # 清理可能导致旧版 automake 行为的符号链接
    if [ -h "test-driver" ]; then
      rm -f test-driver
    fi

    # 如果系统安装了 autoconf/automake，尝试刷新构建脚本，更新 missing 等辅助脚本
    if command -v autoreconf >/dev/null 2>&1; then
      autoreconf -fvi || true
    fi

    export IPHONEOS_DEPLOYMENT_TARGET="11.0"
  CMD
end
