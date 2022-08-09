FROM debian:stable-slim

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

# Fix bad proxy issue
COPY system/99fixbadproxy /etc/apt/apt.conf.d/99fixbadproxy

WORKDIR /root

SHELL [ "/bin/bash", "-c" ]

# Clear previous sources
RUN rm /var/lib/apt/lists/* -vf \
  && apt-get -y update \
  && apt-get -y dist-upgrade \ 
  && apt-get -y install \
  apt-utils \
  python3 \
  python3-dev \
  python3-pip \
  python3-venv \
  supervisor \
  tzdata \
  curl \
  build-essential \
  lm-sensors \
  wireless-tools \
  smartmontools \
  iputils-ping \
  && mkdir -p /var/log/supervisor \
  && rm -rf .profile \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Fix timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Configure Supervisord and base env
COPY supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY bash/profile .profile

# Copy requirement files
COPY requirements.txt .
COPY requirements-optional.txt ./
RUN python3 -m venv env \
  && source env/bin/activate \
  && pip3 install --no-cache-dir -r requirements-optional.txt \
  && pip3 install --no-cache-dir glances[all] \
  && deactivate

# Copy glances config
COPY conf/glances.conf /root/conf/glances.conf

COPY run.sh /run.sh
RUN ["chmod", "+x", "/run.sh"]
CMD ["/run.sh"]