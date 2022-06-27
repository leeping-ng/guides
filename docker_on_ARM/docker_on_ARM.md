# Docker on ARM CPUs

This guide was written in early 2020, and there may have been updates to Docker and available ARM packages since then.

## 1. Background on RPi

- The main reason why using Docker is different on a Raspberry Pi is because it uses ARM processors instead of x86_64/AMD64 processors which are used on typical computers.
- Most Raspberry Pi versions (except for Model 1) have ARM processors that can run both 32-bit and 64-bit OS
- However, for backward compatibility, most versions of OS e.g. Raspbian are still 32-bit.
- The table below shows the options for the `platform` argument to later choose from (not exhaustive) when building a Docker image:

| Processor/OS type | --platform |
| --- | --- | 
| x86_64/AMD64 processor (typical computer) | linux/amd64 |
| 32-bit OS (e.g. 32-bit Raspbian on RPi 3) | linux/arm/v7 |
| 64-bit OS (e.g. 64-bit Ubuntu Mate on RPi 4) | linux/arm64 |

## 2. Installing Docker on RPi

- Follow this [guide](https://withblue.ink/2019/07/13/yes-you-can-run-docker-on-raspbian.html) to intall Docker.
- Once done, allow Docker to be used as a non-root user by following these [steps](https://docs.docker.com/engine/install/linux-postinstall/).

## 3. Building Docker Images for RPi

- Follow the following sections of this [guide](https://www.docker.com/blog/getting-started-with-docker-for-arm-on-linux/) to:
  - Install buildx for multi-architecture image builds
  - Register Arm executables to run on x64 machines (note that you'll have to repeat this step every time you reboot/can add to startup script if you use buildx often)
  - Create a multi-architecture build instance
- You may be used to the conventional way of `docker build` where the built container image is exported to `docker images`, and you can verify it's creation with the `docker images` command. I would usually do this first, then use `docker save` to save the image.
- Unfortunately, when using `buildx`, it's different, and most guides like [this one](https://www.docker.com/blog/multi-arch-images/) push the built Docker image to a repository like Dockerhub, using a command like this:
  ```
  docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t <repo> --push .
  ```
- If you'd like to save a Docker image, you can use the following command:
  ```
  docker buildx build --platform linux/arm/v7 -t <container_name> -f <dockerfile> . --load
  ```
  - The caveat is that this only works for a single platform build, see [here](https://github.com/docker/buildx#-o---outputpath-typetypekeyvalue).
 - When building from a Dockerfile, remember that the base image from the Dockerfile has to work on ARM architectures, such as [these](https://pythonspeed.com/articles/base-image-python-docker-images/) if you cross-check on Dockerhub.
   - Unfortunately, miniconda is not available as a base image for ARM, thus you'll have to install packages from requirements.txt instead of conda.yml. I've encountered several issues while trying to do this, particularly with *pandas* and *numpy*.
   - Here is a [Dockerfile](docker/Dockerfile) that can compile successfully on *linux/arm/v7*. However, because we're using apt-install for some packages like *pandas* and *numpy* (because pip didn't work), the versions are pretty outdated and they may (and have) lead to errors when running the container. 


## 4. Useful Docker Commands

See the [Docker Quick Reference Guide](../docker.md) for the most common commands. I do not use the following commands as frequently, but they are required here.

1. To save the image into a *.tar* file:
    ```
    docker save -o <imagename.tar> <name:tag>
    ```
    A *.tar* file will be saved to PATH, which you can then use to create a Docker container elsewhere.

4. To load the image from the *.tar* file:
    ```
    docker load -i <imagename.tar>
    ```
    Note that saving + loading is for images, while exporting + importing is for containers, see [this](https://tuhrig.de/difference-between-save-and-export-in-docker/).


 ## 5. WIP - Multi-Platform Build without using `push`
 
  - Still exploring other [options](https://github.com/docker/buildx#-o---outputpath-typetypekeyvalue) for multi platform build, including:
    - Using `docker` driver instead of `docker-container` driver, which may allow the [`image`](https://github.com/docker/buildx#image) option to be used. However, it seems that the `default` builder which uses the `docker` driver doesn't support ARM platforms... to be verified again.
    - `--output type=oci` following this [thread](https://github.com/docker/buildx/issues/166) created a container instead of an image ([export vs save](https://tuhrig.de/difference-between-save-and-export-in-docker/)). I had to use `docker import` instead of `docker load` the .tar file
    
