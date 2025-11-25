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
constraint_setting(
    name = "qnx_version",
    visibility = ["//visibility:public"],
)

constraint_value(
    name = "qnx7_1",
    constraint_setting = ":qnx_version",
    visibility = ["//visibility:public"],
)

constraint_value(
    name = "qnx8_0",
    constraint_setting = ":qnx_version",
    visibility = ["//visibility:public"],
)

platform(
    name = "x86_64-qnx",
    constraint_values = [
        "@platforms//cpu:x86_64",
        "@platforms//os:qnx",
        ":qnx8_0",
    ],
    visibility = ["//visibility:public"],
)

platform(
    name = "x86_64-qnx7_1",
    constraint_values = [
        "@platforms//cpu:x86_64",
        "@platforms//os:qnx",
        ":qnx7_1",
    ],
    visibility = ["//visibility:public"],
)

platform(
    name = "aarch64-qnx8_0",
    constraint_values = [
        "@platforms//cpu:aarch64",
        "@platforms//os:qnx",
        ":qnx8_0",
    ],
    visibility = ["//visibility:public"],
)

platform(
    name = "aarch64-qnx7_1",
    constraint_values = [
        "@platforms//cpu:aarch64",
        "@platforms//os:qnx",
        ":qnx7_1",
    ],
    visibility = ["//visibility:public"],
)
