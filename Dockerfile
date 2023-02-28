#
# LinuxGSM Base Dockerfile
#
# https://github.com/GameServerManagers/LinuxGSM-Docker
#

FROM ubuntu:20.04

LABEL maintainer="LinuxGSM <me@danielgibbs.co.uk>"

ENV DEBIAN_FRONTEND noninteractive
ENV TERM=xterm
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install UTF-8 unicode
RUN echo "**** Install UTF-8 ****" \
    && apt-get update \
    && apt-get install -y locales apt-utils debconf-utils
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

## Upgrade Ubuntu
RUN echo "**** apt upgrade ****" \
    && apt-get update; \
    apt-get upgrade -y

## Install Base LinuxGSM Requirements
RUN echo "**** Install Base LinuxGSM Requirements ****" \
    && apt-get update \
    && apt-get install -y software-properties-common \
    && add-apt-repository multiverse \
    && apt-get update 
RUN apt-get install -y    bc
RUN apt-get install -y    binutils 
RUN apt-get install -y    bsdmainutils 
RUN apt-get install -y    bzip2 
RUN apt-get install -y    ca-certificates 
RUN apt-get install -y	  cron 
RUN apt-get install -y    cpio 
RUN apt-get install -y    curl 
RUN apt-get install -y    distro-info 
RUN apt-get install -y    file 
RUN apt-get install -y    gzip 
RUN apt-get install -y    hostname 
RUN apt-get install -y    jq 
# RUN apt-get install -y    lib32gcc1 
# RUN apt-get install -y    lib32stdc++6 
RUN apt-get install -y    netcat 
RUN apt-get install -y    openjdk-17-jre 
RUN apt-get install -y    python3 
RUN apt-get install -y    tar 
RUN apt-get install -y    tmux 
RUN apt-get install -y    unzip 
RUN apt-get install -y    util-linux 
RUN apt-get install -y    wget 
RUN apt-get install -y    xz-utils 
    # Docker Extras
RUN apt-get install -y    cron 
RUN apt-get install -y    iproute2 
RUN apt-get install -y    iputils-ping 
RUN apt-get install -y    nano 
RUN apt-get install -y    vim 
RUN apt-get install -y    sudo 
RUN apt-get install -y    tini

# Install SteamCMD
# RUN echo "**** Install SteamCMD ****" \
#     && echo steam steam/question select "I AGREE" | debconf-set-selections \
#     && echo steam steam/license note '' | debconf-set-selections \
#     && dpkg --add-architecture i386 \
#     && apt-get update -y \
#     && apt-get install -y --no-install-recommends libsdl2-2.0-0:i386 steamcmd \
#     && ln -s /usr/games/steamcmd /usr/bin/steamcmd

# Install NodeJS
RUN echo "**** Install NodeJS ****" \
    && curl -sL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get update && apt-get install -y nodejs

# Install GameDig https://docs.linuxgsm.com/requirements/gamedig
RUN echo "**** Install GameDig ****" \
    && npm install -g gamedig

# Install Cleanup
RUN echo "**** Cleanup ****"  \
    && apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

##Need use xterm for LinuxGSM##

ENV DEBIAN_FRONTEND noninteractive

ARG USERNAME=linuxgsm
ARG USER_UID=1000
ARG USER_GID=$USER_UID

## Add linuxgsm user
RUN echo "**** Add linuxgsm user ****" \
# Create the user
    && groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && chown $USERNAME:$USERNAME /home/$USERNAME

# Create /opt/linuxgsm
#RUN echo "**** Create /opt/linuxgsm ****" \
#    && mkdir -p /opt/linuxgsm \
#    && chown linuxgsm:linuxgsm /opt/linuxgsm
#

## Download linuxgsm.sh
RUN echo "**** Download linuxgsm.sh ****" \
    && set -ex \
    && wget -O linuxgsm.sh https://linuxgsm.sh \
    && chmod +x /linuxgsm.sh

WORKDIR /home/linuxgsm
ENV PATH=$PATH:/home/linuxgsm
USER linuxgsm

# Add LinuxGSM cronjobs
RUN (crontab -l 2>/dev/null; echo "*/5 * * * * /home/linuxgsm/*server monitor > /dev/null 2>&1") | crontab -
RUN (crontab -l 2>/dev/null; echo "*/30 * * * * /home/linuxgsm/*server update > /dev/null 2>&1") | crontab -
RUN (crontab -l 2>/dev/null; echo "0 1 * * 0 /home/linuxgsm/*server update-lgsm > /dev/null 2>&1") | crontab -

COPY entrypoint.sh /home/linuxgsm/entrypoint.sh

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "bash","./entrypoint.sh" ]
