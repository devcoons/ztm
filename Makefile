all: ztm-db ztm-srv-users ztm-gateway ztm-networks

ztm-db:
	$(MAKE) -C ztm-sql-database

ztm-srv-users:
	$(MAKE) -C ztm-service-users	

ztm-gateway:
	$(MAKE) -C ztm-propylaea	

ztm-networks:
	-docker network create ztm-net 
	-docker network create ztm-net-users
	-docker network connect ztm-net ztm-gateway
	-docker network connect ztm-net ztm-srv-users
	-docker network connect ztm-net-users ztm-srv-users
	-docker network connect ztm-net-users ztm-srv-users-db


