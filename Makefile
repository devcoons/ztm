ifeq ($(OS), Windows_NT)
	WHERE_WHICH ?= where
else
	WHERE_WHICH ?= which
endif

ifeq (, $(shell $(WHERE_WHICH) podman))
	DOCKER := $(shell $(WHERE_WHICH) docker)
	ifeq (, $(DOCKER))
		$(error "Neither Docker nor Podman is installed. Please install one of them.")
	endif
	CONTAINER_ENGINE := docker
else
	CONTAINER_ENGINE := podman
endif

all: ztm-db ztm-srv-users ztm-gateway ztm-networks
debug: ztm-db ztm-srv-users-dbg ztm-gateway-dbg ztm-networks

ztm-db:
	-$(MAKE) -C ztm-sql-database

ztm-gateway:
	-$(MAKE) -C ztm-propylaea

ztm-gateway-dbg:
	-$(MAKE) -C ztm-propylaea build-debug
	-$(MAKE) -C ztm-propylaea run-debug

ztm-srv-users:
	-$(MAKE) -C ztm-service-users

ztm-srv-users-dbg:
	-$(MAKE) -C ztm-service-users run-db
	-$(MAKE) -C ztm-service-users build-debug
	-$(MAKE) -C ztm-service-users run-debug

ztm-networks:
	-$(CONTAINER_ENGINE) network create ztm-net
	-$(CONTAINER_ENGINE) network create ztm-net-db
	-$(CONTAINER_ENGINE) network create ztm-net-users
	-$(CONTAINER_ENGINE) network connect ztm-net ztm-gateway
	-$(CONTAINER_ENGINE) network connect ztm-net ztm-srv-users
	-$(CONTAINER_ENGINE) network connect ztm-net-users ztm-srv-users
	-$(CONTAINER_ENGINE) network connect ztm-net-users ztm-srv-users-db
	-$(CONTAINER_ENGINE) network connect ztm-net-db ztm-srv-users-db

run:
	-$(CONTAINER_ENGINE) exec -it -d ztm-gateway sh -c "go run main.go"
	-$(CONTAINER_ENGINE) exec -it -d ztm-srv-users sh -c "go run main.go"

clean:
	-$(CONTAINER_ENGINE) stop ztm-gateway ztm-srv-users ztm-phpmyadmin ztm-srv-users-db >/dev/null 2>&1 || true
	-$(CONTAINER_ENGINE) rm ztm-gateway ztm-srv-users ztm-phpmyadmin ztm-srv-users-db >/dev/null 2>&1 || true
	-$(CONTAINER_ENGINE) images --format "{{.Repository}}:{{.Tag}}" | grep '^ztm-' | awk '{print $1}' | xargs -I {} docker rmi {} >/dev/null 2>&1 || true
	-$(CONTAINER_ENGINE) network rm ztm-net ztm-net-db ztm-net-users >/dev/null 2>&1 || true

ztm-phpmyadmin:
	-$(CONTAINER_ENGINE) run --name ztm-phpmyadmin -d -e PMA_ARBITRARY=1 -p 8080:80 phpmyadmin
	-$(CONTAINER_ENGINE) network connect ztm-net-db ztm-phpmyadmin

