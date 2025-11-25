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
load("@score_toolchains_qnx//toolchains/fs:toolchain.bzl", "qnx_fs_toolchain_config")

qnx_fs_toolchain_config(
    name = "mkifs_toolchain",
    executable = "@%{toolchain_sdp}//:mkifs",
    host_dir = "@%{toolchain_sdp}//:host_dir",
    target_dir = "@%{toolchain_sdp}//:target_dir",
    host = "@%{toolchain_sdp}//:host_all",
    target = "@%{toolchain_sdp}//:target_all",
    default_license_server = "%{default_license_server}",
)

qnx_fs_toolchain_config(
    name = "mkifs_toolchain_aarch64",
    executable = "@%{toolchain_sdp}//:aarch64_mkifs",
    host_dir = "@%{toolchain_sdp}//:aarch64_host_dir",
    target_dir = "@%{toolchain_sdp}//:aarch64_target_dir",
    host = "@%{toolchain_sdp}//:aarch64_host_all",
    target = "@%{toolchain_sdp}//:aarch64_target_all",
    default_license_server = "%{default_license_server}",
)

toolchain(
    name = "ifs_x86_64",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:qnx",
        "%{qnx_version_constraint}",
    ],
    toolchain = ":mkifs_toolchain",
    toolchain_type = "@score_toolchains_qnx//toolchains/fs/ifs:toolchain_type",
)


toolchain(
    name = "ifs_aarch64",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:aarch64",
        "@platforms//os:qnx",
        "%{qnx_version_constraint}",
    ],
    toolchain = ":mkifs_toolchain_aarch64",
    toolchain_type = "@score_toolchains_qnx//toolchains/fs/ifs:toolchain_type",
)
