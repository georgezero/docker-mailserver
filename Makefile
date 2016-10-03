IMGNAME = rpi-mailservertv
VERSION = 0.01
USER=georgezero
.PHONY: all build test taglatest  

all: build test

build:
	@docker build -t $(IMGNAME):$(VERSION) --rm . && echo Buildname: $(IMGNAME):$(VERSION)
test:
	sudo docker run -it \
        --name $(IMGNAME)_test \
		--network=host
	--rm \
	$(IMGNAME):$(VERSION) \
        /start.sh || sudo docker stop $(IMGNAME)_test && docker rm $(IMGNAME)_test
run: 
	sudo docker run -it \
        --name $(IMGNAME)_run \
		--network=host
	$(IMGNAME):$(VERSION) 
stop:
	@docker stop $(IMGNAME)_test || docker stop $(IMGNAME)_run || docker stop $(IMGNAME)_shell
	@docker rm $(IMGNAME)_test || docker rm $(IMGNAME)_run || docker rm $(IMGNAME)_shell
shell:
	@sudo docker run -t \
        --name $(IMGNAME)_shell \
		--network=host \
        -ti --entrypoint=/bin/bash \
	--rm \
	$(IMGNAME):$(VERSION) || sudo docker stop $(IMGNAME)_shell && docker rm $(IMGNAME)_shell
clean:
	@docker ps -a |grep $(IMGNAME) |cut -f 1 -d' '|xargs -P1 -i docker stop {}
	@docker ps -a |grep $(IMGNAME) |cut -f 1 -d' '|xargs -P1 -i docker rm {}
	@docker rmi $(IMGNAME):$(VERSION)
taglatest:
	docker tag $(IMGNAME):$(VERSION) $(IMGNAME):latest
	docker tag $(IMGNAME):$(VERSION) $(USER)/$(IMGNAME):$(VERSION)
	docker tag $(IMGNAME):$(VERSION) $(USER)/$(IMGNAME):latest
push:
	docker push $(USER)/$(IMGNAME)
	docker push $(USER)/$(IMGNAME):$(VERSION)
release: taglatest push
