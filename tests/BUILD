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

load("@score_toolchains_qnx//rules/fs:ifs.bzl", "qnx_ifs")

cc_binary(
    name = "main_cpp",
    srcs = ["main.cpp"],
)

cc_binary(
    name = "main_c",
    srcs = ["main.c"],
)

qnx_ifs(
    name = "init",
    build_file = "init.build",
)

sh_binary(
    name = "run_qemu",
    srcs = ["run_qemu.sh"],
    args = [
        "$(location @toolchains_qnx_sdp//:host_dir)",
        "$(location :init)",
    ],
    data = [
        ":init",
        "@toolchains_qnx_sdp//:host_all",
        "@toolchains_qnx_sdp//:host_dir",
    ],
)
