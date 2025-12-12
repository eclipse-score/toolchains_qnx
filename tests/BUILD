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

load("@rules_pkg//pkg:tar.bzl", "pkg_tar")
load("@score_toolchains_qnx//rules/fs:ifs.bzl", "qnx_ifs")

config_setting(
    name = "is_qnx_x86_64",
    constraint_values = [
        "@platforms//cpu:x86_64",
        "@platforms//os:qnx",
        "@score_bazel_platforms//:qnx8_0",
    ],
)

config_setting(
    name = "is_qnx_aarch64",
    constraint_values = [
        "@platforms//cpu:arm64",
        "@platforms//os:qnx",
        "@score_bazel_platforms//:qnx8_0",
    ],
)

cc_binary(
    name = "main_cpp",
    srcs = ["main.cpp"],
)

genrule(
    name = "stage_main_cpp",
    srcs = [":main_cpp"],
    outs = ["install/usr/bin/main_cpp"],
    cmd = "mkdir -p $(RULEDIR)/install/usr/bin && cp $(location :main_cpp) $@ && chmod +x $@",
)

cc_binary(
    name = "main_c",
    srcs = ["main.c"],
)

pkg_tar(
    name = "main_cpp_as_pkg",
    srcs = [
        ":main_cpp",
    ],
    package_dir = "/some_directory",
)

pkg_tar(
    name = "main_cpp_as_different_pkg",
    srcs = [
        ":main_cpp",
    ],
    package_dir = "/some_other_directory",
)

qnx_ifs(
    name = "init",
    # Only include the install tree as inputs on aarch64
    srcs = select({
        ":is_qnx_aarch64": [
            ":stage_main_cpp",  # <-- staged binary
        ] + glob(["install/**"]),  # your existing overlay
        "//conditions:default": [],
    }),
    out = select({
        ":is_qnx_x86_64": "init_x86_64.ifs",
        ":is_qnx_aarch64": "init_aarch64.ifs",
    }),
    build_file = select({
        ":is_qnx_x86_64": "init_x86_64.build",
        ":is_qnx_aarch64": "init_rpi4.build",
    }),

    # Only pass -r on aarch64 (mkifs will receive: -r install)
    search_roots = select({
        ":is_qnx_aarch64": ["install"],  # relative to the .build file’s dir
        "//conditions:default": [],
    }),
    tars = {
        "EXAMPLE_KEY": ":main_cpp_as_pkg.tar",
        "ANOTHER_KEY": ":main_cpp_as_different_pkg.tar",
    },
)

sh_binary(
    name = "run_qemu",
    srcs = ["run_qemu.sh"],
    args = [
        "$(location @toolchains_qnx_sdp//:host_dir)",
        "$(location :init)",
        "$(location @custom_qemu//:qemu_bin)",
        "$(location @custom_qemu//:rpi4_dtb)",
    ],
    data = [
        ":init",
        "@custom_qemu//:qemu_bin",
        "@custom_qemu//:rpi4_dtb",
        "@toolchains_qnx_sdp//:host_all",
        "@toolchains_qnx_sdp//:host_dir",
    ],
)
