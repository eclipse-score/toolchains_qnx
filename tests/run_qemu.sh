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
#!/bin/bash

set -euo pipefail

QNX_HOST=$1

IFS_IMAGE=$2

qemu-system-x86_64 \
                -smp 2 \
                --enable-kvm \
                --cpu host \
                -m 1G \
                -pidfile /tmp/qemu.pid \
                -nographic \
                -kernel "${IFS_IMAGE}" \
                -serial mon:stdio \
                -object rng-random,filename=/dev/urandom,id=rng0 \
                -device virtio-rng-pci,rng=rng0 &

sleep 5

kill $(cat /tmp/qemu.pid)
