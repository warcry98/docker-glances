FROM python:slim

# Install packages
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  python3-dev \
  curl \
  build-essential \
  lm-sensors \
  wireless-tools \
  smartmontools \
  iputils-ping && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Install packages for timezone and healthcheck
RUN apt-get install -y --no-install-recommends bash tzdata curl
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install the dependencies beforehand to make them cacheable
COPY requirements.txt .
RUN pip3 install --no-cache-dir --user -r requirements.txt

# Install additional packages
COPY requirements-optional.txt ./
RUN CASS_DRIVER_NO_CYTHON=1 pip3 install --no-cache-dir --user -r requirements-optional.txt

# Force install otherwise it could be cached without rerun
ARG CHANGING_ARG
RUN pip3 install --no-cache-dir --user glances[all]

# EXPOSE PORT (XMLRPC / WebUI)
EXPOSE 61209 61208

WORKDIR /glances
COPY conf/glances.conf .

# Define default command
CMD python3 -m glances -C /glances/conf/glances.conf $GLANCES_OPT