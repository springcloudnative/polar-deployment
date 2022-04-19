#!/bin/bash

set -oe errexit

# desired cluster name; default is "kind"
KIND_CLUSTER_NAME="polar-cluster"

# default registry name and port
reg_name='polar-registry'
reg_port='5000'

echo ">> initializing Docker registry"

# create registry container unless it already exists
running="$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)"
if [ "${running}" != 'true' ]; then
  docker run \
    -d --restart=always -p "${reg_port}:5000" --name "${reg_name}" \
    registry:2
fi

echo ">> initializing Kind cluster: ${KIND_CLUSTER_NAME} with registry ${reg_name}, extraPortMappings and node-labels..."

# create a cluster with the local registry enabled in containerd
kind create cluster --name "${KIND_CLUSTER_NAME}" --config=kind-config.yml
# cat <<EOF | kind create cluster --name "${KIND_CLUSTER_NAME}" --config=-
# kind: Cluster
# apiVersion: kind.x-k8s.io/v1alpha4
# nodes:
# - role: control-plane
#   kubeadmConfigPatches:
#   - |
#     kind: InitConfiguration
#     nodeRegistration:
#       kubeletExtraArgs:
#         node-labels: "ingress-ready=true"
#   extraPortMappings:
#   - containerPort: 80
#     hostPort: 80
#     protocol: TCP
#   - containerPort: 443
#     hostPort: 443
#     protocol: TCP          
# containerdConfigPatches:
# - |-
#   [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
#     endpoint = ["http://${reg_name}:${reg_port}"]
# EOF

if [ "${running}" != 'true' ]; then
  docker network connect kind "${reg_name}"
fi

echo ">> Deploying NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# echo ">> Waiting until NGINX Ingress Controller is ready to process request running..."
# kubectl wait --for=condition=ready pod \
#   --selector=app.kubernetes.io/component=controller \
#   --timeout=100s

# echo ">> Applying the NGINX Ingress Controller contents..."  
# kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/usage.yaml

echo ">> port-forwarding k8s API server"
./cluster/start-portforward-service.sh start

APISERVER_PORT=$(kubectl config view -o jsonpath='{.clusters[].cluster.server}' | cut -d: -f 3 -)
./cluster/portforward.sh $APISERVER_PORT
kubectl get nodes # make sure it worked

echo ">> port-forwarding local registry"
./cluster/portforward.sh $reg_port

echo ">> applying local-registry docs"

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${reg_port}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF

echo ">> waiting for kubernetes node(s) become ready"
kubectl wait --for=condition=ready node --all --timeout=60s

echo ">> Deploying platform services, configurations and secrets..."

kubectl apply -f secrets
kubectl apply -f config
kubectl apply -f services

sleep 5

echo ">>⌛ Waiting for MySQL to be deployed..."

while [ $(kubectl get pod -l app=polar-mysql | wc -l) -eq 0 ] ; do
  sleep 5
done

echo ">>⌛ Waiting for MySQL to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=app=polar-mysql \
  --timeout=300s

echo ">>⌛ Waiting for Redis to be deployed..."

while [ $(kubectl get pod -l db=polar-redis | wc -l) -eq 0 ] ; do
  sleep 5
done

echo ">>⌛ Waiting for Redis to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=db=polar-redis \
  --timeout=300s

echo ">> with-kind-cluster.sh setup complete! Running user script: $@"
exec "$@"