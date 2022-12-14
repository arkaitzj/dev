DOCKER_IMAGE=arkaitzj/dev

build:
	docker build -t ${DOCKER_IMAGE} --target dev .

run:
	docker run -it --rm ${DOCKER_IMAGE}

push:
	docker push ${DOCKER_IMAGE}
