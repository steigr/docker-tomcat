IMAGE    ?= steigr/tomcat
VERSION  ?= $(shell git branch | grep \* | cut -d ' ' -f2)
PORT     ?= 8080
BASE     ?= steigr/java:8_server-jre_unlimited

all: image
	@true

image:
	@sed 's#^FROM .*#FROM $(BASE)#' Dockerfile > Dockerfile.build
	[[ "$(NO_PULL)" ]] || docker pull $$(grep ^FROM Dockerfile.build | awk '{print $$2}')
	docker build --tag=$(IMAGE):$(VERSION) --file=Dockerfile.build .
	@rm Dockerfile.build

run: image
	docker run --rm --env=TRACE --publish=$(PORT):$(PORT) --name=$(shell basename $(IMAGE)) --env=CATALINA_CONNECTOR_$(PORT)_upgrade=http2 $(IMAGE):$(VERSION)
