.PHONY: run_website stop_website create_kind_cluster \
	create_local_docker_registry connect_registry_to_kind_network \
	connect_registry_to_kind create_kind_cluster_with_registry \
	delete_kind_cluster delete_local_docker_registry

# run_website:
# 	docker build -t explorecalifornia.com . && \
# 		docker run --rm --name explorecalifornia.com -p 5001:80 -d explorecalifornia.com

# stop_website:
# 	docker stop explorecalifornia.com

install_kind:
  	curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64 && \
		./kind --version

create_kind_cluster: install_kind
	kind create cluster --name polar-cluster --config ./kind_config.yml || true && \
		kubectl get nodes

create_local_docker_registry:
	if docker ps | grep -q 'polar-local-registry'; \
	then echo "--> polar-local-registry already created; skipping"; \
	else docker run --name polar-local-registry -d --restart=always -p 5000:5000 registry:2; \
	fi

# Rule to connect the Docker network that was created for the kind container
# to the Docker network that's created or that's used by our registry.
connect_registry_to_kind_network: create_local_docker_registry
	docker network connect kind polar-local-registry || true

connect_registry_to_kind: connect_registry_to_kind_network
	kubectl apply -f ./kind_configmap.yml

deploy_nginx_ingress_controller:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml


deploy_manifests_to_cluster:
	kubectl apply -f configs && kubectl apply -f secrets && kubectl apply -f services

# Rule to create a new version of the "create_kind_cluster" rule,
## creating both, the cluster and the registry and link them together
create_kind_cluster_with_registry:
	$(MAKE) create_kind_cluster && $(MAKE) connect_registry_to_kind && $(MAKE) deploy_manifests_to_cluster 

delete_kind_cluster: delete_local_docker_registry 
	kind delete cluster --name polar-cluster

delete_local_docker_registry:
	if docker ps | grep -q 'polar-local-registry'; \
	then docker stop polar-local-registry && docker rm -f polar-local-registry; \
	else  echo "--> polar-local-registry does not exists; skipping";  \
	fi