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
	-docker network create ztm-net
	-docker network create ztm-net-db
	-docker network create ztm-net-users
	-docker network connect ztm-net ztm-gateway
	-docker network connect ztm-net ztm-srv-users
	-docker network connect ztm-net-users ztm-srv-users
	-docker network connect ztm-net-users ztm-srv-users-db
	-docker network connect ztm-net-db ztm-srv-users-db

run:
	-docker exec -it -d ztm-gateway sh -c "go run main.go"
	-docker exec -it -d ztm-srv-users sh -c "go run main.go"

clean:
	-docker stop ztm-gateway ztm-srv-users ztm-phpmyadmin ztm-srv-users-db >/dev/null 2>&1 || true
	-docker rm ztm-gateway ztm-srv-users ztm-phpmyadmin ztm-srv-users-db >/dev/null 2>&1 || true
	-docker images --format "{{.Repository}}:{{.Tag}}" | grep '^ztm-' | awk '{print $1}' | xargs -I {} docker rmi {} >/dev/null 2>&1 || true
	-docker network rm ztm-net ztm-net-db ztm-net-users >/dev/null 2>&1 || true

ztm-phpmyadmin:
	-docker run --name ztm-phpmyadmin -d -e PMA_ARBITRARY=1 -p 8080:80 phpmyadmin
	-docker network connect ztm-net-db ztm-phpmyadmin

