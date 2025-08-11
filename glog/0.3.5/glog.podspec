Pod::Spec.new do |s|
  s.name         = "glog"
  s.version      = "0.3.5"
  s.summary      = "Google Logging Library"
  s.homepage     = "https://github.com/google/glog"
  s.license      = { :type => "BSD", :file => "COPYING" }
  s.authors      = { "Google" => "opensource@google.com" }
  s.source       = { :git => "https://github.com/nqwlch/glog.git", :tag => "v#{s.version}" }

  s.requires_arc = false
  s.static_framework = true
  s.platforms = { :ios => "11.0", :tvos => "11.0", :osx => "10.13" }

  # 公开头文件需要是 <glog/logging.h> 这种包含方式
  s.source_files = [
    # 头文件（供编译与索引使用）
    "src/**/*.h",
    "src/**/*.hpp",
    # 仅编译 glog 必需的实现文件
    "src/demangle.cc",
    "src/logging.cc",
    "src/raw_logging.cc",
    "src/signalhandler.cc",
    "src/symbolize.cc",
    "src/utilities.cc",
    "src/vlog_is_on.cc"
  ]
  s.public_header_files = "src/glog/*.h"
  s.header_mappings_dir = "src"
  s.exclude_files = [
    "src/windows/**",
    "googletest/**",
    "cmake/**",
    "doc/**",
    "scripts/**",
    # 排除所有测试与示例相关源码与头，避免 iOS 编译错误
    "src/*test*.cc",
    "src/*unittest*.cc",
    "src/logging_striptest*.cc",
    "src/logging_striptest_main.cc",
    "src/mock-log_test.cc",
    "src/googletest.h"
  ]

  # C++ 配置与宏
  s.pod_target_xcconfig = {
    "CLANG_CXX_LANGUAGE_STANDARD" => "gnu++17",
    "CLANG_CXX_LIBRARY" => "libc++",
    "GCC_PREPROCESSOR_DEFINITIONS" => "GLOG_OS_MACOSX=1 GLOG_NO_ABBREVIATED_SEVERITIES=1"
  }
  s.platform = :ios, '15.1'

  # 安装阶段生成 config.h（只跑一次）
  s.prepare_command = <<-CMD
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