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
"""
Toolchain provider implementation for QNX filesystem image rules.
"""

ToolInfo = provider(
    doc = "Executable for generating QNX filesystems.",
    fields = ["executable", "files", "env"],
)

def _impl(ctx):
    # Prefer user-provided license server, otherwise fall back to SDP default (if given).
    qnxlm_license_file = ctx.configuration.default_shell_env.get("QNXLM_LICENSE_FILE", "") or ctx.attr.default_license_server
    lm_license_file = ctx.configuration.default_shell_env.get("LM_LICENSE_FILE", "") or qnxlm_license_file

    env = {
        "QNX_HOST": "/proc/self/cwd/" + ctx.file.host_dir.path,
        "QNX_TARGET": "/proc/self/cwd/" + ctx.file.target_dir.path,
        "QNX_CONFIGURATION_EXCLUSIVE": "/var/tmp/.qnx",
        "QNX_SHARED_LICENSE_FILE": "/opt/score_qnx/license/licenses",
        "PATH": "/proc/self/cwd/" + ctx.file.host_dir.path + "/usr/bin",
    }
    if qnxlm_license_file:
        env["QNXLM_LICENSE_FILE"] = qnxlm_license_file
    if lm_license_file:
        env["LM_LICENSE_FILE"] = lm_license_file

    return [
        platform_common.ToolchainInfo(
            tool_info = ToolInfo(
                env = env,
                executable = ctx.executable.executable,
                files = depset(ctx.files.host + ctx.files.target, transitive = [ctx.attr.executable.default_runfiles.files]),
            ),
        ),
    ]

qnx_fs_toolchain_config = rule(
    _impl,
    attrs = {
        "executable": attr.label(
            cfg = "exec",
            executable = True,
            mandatory = True,
        ),
        "host_dir": attr.label(
            cfg = "exec",
            mandatory = True,
            allow_single_file = True,
        ),
        "target_dir": attr.label(
            cfg = "exec",
            mandatory = True,
            allow_single_file = True,
        ),
        "host": attr.label(
            cfg = "exec",
            mandatory = True,
        ),
        "target": attr.label(
            cfg = "exec",
            mandatory = True,
        ),
        "default_license_server": attr.string(default = ""),
    },
)
