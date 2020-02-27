FROM registry.fedoraproject.org/fedora:31

ARG HASS_VERSION=0.106.0
ARG HASS_CLI_VERSION=0.8.0
ARG RELEASE=1

RUN dnf -y install \
      https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-31.noarch.rpm \
      https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-31.noarch.rpm
RUN rpm --import \
      /etc/pki/rpm-gpg/RPM-GPG-KEY-rpmfusion-free-fedora-31 \
      /etc/pki/rpm-gpg/RPM-GPG-KEY-rpmfusion-nonfree-fedora-31
RUN dnf -y update
RUN dnf -y install \
      android-tools \
      autoconf \
      autoconf \
      doxygen \
      ffmpeg \
      ffmpeg-devel \
      ffmpeg-devel \
      freetype \
      freetype-devel \
      gcc \
      gcc-c++ \
      git \
      glib2-devel \
      graphviz \
      hdf5 \
      hdf5-devel \
      hidapi \
      hidapi-devel \
      iputils \
      lcms-devel \
      lcms-libs \
      libffi \
      libffi-devel \
      libjpeg-turbo \
      libjpeg-turbo-devel \
      libpng \
      libpng-devel \
      libtiff \
      libtiff-devel \
      libwebp \
      libwebp-devel \
      libxml2 \
      libxml2-devel \
      libxslt \
      libxslt-devel \
      libyaml \
      libyaml-devel \
      lirc-devel \
      lirc-libs \
      make \
      make \
      nmap \
      openssl-devel \
      openssl-libs \
      postgresql-devel \
      postgresql-libs \
      python3 \
      python3-devel \
      python3-devel \
      redhat-rpm-config \
      redhat-rpm-config \
      rpm-build \
      systemd-devel \
      systemd-libs \
      tinyxml \
      tinyxml-devel \
      which

RUN python3 -m venv /opt/home-assistant
RUN /opt/home-assistant/bin/python -m pip install --upgrade pip setuptools wheel
#RUN /opt/home-assistant/bin/python -m pip install Cython
#RUN /opt/home-assistant/bin/python -m pip install six
#RUN /opt/home-assistant/bin/python -m pip install "PyDispatcher>=2.0.5"
#RUN /opt/home-assistant/bin/python -m pip install $REQUESTS

RUN /opt/home-assistant/bin/python -m pip install -r https://raw.githubusercontent.com/home-assistant/home-assistant/$HASS_VERSION/requirements_all.txt

RUN /opt/home-assistant/bin/python -m pip install "psycopg2"
RUN /opt/home-assistant/bin/python -m pip install "aiofiles==0.4.0"
RUN /opt/home-assistant/bin/python -m pip install "homeassistant==$HASS_VERSION"

RUN python3 -m venv /opt/home-assistant-cli
RUN /opt/home-assistant-cli/bin/python -m pip install --upgrade pip setuptools wheel
RUN /opt/home-assistant-cli/bin/python -m pip install "homeassistant-cli==$HASS_CLI_VERSION"

RUN rm -rf /root/.cache/pip

RUN mkdir /conf
RUN mkdir /logs

RUN ln -s /opt/home-assistant/bin/hass /usr/local/bin/hass
RUN ln -s /opt/home-assistant-cli/bin/hass-cli /usr/local/bin/hass-cli

RUN groupadd -g 6000 homeassistant
RUN useradd --uid 6000 --gid homeassistant --groups dialout --home-dir /opt/home-assistant --no-create-home --shell /usr/bin/bash homeassistant
RUN chown -R homeassistant:homeassistant /conf /logs

VOLUME /conf
VOLUME /logs

EXPOSE 8123
USER homeassistant
WORKDIR /opt/home-assistant
CMD [ "/opt/home-assistant/bin/hass", "--config", "/conf", "--log-file", "/logs/home-assistant.log", "--log-rotate-days", "30" ]
