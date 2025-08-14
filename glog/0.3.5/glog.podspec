# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

glog_git_url = "https://github.com/nqwlch/glog.git"

Pod::Spec.new do |spec|
  spec.name = 'glog'
  spec.version = '0.3.5'
  spec.license = { :type => 'Google', :file => 'COPYING' }
  spec.homepage = 'https://github.com/google/glog'
  spec.summary = 'Google logging module'
  spec.authors = 'Google'
  spec.libraries = "c++"
  spec.pod_target_xcconfig = {
    "CLANG_CXX_LANGUAGE_STANDARD" => "c++20"
  }
  # 合并的配置脚本内容
  spec.prepare_command = <<-CMD
    #!/bin/bash
    set -e

    # =============================================================================
    # Configuration validation subroutine (merged from config.sub)
    # =============================================================================

    config_sub() {
        local input="$1"
        
        # Split fields of configuration type
        local field1 field2 field3 field4
        IFS="-" read -r field1 field2 field3 field4 <<< "$input"
        
        # Separate into logical components for further validation
        local basic_machine basic_os
        case "$input" in
            *-*-*-*-*)
                echo "Invalid configuration '$input': more than four components" >&2
                return 1
                ;;
            *-*-*-*)
                basic_machine="$field1-$field2"
                basic_os="$field3-$field4"
                ;;
            *-*-*)
                # For iOS builds, we expect CPU-OS format
                basic_machine="$field1"
                basic_os="$field2-$field3"
                ;;
            *-*)
                basic_machine="$field1"
                basic_os="$field2"
                ;;
            *)
                basic_machine="$input"
                basic_os=""
                ;;
        esac
        
        # Decode basic machines for iOS-specific needs
        local cpu vendor
        case "$basic_machine" in
            # iOS supported architectures
            arm64-*)
                cpu="aarch64"
                vendor="apple"
                ;;
            x86_64-*)
                cpu="x86_64"
                vendor="pc"
                ;;
            i386-* | i686-*)
                cpu="i386"
                vendor="pc"
                ;;
            arm-*)
                cpu="arm"
                vendor="apple"
                ;;
            # Generic fallback
            *)
                cpu="$basic_machine"
                vendor="unknown"
                ;;
        esac
        
        # Decode operating system for iOS
        local os
        case "$basic_os" in
            darwin* | ios* | macos*)
                os="darwin"
                ;;
            *)
                os="$basic_os"
                ;;
        esac
        
        # Output canonical configuration
        echo "$cpu-$vendor${os:+-$os}"
    }

    # =============================================================================
    # Main iOS configuration script
    # =============================================================================

    PLATFORM_NAME="${PLATFORM_NAME:-iphoneos}"
    CURRENT_ARCH="${CURRENT_ARCH}"

    if [ -z "$CURRENT_ARCH" ] || [ "$CURRENT_ARCH" == "undefined_arch" ]; then
        # Xcode 10 beta sets CURRENT_ARCH to "undefined_arch", this leads to incorrect linker arg.
        # it's better to rely on platform name as fallback because architecture differs between simulator and device

        if [[ "$PLATFORM_NAME" == *"simulator"* ]]; then
            CURRENT_ARCH="x86_64"
        else
            CURRENT_ARCH="arm64"
        fi
    fi

    # Validate architecture using integrated config.sub function
    echo "Validating architecture: $CURRENT_ARCH"
    config_sub "$CURRENT_ARCH-apple-darwin" > /dev/null || {
        echo "Error: Invalid architecture configuration" >&2
        exit 1
    }

    XCRUN="$(which xcrun || true)"
    if [ -n "$XCRUN" ]; then
      export CC="$(xcrun -find -sdk $PLATFORM_NAME cc) -arch $CURRENT_ARCH -isysroot $(xcrun -sdk $PLATFORM_NAME --show-sdk-path)"
      export CXX="$CC"
    else
      export CC="$CC:-$(which gcc)"
      export CXX="$CXX:-$(which g++ || true)"
    fi
    export CXX="$CXX:-$CC"

    # Remove automake symlink if it exists
    if [ -h "test-driver" ]; then
        rm test-driver
    fi

    # Manually disable gflags include to fix issue https://github.com/facebook/react-native/issues/28446
    sed -i.bak -e 's/\\@ac_cv_have_libgflags\\@/0/' src/glog/logging.h.in && rm src/glog/logging.h.in.bak
    sed -i.bak -e 's/HAVE_LIB_GFLAGS/HAVE_LIB_GFLAGS_DISABLED/' src/config.h.in && rm src/config.h.in.bak

    ./configure --host arm-apple-darwin || true

    cat << EOF >> src/config.h
/* Add in so we have Apple Target Conditionals */
#ifdef __APPLE__
#include <TargetConditionals.h>
#include <Availability.h>
#endif

/* Special configuration for ucontext */
#undef HAVE_UCONTEXT_H
#undef PC_FROM_UCONTEXT
#if defined(__x86_64__)
#define PC_FROM_UCONTEXT uc_mcontext->__ss.__rip
#elif defined(__i386__)
#define PC_FROM_UCONTEXT uc_mcontext->__ss.__eip
#endif
EOF

    # Prepare exported header include
    EXPORTED_INCLUDE_DIR="exported/glog"
    mkdir -p exported/glog
    cp -f src/glog/log_severity.h "$EXPORTED_INCLUDE_DIR/"
    cp -f src/glog/logging.h "$EXPORTED_INCLUDE_DIR/"
    cp -f src/glog/raw_logging.h "$EXPORTED_INCLUDE_DIR/"
    cp -f src/glog/stl_logging.h "$EXPORTED_INCLUDE_DIR/"
    cp -f src/glog/vlog_is_on.h "$EXPORTED_INCLUDE_DIR/"

    echo "iOS glog configuration completed successfully for $CURRENT_ARCH architecture"
  CMD

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

end
