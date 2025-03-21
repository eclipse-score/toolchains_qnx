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
def _impl(rctx):
    rctx.template(
        "BUILD",
        rctx.attr._cc_tolchain_build,
        {
            "%{toolchain_sdp}": rctx.attr.sdp_repo,
        },
    )

    rctx.template(
        "cc_toolchain_config.bzl",
        rctx.attr._cc_toolchain_config_bzl,
        {},
    )

qnx_toolchain = repository_rule(
    implementation = _impl,
    attrs = {
        "sdp_repo": attr.string(),
        "_cc_toolchain_config_bzl": attr.label(
            default = "//toolchain:cc_toolchain_config.bzl",
        ),
        "_cc_tolchain_build": attr.label(
            default = "//toolchain:toolchain.BUILD",
        ),
    },
)
