FROM gcr.io/deeplearning-platform-release/base-cu110

ARG APP_HOME="/Repositories"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y \
    build-essential \
    bzip2 \
    curl \
    gcc \
    ffmpeg \
    libfreetype6-dev \
    libhdf5-serial-dev \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libzmq3-dev \
    pkg-config \
    rsync \
    software-properties-common \
    ssh \
    unzip \
    vim \
    python3-pip \
    wget && \
    apt-get clean

COPY requirements.txt /tmp/
WORKDIR /tmp/
RUN pip install -r requirements.txt

# COPY <repo_dir> <target location within Docker container>
COPY . ${APP_HOME}
WORKDIR ${APP_HOME}

EXPOSE 5000

CMD gunicorn main:app -w 1 -b :5000 -k uvicorn.workers.UvicornWorker