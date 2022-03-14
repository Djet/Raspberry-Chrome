FROM alpine:3.14
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
# hadolint ignore=DL3018
RUN apk add --no-cache \
        util-linux \
        eudev \
        chrony \
        rsyslog \
        openrc \
        alpine-base \
        dhclient \
        dropbear \
        haveged \
        xorg-server \
        xf86-video-fbdev \
        mesa-egl \
        mesa-gles \
        mesa-dri-gallium \
        libinput \
        xf86-input-evdev \
        chromium \
        chromium-swiftshader \
        i3wm \
  && rm -rf /usr/share/man \
    /tmp/* \
    /root/.cache \
    && sed -i -e 's/#rc_sys=".*"/rc_sys=""/g' /etc/rc.conf \
    && sed -i -e 's/#rc_depend_strict=".*"/rc_depend_strict=""/g' /etc/rc.conf \
    && sed -i -e 's/#rc_parallel=".*"/rc_parallel="YES"/g' /etc/rc.conf \
    && sed -i -e 's/#rc_logger=".*"/rc_sys="YES"/g' /etc/rc.conf \
    && sed -i -e 's/#rc_log_path=".*"/rc_log_path="\/rc.log"/g' /etc/rc.conf 

COPY root/ /
RUN for INIT in udev-trigger X hwdrivers modules dmesg sysfs devfs networking crond; do rc-update add "$INIT" sysinit; done
RUN for INIT in chronyd loadkmap rsyslog dropbear networking; do rc-update add "$INIT" boot; done
