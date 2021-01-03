FROM alpine:3.12 as builder

RUN apk add bash e2fsprogs e2fsprogs-extra tar gzip squashfs-tools

COPY rootfs.ext4 /rootfs.ext4

RUN mkdir -p /stage1 && \
    debugfs -R "rdump / /stage1" /rootfs.ext4 && \
    unsquashfs -d /rootfs/ /stage1/volumio_current.sqsh

#RUN mkdir -p /stage2 && \
#    cd /rootfs && \
#    tar -cvf /stage2/rootfs.tar .

FROM scratch
#ADD --from=builder /stage2/rootfs.tar /
COPY --from=builder /rootfs/ /
