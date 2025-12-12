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
def _qcc_toolchain_impl(rctx):
    rctx.template(
        "BUILD",
        rctx.attr._cc_tolchain_build,
        {
            "%{toolchain_sdp}": rctx.attr.sdp_repo,
            "%{qcc_version}": rctx.attr.qcc_version,
            "%{sdp_version}": rctx.attr.sdp_version,
            "%{qnx_version_constraint}": str(rctx.attr.qnx_version_constraint),
            "%{default_license_server}": rctx.attr.default_license_server,
        },
    )

    rctx.template(
        "cc_toolchain_config.bzl",
        rctx.attr._cc_toolchain_config_bzl,
        {},
    )

qcc_toolchain = repository_rule(
    implementation = _qcc_toolchain_impl,
    attrs = {
        "sdp_repo": attr.string(),
        "qcc_version": attr.string(default = "12.2.0"),
        "sdp_version": attr.string(default = "8.0.0"),
        "qnx_version_constraint": attr.label(
            default = "@score_bazel_platforms//:qnx8_0",
        ),
        "default_license_server": attr.string(default = ""),
        "_cc_toolchain_config_bzl": attr.label(
            default = "//toolchains/qcc:cc_toolchain_config.bzl",
        ),
        "_cc_tolchain_build": attr.label(
            default = "//toolchains/qcc:toolchain.BUILD",
        ),
    },
)

def _ifs_toolchain_impl(rctx):
    rctx.template(
        "BUILD",
        rctx.attr._ifs_tolchain_build,
        {
            "%{toolchain_sdp}": rctx.attr.sdp_repo,
            "%{default_license_server}": rctx.attr.default_license_server,
            "%{qnx_version_constraint}": str(rctx.attr.qnx_version_constraint),
        },
    )

ifs_toolchain = repository_rule(
    implementation = _ifs_toolchain_impl,
    attrs = {
        "sdp_repo": attr.string(),
        "qnx_version_constraint": attr.label(
            default = "@score_bazel_platforms//:qnx8_0",
        ),
        "default_license_server": attr.string(default = ""),
        "_ifs_tolchain_build": attr.label(
            default = "//toolchains/fs/ifs:ifs.BUILD",
        ),
    },
)
