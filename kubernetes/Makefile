.PHONY: create_local_docker_registry connect_registry_to_kind_network \
	connect_registry_to_kind create_kind_cluster_with_registry_and_nginx_ingress \
	delete_kind_cluster delete_local_docker_registry deploy_manifests_to_cluster \
	deploy_nginx_ingress_controller


docker_registry := polar-local-registry
docker_registry_port := 5000

install_kind:
  	curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64 && \
		./kind --version

create_kind_cluster: install_kind
	@echo -e "📦 Initializing Kubernetes cluster..."
	kind create cluster --name polar-cluster --config=./local/kind/kind-config.yml || true && \
		kubectl get nodes && kubectl config get-contexts
	@echo -e "\n-----------------------------------------------------\n"	

create_local_docker_registry:
	@echo -e "📦 Creating/reusing local Docker registry..."
	@if docker ps --format '{{.Names}}' | grep -w $(docker_registry); then \
	echo "--> polar-local-registry already created; skipping"; \
	else docker run --name polar-local-registry -d --restart=always -p $(docker_registry_port):$(docker_registry_port) registry:2; fi;
	@echo -e "\n-----------------------------------------------------\n"

# Rule to connect the Docker network that was created for the kind container
# to the Docker network that's created or that's used by our registry.
connect_registry_to_kind_network: create_local_docker_registry
	@echo -e "📦 Connecting the local Docker registry to the kind network..."
	docker network connect kind polar-local-registry || true
	@echo -e "\n-----------------------------------------------------\n"

connect_registry_to_kind: connect_registry_to_kind_network
	@echo -e "📦 Connecting the local Docker registry to kind..."
	kubectl apply -f ./kind-configmap.yml
	@echo -e "\n-----------------------------------------------------\n"

deploy_nginx_ingress_controller:
	@echo -e "🔌 Installing NGINX Ingress..."
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	@echo -e "\n-----------------------------------------------------\n"
	@echo -e "⌛ Waiting for NGINX Ingress to be available..."
	sleep 10
#	 kubectl wait --namespace ingress-nginx \
#  	 	--for=condition=available pod \
#  	 	--selector=app.kubernetes.io/component=controller \
#  	 	--timeout=240s
	@echo -e "\n"
	@echo -e "⛵ Happy Sailing!"


deploy_manifests_to_cluster:
	@echo -e "🔌 Deploying configmaps, secrets and backend services into the kind cluster..."
	kubectl apply -f configmaps && kubectl apply -f secrets && kubectl apply -f services
	@echo -e "\n-----------------------------------------------------\n"

# Rule to create a new version of the "create_kind_cluster" rule,
## creating both, the cluster and the registry and link them together
create_kind_cluster_with_registry_and_nginx_ingress:
	@echo -e "📦 Creating a full local kind cluster..."
	$(MAKE) create_kind_cluster && $(MAKE) connect_registry_to_kind && $(MAKE) deploy_nginx_ingress_controller && $(MAKE) deploy_manifests_to_cluster 
	@echo -e "\n-----------------------------------------------------\n"

delete_kind_cluster: delete_local_docker_registry 
	@echo -e "📦 Removing the local kind cluster..."
	kind delete cluster --name polar-cluster
	@echo -e "\n-----------------------------------------------------\n"

delete_local_docker_registry:
	@echo -e "📦 Removing the local Docker registry..."
	if docker ps --format '{{.Names}}' | grep -w $(docker_registry); \
	then docker stop polar-local-registry && docker rm -f $(docker_registry); \
	else  echo "--> $(docker_registry) does not exists; skipping";  \
	fi
	@echo -e "\n-----------------------------------------------------\n"