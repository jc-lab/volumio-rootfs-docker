VOLUMIO_OS_IMAGE_URL=https://updates.volumio.org/pi/volumio/2.861/volumio-2.861-2020-12-22-pi.img.zip
VOLUMIO_OS_IMAGE_NAME=volumio-2.861-2020-12-22-pi

SUDO=$(shell which sudo)

CURRENT_MACHINE=$(shell uname -m)
CURRENT_IS_ARMHF = 0

ifeq ($(CURRENT_MACHINE), armhf)
CURRENT_IS_ARMHF = 1
endif

ifeq ($(CURRENT_MACHINE), armv71)
CURRENT_IS_ARMHF = 1
endif

WORKDIR=work

DOCKER_IMAGE=jclab/volumio-rootfs:2.861-2020-12-22-pi

work/prepare:
	mkdir work
	touch work/prepare

work/volumio.img: work/prepare
	wget -O work/$(VOLUMIO_OS_IMAGE_NAME).img.zip $(VOLUMIO_OS_IMAGE_URL)
	cd work && unzip $(VOLUMIO_OS_IMAGE_NAME).img.zip
	rm work/$(VOLUMIO_OS_IMAGE_NAME).img.zip
	mv work/$(VOLUMIO_OS_IMAGE_NAME).img work/volumio.img

work/docker/Dockerfile:
	mkdir -p work/docker
	cp Dockerfile work/docker/Dockerfile

work/docker/rootfs.ext4: work/volumio.img
	mkdir -p work/docker
	sh extract_rootfs.sh work/volumio.img work/docker/rootfs.ext4

ifeq ($(CURRENT_IS_ARMHF), 1)
work/docker-built: work/docker/Dockerfile work/docker/rootfs.ext4
	$(SUDO) docker build --tag=$(DOCKER_IMAGE) work/docker/
	touch work/docker-built
else
work/docker-built: work/docker/Dockerfile work/docker/rootfs.ext4
	echo "CURRENT_IS_ARMHF=$(CURRENT_IS_ARMHF)"
	$(SUDO) docker build --platform=armhf --tag=$(DOCKER_IMAGE) work/docker/
	touch work/docker-built
endif

all: work/docker-built

