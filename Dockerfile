FROM ubuntu:16.04
MAINTAINER Doro Wu <fcwu.tw@gmail.com> ZhiBo Fu <mobilefzb@163.com>

ENV DEBIAN_FRONTEND noninteractive

# RUN sed -i 's#http://archive.ubuntu.com/#http://tw.archive.ubuntu.com/#' /etc/apt/sources.list

# built-in packages
RUN apt-get update \
    && /bin/bash -c "echo 'deb http://download.openSUSE.org/repositories/home:/Horst3180/xUbuntu_16.04/ /' >> /etc/apt/sources.list.d/arc-theme.list" \
    && apt-get install -y apt-transport-https ca-certificates \
    && apt-get install -y --no-install-recommends software-properties-common curl \
    && curl -SL http://download.opensuse.org/repositories/home:Horst3180/xUbuntu_16.04/Release.key | apt-key add - \
    && add-apt-repository ppa:fcwu-tw/ppa \
    && dpkg --add-architecture i386 \
    && curl -SL https://dl.winehq.org/wine-builds/Release.key | apt-key add - \
    && apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/ \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
    && echo "deb http://download.mono-project.com/repo/ubuntu xenial main" | tee /etc/apt/sources.list.d/mono-official.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
        supervisor \
        openssh-server pwgen sudo vim-tiny \
        net-tools \
        lxde x11vnc xvfb \
        gtk2-engines-murrine ttf-ubuntu-font-family \
        firefox \
        fonts-wqy-microhei \
        language-pack-zh-hant language-pack-gnome-zh-hant firefox-locale-zh-hant \
        language-pack-zh-hans-base language-pack-gnome-zh-hans-base firefox-locale-zh-hans \
        nginx \
        python-pip python-dev build-essential \
        mesa-utils libgl1-mesa-dri \
        gnome-themes-standard gtk2-engines-pixbuf gtk2-engines-murrine pinta arc-theme \
        dbus-x11 x11-utils zenity cabextract \
    && apt-get install -y fcitx fcitx-config-gtk fcitx-sunpinyin fcitx-table-all fcitx-googlepinyin im-config \
    && apt-get install -y wget unzip \
    && apt-get install -y --install-recommends winehq-stable \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*


# tini for subreap                                   
ENV TINI_VERSION v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini
ADD image /
RUN wget -P /usr/bin https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
RUN chmod +x /usr/bin/winetricks
RUN echo '#!/bin/bash' >> /etc/profile.d/lang_set.sh
RUN echo 'export LANG="zh_CN.UTF-8"' >> /etc/profile.d/lang_set.sh
RUN echo 'export LC_ALL="zh_CN.UTF-8"' >> /etc/profile.d/lang_set.sh
RUN echo -e '#!/bin/bash\n/usr/bin/fcitx' >> /etc/profile.d/fcitx.sh
RUN chmod +x /etc/profile.d/fcitx.sh
RUN chmod +x /etc/profile.d/lang_set.sh
RUN im-switch -s fcitx -z default
RUN pip install --upgrade pip && pip install setuptools wheel && pip install -r /usr/lib/web/requirements.txt

EXPOSE 80
WORKDIR /root
ENV HOME=/home/ubuntu \
    SHELL=/bin/bash
ENTRYPOINT ["/startup.sh"]
