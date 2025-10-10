# *******************************************************************************
# Copyright (c) 2025 Contributors to the Eclipse Foundation
#
# See the NOTICE file(s) distributed with this work for additional
# information regarding copyright ownership.
#
# This program and the accompanying materials are made available under the
# terms of the Apache License Version 2.0 which is available at
# https://www.apache.org/licenses/LICENSE-2.0
#
# SPDX-License-Identifier: Apache-2.0
# *******************************************************************************
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "action_config",
    "env_entry",
    "env_set",
    "feature",
    "flag_group",
    "flag_set",
    "tool",
    "tool_path",
    "with_feature_set",
)

all_cpp_compile_actions = [
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.cpp_header_parsing,
    ACTION_NAMES.cpp_module_compile,
    ACTION_NAMES.cpp_module_codegen,
    ACTION_NAMES.clif_match,
    ACTION_NAMES.lto_backend,
]

all_c_compile_actions = [
    ACTION_NAMES.c_compile,
]

all_assemble_actions = [
    ACTION_NAMES.assemble,
    ACTION_NAMES.preprocess_assemble,
]

all_compile_actions = all_c_compile_actions + all_cpp_compile_actions + all_assemble_actions

all_link_actions = [
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
]

all_actions = all_compile_actions + all_link_actions + [
    ACTION_NAMES.strip,
    ACTION_NAMES.cpp_link_static_library,
]

