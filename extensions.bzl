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
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("//toolchains:rules.bzl", "ifs_toolchain", "qcc_toolchain")

QNX8_AARCH64_DEFAULT = "@score_toolchains_qnx//toolchains:sdp_aarch64.BUILD"
QNX8_X86_64_DEFAULT = "@score_toolchains_qnx//toolchains:sdp.BUILD"

def _impl(mctx):
    for mod in mctx.modules:
        if not mod.is_root:
            fail("Only the root module can use the 'toolchains_qnx' extension")

        for sdp in mod.tags.sdp:
            name = sdp.name
            url = sdp.url
            sha256 = sdp.sha256
            strip_prefix = sdp.strip_prefix

            sdp_build = sdp.sdp_build

            # --- Only allowed keys ---
            allowed_keys = ["build_in", "ext_build_file"]

            # --- Check unknown keys ---
            for key in sdp_build:
                if key not in allowed_keys:
                    fail("Unknown field '{}' in sdp_build. Allowed: {}".format(
                        key,
                        allowed_keys,
                    ))

            # --- Ensure exactly one key is set ---
            set_keys = [k for k in allowed_keys if k in sdp_build and sdp_build[k] != ""]
            if len(set_keys) != 1:
                fail(
                    "sdp_build must have exactly one of the following set: {}. Got: {}"
                        .format(allowed_keys, set_keys),
                )

            # --- Validate the key that is set ---
            key = set_keys[0]
            if key == "build_in":
                allowed_build_in = ["aarch64", "x86_64"]
                value = sdp_build[key]
                if value not in allowed_build_in:
                    fail(
                        "Invalid build_in='{}'. Expected one of: {}"
                            .format(value, allowed_build_in),
                    )
                if value == "aarch64":
                    build_file = "@score_toolchains_qnx//toolchains:sdp_aarch64.BUILD"
                else:
                    build_file = "@score_toolchains_qnx//toolchains:sdp.BUILD"
            elif key == "ext_build_file":
                build_file = sdp_build[key]

            http_archive(
                name = "%s_sdp" % name,
                urls = [url],
                build_file = build_file,
                sha256 = sha256,
                strip_prefix = strip_prefix,
            )

            qcc_toolchain(
                name = "%s_qcc" % name,
                sdp_repo = "%s_sdp" % name,
            )

            ifs_toolchain(
                name = "%s_ifs" % name,
                sdp_repo = "%s_sdp" % name,
            )

toolchains_qnx = module_extension(
    implementation = _impl,
    tag_classes = {
        "sdp": tag_class(
            attrs = {
                "name": attr.string(default = "toolchains_qnx"),
                "url": attr.string(mandatory = True),
                "strip_prefix": attr.string(default = ""),
                "sha256": attr.string(mandatory = True),
                "sdp_build": attr.string_dict(mandatory = True, doc = "Configuration for building the SDP. Allowed keys: 'build_in' (values: 'aarch64', 'x86_64'), 'ext_build_file' (path to custom BUILD file)."),
            },
        ),
    },
)
