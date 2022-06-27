FROM ubuntu:18.04
RUN apt-get update && apt-get install \
  -y --no-install-recommends python3 python3-pip python3-setuptools libgomp1 \ 
  python3-pandas python3-numpy python3-sklearn python3-sklearn-lib 

# Setup working directory
COPY . /app
# Note that any Docker command executing from this point onward is from "/app" directory
WORKDIR /app

RUN pip3 install Cython
RUN pip3 install -r requirements.txt

# Run server
EXPOSE 80
ENTRYPOINT [ "python3" ]
CMD [ "app.py" ]

# PREVIOUS ISSUES BELOW

# 1. Stuck at Geographic area
# FROM ubuntu:18.04
# RUN apt-get update && apt-get install \
#   -y python3 python3-pip python3-setuptools libgomp1 python3-pandas python3-numpy

# 2. https://stackoverflow.com/questions/55891319/problem-building-docker-with-numpy-and-pandas-over-arm64
#The following packages have unmet dependencies:
#8 5.008  python3-pandas : Depends: python3-pandas-lib (>= 0.19.2-5.1) but it is not installable
#8 5.008                   Recommends: python3-numexpr but it is not going to be installed
#8 5.008                   Recommends: python3-tables but it is not going to be installed
#8 5.008                   Recommends: python3-bs4 but it is not going to be installed
#8 5.008                   Recommends: python3-html5lib but it is not going to be installed
#8 5.009                   Recommends: python3-lxml but it is not going to be installed
#8 5.025 E: Unable to correct problems, you have held broken packages.
# FROM debian:stretch-slim
# RUN apt-get update && apt-get -y dist-upgrade
# RUN apt-get -y install build-essential libssl-dev libffi-dev python3.5 libblas3 libc6 liblapack3 gcc python3-dev python3-pip cython3
# RUN apt-get -y install python3-numpy python3-sklearn
# RUN apt-get -y install python3-pandas

# 3. condaforge/linux-anvil-armv7l:latest
# https://hub.docker.com/r/condaforge/linux-anvil-armv7l/tags
#failed to solve: rpc error: code = Unknown desc = failed to load cache key: failed to do request: Head https://registry-1.docker.io/v2/condaforge/linux-anvil-armv7l/manifests/latest: dial tcp: lookup registry-1.docker.io on 192.168.1.254:53: read udp 172.17.0.2:39532->192.168.1.254:53: i/o timeout

# 4. derekmerck/conda:latest
# https://hub.docker.com/r/derekmerck/conda/tags
# failed to solve: rpc error: code = Unknown desc = failed to load cache key: failed to do request: Head https://registry-1.docker.io/v2/derekmerck/conda/manifests/latest: dial tcp: lookup registry-1.docker.io on 192.168.1.254:53: read udp 172.17.0.2:54886->192.168.1.254:53: i/o timeout

# 5. d3banjan/raspbian-armv7l-miniconda:kugu
# https://hub.docker.com/r/d3banjan/raspbian-armv7l-miniconda/tags
# same error as above

# 6. Built okay! without requirements.txt
# FROM ubuntu:18.04
# RUN apt-get update && apt-get install \
#   -y --no-install-recommends python3 python3-pip python3-setuptools libgomp1 python3-pandas python3-numpy

# 7. Failed at LightGBM
# Exception: Cannot install LightGBM in 32-bit Python, please use 64-bit Python instead.
# FROM ubuntu:18.04
# RUN apt-get update && apt-get install \
#   -y --no-install-recommends python3 python3-pip python3-setuptools libgomp1 \ 
#   python3-pandas python3-numpy python3-sklearn python3-sklearn-lib 