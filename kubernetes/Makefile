.PHONY: create_local_docker_registry connect_registry_to_kind_network \
	connect_registry_to_kind create_kind_cluster_with_registry_and_nginx_ingress \
	delete_kind_cluster delete_local_docker_registry deploy_manifests_to_cluster \
	deploy_dev_manifests_to_cluster deploy_nginx_ingress_controller_windows \
	deploy_nginx_ingress_controller_linux

OSFLAG :=
ifeq ($(OS),Windows_NT)
	OSFLAG += -D WIN32
	ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
		OSFLAG += -D AMD64
	endif
	ifeq ($(PROCESSOR_ARCHITECTURE),x86)
		OSFLAG += -D IA32
	endif
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		OSFLAG += -D LINUX
	endif
	ifeq ($(UNAME_S),Darwin)
		OSFLAG += -D OSX
	endif
		UNAME_P := $(shell uname -p)
	ifeq ($(UNAME_P),x86_64)
		OSFLAG += -D AMD64
	endif
		ifneq ($(filter %86,$(UNAME_P)),)
	OSFLAG += -D IA32
		endif
	ifneq ($(filter arm%,$(UNAME_P)),)
		OSFLAG += -D ARM
	endif
endif

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

deploy_nginx_ingress_controller_linux:
	@echo $(OSFLAG)
	@echo -e "🔌 Installing NGINX Ingress..."
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
	@echo -e "\n-----------------------------------------------------\n"
	@echo -e "⌛ Waiting for NGINX Ingress to be available..."
	timeout 10
	kubectl wait --for=condition=Ready pod -l app.kubernetes.io/component=controller -n ingress-nginx --timeout=300s
	kubectl wait --for=condition=Complete job -l app.kubernetes.io/component=admission-webhook -n ingress-nginx --timeout=300s
	@echo -e "\n"
	@echo -e "⛵ Happy Sailing!"

deploy_nginx_ingress_controller_windows:
	@echo $(OSFLAG)
	@echo -e "🔌 Installing NGINX Ingress..."
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
	@echo -e "\n-----------------------------------------------------\n"
	@echo -e "⌛ Waiting for NGINX Ingress to be available..."
	timeout 10
	kubectl wait --for=condition=Ready pod -l app.kubernetes.io/component=controller -n ingress-nginx --timeout=300s
	kubectl wait --for=condition=Complete job -l app.kubernetes.io/component=admission-webhook -n ingress-nginx --timeout=300s
	@echo -e "\n"
	@echo -e "⛵ Happy Sailing!"


deploy_manifests_to_cluster:
	@echo -e "🔌 Deploying configmaps, secrets and backend services into the kind cluster..."
	kubectl apply -f configmaps && kubectl apply -f secrets && kubectl apply -f services
	@echo -e "\n-----------------------------------------------------\n"

deploy_dev_manifests_to_cluster: create_kind_cluster
	@echo -e "🔌 Deploying development configmaps, secrets and backend services into the kind cluster..."
	kubectl apply -f ./local/configmaps && kubectl apply -f ./local/secrets && kubectl apply -f ./local/platform
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