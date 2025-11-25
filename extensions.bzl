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

def _version_info(version):
    if version.startswith("7.1"):
        return struct(
            build_file = "@score_toolchains_qnx//toolchains:sdp_qnx710.BUILD",
            default_qcc_version = "8.3.0",
            qnx_version_constraint = "@score_toolchains_qnx//platforms:qnx7_1",
            default_license_server = "27000@10.56.17.4",
        )
    if version.startswith("8"):
        return struct(
            build_file = "@score_toolchains_qnx//toolchains:sdp.BUILD",
            default_qcc_version = "12.2.0",
            qnx_version_constraint = "@score_toolchains_qnx//platforms:qnx8_0",
            default_license_server = "",
        )

    fail("Unsupported QNX SDP version: %s" % version)

def _impl(mctx):
    for mod in mctx.modules:
        if not mod.is_root:
            fail("Only the root module can use the 'toolchains_qnx' extension")

        for sdp in mod.tags.sdp:
            name = sdp.name
            url = sdp.url
            sha256 = sdp.sha256
            strip_prefix = sdp.strip_prefix
            version = sdp.version
            version_info = _version_info(version)
            qcc_version = sdp.qcc_version if sdp.qcc_version else version_info.default_qcc_version

            http_archive(
                name = "%s_sdp" % name,
                urls = [url],
                build_file = version_info.build_file,
                sha256 = sha256,
                strip_prefix = strip_prefix,
            )

            qcc_toolchain(
                name = "%s_qcc" % name,
                sdp_repo = "%s_sdp" % name,
                qcc_version = qcc_version,
                sdp_version = version,
                qnx_version_constraint = version_info.qnx_version_constraint,
                default_license_server = version_info.default_license_server,
            )

            ifs_toolchain(
                name = "%s_ifs" % name,
                sdp_repo = "%s_sdp" % name,
                qnx_version_constraint = version_info.qnx_version_constraint,
                default_license_server = version_info.default_license_server,
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
                "version": attr.string(default = "8.0.0"),
                "qcc_version": attr.string(default = ""),
            },
        ),
    },
)
