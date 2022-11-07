all: ztm-db ztm-srv-users ztm-gateway ztm-networks

debug: ztm-db ztm-gateway-dbg ztm-srv-users-dbg ztm-networks

ztm-db:
	$(MAKE) -C ztm-sql-database

ztm-gateway:
	$(MAKE) -C ztm-propylaea	

ztm-srv-users:
	$(MAKE) -C ztm-service-users	

ztm-gateway-dbg:
	$(MAKE) -C ztm-propylaea build-debug
	$(MAKE) -C ztm-propylaea run-debug

ztm-srv-users-dbg:
	$(MAKE) -C ztm-service-users run-db	
	$(MAKE) -C ztm-service-users build-debug
	$(MAKE) -C ztm-service-users run-debug	

ztm-networks:
	-docker network create ztm-net 
	-docker network create ztm-net-users
	-docker network connect ztm-net ztm-gateway
	-docker network connect ztm-net ztm-srv-users
	-docker network connect ztm-net-users ztm-srv-users
	-docker network connect ztm-net-users ztm-srv-users-db


