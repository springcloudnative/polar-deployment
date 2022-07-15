#!/bin/bash
#
# Starts a portforwarding service on a remote Docker.
#
# Usage:
#   start-portforward-service.sh
#   portforward.sh [port]
#
# Adapted from
# https://github.com/kubernetes-retired/kubeadm-dind-cluster/blob/master/build/portforward.sh
#
# Copyright 2020 The Kubernetes Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

CONTAINER_NAME='portforward'
running="$(docker inspect -f '{{.State.Running}}' "${CONTAINER_NAME}" 2>/dev/null || true)"

if [[ $(docker ps -a --filter="name=$CONTAINER_NAME" --filter "status=exited" | grep -w "$CONTAINER_NAME") ]]; then
    echo "docker start ${CONTAINER_NAME}..."
elif [[ $(docker ps -a --filter="name=$CONTAINER_NAME" --filter "status=running" | grep -w "$CONTAINER_NAME") ]]; then
    echo "docker ${CONTAINER_NAME} still running"
else
    echo "docker run ${CONTAINER_NAME}..."
    docker run --rm -d -it \
        --name "${CONTAINER_NAME}" --net=host \
        --entrypoint /bin/sh \
        alpine/socat -c "while true; do sleep 1000; done"    
fi