def _impl(ctx):
    dbg_feature = feature(name = "dbg")
    opt_feature = feature(name = "opt")

    assemble_action = action_config(
        action_name = ACTION_NAMES.assemble,
        tools = [tool(tool = ctx.executable.cc_binary)],
    )
    preprocess_assemble_action = action_config(
        action_name = ACTION_NAMES.preprocess_assemble,
        tools = [tool(tool = ctx.executable.cc_binary)],
    )
    c_compile_action = action_config(
        action_name = ACTION_NAMES.c_compile,
        tools = [tool(tool = ctx.executable.cc_binary)],
    )
    cpp_compile_action = action_config(
        action_name = ACTION_NAMES.cpp_compile,
        tools = [tool(tool = ctx.executable.cxx_binary)],
    )
    cpp_link_executable_action = action_config(
        action_name = ACTION_NAMES.cpp_link_executable,
        tools = [tool(tool = ctx.executable.cxx_binary)],
    )
    cpp_link_dynamic_library_action = action_config(
        action_name = ACTION_NAMES.cpp_link_dynamic_library,
        tools = [tool(tool = ctx.executable.cxx_binary)],
    )
    cpp_link_nodeps_dynamic_library_action = action_config(
        action_name = ACTION_NAMES.cpp_link_nodeps_dynamic_library,
        tools = [tool(tool = ctx.executable.cxx_binary)],
    )
    cpp_link_static_library_action = action_config(
        action_name = ACTION_NAMES.cpp_link_static_library,
        tools = [tool(tool = ctx.executable.ar_binary)],
        implies = ["archiver_flags"],
    )
    strip_action = action_config(
        action_name = ACTION_NAMES.strip,
        tools = [tool(tool = ctx.executable.strip_binary)],
        flag_sets = [
            flag_set(
                flag_groups = [
                    flag_group(
                        flags = [
                            "-S",
                            "-p",
                            "--strip-all",
                        ],
                    ),
                    flag_group(
                        iterate_over = "stripopts",
                        flags = ["%{stripopts}"],
                    ),
                    flag_group(
                        flags = [
                            "-o",
                            "%{output_file}",
                            "%{input_file}",
                        ],
                    ),
                ],
            ),
        ],
    )

    action_configs = [
        assemble_action,
        c_compile_action,
        cpp_compile_action,
        cpp_link_dynamic_library_action,
        cpp_link_executable_action,
        cpp_link_nodeps_dynamic_library_action,
        cpp_link_static_library_action,
        preprocess_assemble_action,
        strip_action,
    ]

    unfiltered_compile_flags_feature = feature(
        name = "unfiltered_compile_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_c_compile_actions + all_cpp_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-D__DATE__=\"redacted\"",
                            "-D__TIMESTAMP__=\"redacted\"",
                            "-D__TIME__=\"redacted\"",
                            "-Wno-builtin-macro-redefined",
                        ],
                    ),
                ],
            ),
        ],
    )

    default_compile_flags_feature = feature(
        name = "default_compile_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-V12.2.0,gcc_ntox86_64",
                            "-fno-canonical-system-headers",
                        ],
                    ),
                ],
            ),
            flag_set(
                actions = all_cpp_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-std=gnu++17",
                        ],
                    ),
                ],
                with_features = [
                    with_feature_set(not_features = ["c++17", "c++20"]),
                ],
            ),
            flag_set(
                actions = all_c_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-std=c11",
                        ],
                    ),
                ],
            ),
            flag_set(
                actions = all_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-Og",
                            "-g3",
                        ],
                    ),
                ],
                with_features = [with_feature_set(features = ["dbg"])],
            ),
            flag_set(
                actions = all_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-O2",
                            "-DNDEBUG",
                        ],
                    ),
                ],
                with_features = [with_feature_set(features = ["opt"])],
            ),
        ],
    )

    default_link_flags_feature = feature(
        name = "default_link_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_link_actions,
                flag_groups = [
                    flag_group(flags = [
                        "-Wl,-z,relro",
                        "-Wl,-z,now",
                        "-Wl,--push-state",
                        "-Wl,--as-needed",
                        "-lc++",
                        "-lm",
                        "-Wl,--pop-state",
                    ]),
                ],
            ),
        ],
    )

    minimal_warnings_feature = feature(
        name = "minimal_warnings",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-Wall",
                            "-Wno-error=deprecated-declarations",
                        ],
                    ),
                ],
                with_features = [
                    with_feature_set(not_features = ["third_party_warnings"]),
                ],
            ),
        ],
    )

    strict_warnings_feature = feature(
        name = "strict_warnings",
        implies = ["minimal_warnings"],
        flag_sets = [
            flag_set(
                actions = all_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-Wextra",
                            "-Wpedantic",
                        ],
                    ),
                ],
                with_features = [
                    with_feature_set(not_features = ["third_party_warnings"]),
                ],
            ),
            flag_set(
                actions = all_cpp_compile_actions,
                flag_groups = [],
                with_features = [
                    with_feature_set(not_features = ["third_party_warnings"]),
                ],
            ),
            flag_set(
                actions = all_c_compile_actions,
                flag_groups = [],
                with_features = [
                    with_feature_set(not_features = ["third_party_warnings"]),
                ],
            ),
        ],
    )

    treat_warnings_as_errors_feature = feature(
        name = "treat_warnings_as_errors",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-Werror",
                        ],
                    ),
                ],
                with_features = [
                    with_feature_set(not_features = ["third_party_warnings"]),
                ],
            ),
        ],
    )

    third_party_warnings_feature = feature(
        name = "third_party_warnings",
        flag_sets = [
            flag_set(
                actions = all_compile_actions,
                flag_groups = [],
            ),
        ],
    )

    cxx17_feature = feature(
        name = "c++17",
        provides = ["cxx_std"],
        flag_sets = [
            flag_set(
                actions = all_cpp_compile_actions,
                flag_groups = [
                    flag_group(flags = ["-std=c++17"]),
                ],
            ),
        ],
    )

    cxx20_feature = feature(
        name = "c++20",
        provides = ["cxx_std"],
        flag_sets = [
            flag_set(
                actions = all_cpp_compile_actions,
                flag_groups = [
                    flag_group(flags = ["-std=c++20"]),
                ],
            ),
        ],
    )

    supports_pic_feature = feature(name = "supports_pic", enabled = True)

    dependency_file_named_implicitly_feature = feature(
        name = "dependency_file_named_implicitly",
        enabled = False,
    )

    dependency_file_feature = feature(
        name = "dependency_file",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.objc_compile,
                    ACTION_NAMES.objcpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.clif_match,
                ],
                flag_groups = [flag_group(flags = [
                    "-Wc,-MD,%{dependency_file}",
                    "-Wp,-MD,%{dependency_file}",
                ])],
                with_features = [
                    with_feature_set(not_features = ["dependency_file_named_implicitly"]),
                ],
            ),
            flag_set(
                actions = [
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.objc_compile,
                    ACTION_NAMES.objcpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.clif_match,
                ],
                flag_groups = [flag_group(flags = [
                    "-Wc,-MD",
                    "-Wp,-MD",
                ])],
                with_features = [
                    with_feature_set(features = ["dependency_file_named_implicitly"]),
                ],
            ),
        ],
    )

    sdp_env_feature = feature(
        name = "sdp_env",
        enabled = True,
        env_sets = [
            env_set(
                actions = all_compile_actions + all_link_actions,
                env_entries = [
                    env_entry(key = "QNX_HOST", value = "/proc/self/cwd/" + ctx.file.qnx_host.path),
                    env_entry(key = "QNX_TARGET", value = "/proc/self/cwd/" + ctx.file.qnx_target.path),
                    env_entry(key = "QNX_CONFIGURATION_EXCLUSIVE", value = "/var/tmp/.qnx"),
                    env_entry(key = "QNX_SHARED_LICENSE_FILE", value = "/opt/score_qnx/license/licenses"),
                ],
            ),
        ],
    )

    features = [
        dbg_feature,
        default_compile_flags_feature,
        dependency_file_named_implicitly_feature,
        dependency_file_feature,
        cxx17_feature,
        cxx20_feature,
        default_link_flags_feature,
        minimal_warnings_feature,
        opt_feature,
        sdp_env_feature,
        strict_warnings_feature,
        supports_pic_feature,
        treat_warnings_as_errors_feature,
        third_party_warnings_feature,
        unfiltered_compile_flags_feature,
    ]

    cxx_builtin_include_directories = [
        "/proc/self/cwd/{}".format(include_directory.path)
        for include_directory in ctx.files.cxx_builtin_include_directories
    ]

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        abi_version = "x86_64-qnx8.0.0",
        abi_libc_version = "unknown",
        compiler = "qcc",
        cxx_builtin_include_directories = cxx_builtin_include_directories,
        features = features,
        action_configs = action_configs,
        host_system_name = "local",
        target_system_name = "x86_64-qnx",
        target_cpu = "x86_64",
        target_libc = "unknown",
        toolchain_identifier = "x86_64-qnx8.0.0",
    )

cc_toolchain_config = rule(
    implementation = _impl,
    provides = [CcToolchainConfigInfo],
    attrs = {
        "ar_binary": attr.label(allow_single_file = True, executable = True, cfg = "exec", mandatory = True),
        "cc_binary": attr.label(allow_single_file = True, executable = True, cfg = "exec", mandatory = True),
        "cxx_binary": attr.label(allow_single_file = True, executable = True, cfg = "exec", mandatory = True),
        "strip_binary": attr.label(allow_single_file = True, executable = True, cfg = "exec", mandatory = True),
        "qnx_host": attr.label(allow_single_file = True, mandatory = True),
        "qnx_target": attr.label(allow_single_file = True, mandatory = True),
        "cxx_builtin_include_directories": attr.label(allow_files = True, mandatory = True),
    },
)
