# Docker Quick Reference

This Docker quick reference guide is a compilation of useful commands and lessons learnt from my experiences with Docker at work.

## Table of Contents
- [Creating a Dockerfile](#creating-a-dockerfile)
- [Common Commands](#common-commands)
- [Troubleshooting](#troubleshooting)
- [Receiving Traffic](#receiving-traffic)
- [Optimising Docker Image Size](#optimising-docker-image-size)

## Creating a Dockerfile

For reference, see example of a [Dockerfile](dockerfiles/Dockerfile_1) used for a deep learning application.

**One tip to speed up Docker builds**: when Docker builds the image on your system, it checks for new changes from the previous build and executes the steps after the changes. The steps prior to the changes have been cached and Docker doesn't repeat them for the new build. 

In the Dockerfile below, if you make just one line of change to your application code, Docker has to re-install the dependencies from `requirements.txt` all over again, causing the build to take a long time.
```
COPY . ${APP_HOME}
WORKDIR ${APP_HOME}
RUN pip install -r requirements.txt
```

This Dockerfile, however, takes advantage of caching. As long as there are no changes to `requirements.txt`, if you change your application code and re-build the Docker image, it can do so in an instant!
```
COPY requirements.txt /tmp/
WORKDIR /tmp/
RUN pip install -r requirements.txt
COPY . ${APP_HOME}
WORKDIR ${APP_HOME}
```

## Common Commands

1. To build a Docker image from Dockerfile:
    ```
    # General command
    >> docker build -t <name:tag> -f <PATH to Dockerfile> <PATH to build>

    # Example
    >> docker build -t yolox-movenet:latest -f Dockerfile .
    ```

2. Once the build is complete, you'll be able to see the new image by:
    ```
    >> docker images
    REPOSITORY      TAG       IMAGE ID       CREATED          SIZE
    yolox-movenet   latest    0f9d43fc69e3   27 seconds ago   14.6GB
    ```

3. To push the image to a container registry:
    ```
    >> docker push <name:tag>
    ```

4. To run the container (note that `-it` should be the last argument):
    ```
    # General command
    >> docker run -d -it <name:tag>

    # With GPUs
    >> docker run --gpus all -d -it <name:tag>

    # Example
    >> docker run -d -it yolox-movenet:latest
    ```
    - If you exclude `-d`, you'll be able to see the output of the container in terminal.
    - `-p` (publish) flag can be added to publish a port. More on this in the [Receiving Traffic](#receiving-traffic) section.
        ```
        -p <host port>:<container port>
        ```
    - `-v` (volume) flag can be added to attach a persistent volume.
        ```
        -v <absolute path of persistent vol on host>:/<absolute path of persistent vol in Docker container>
        ```

5. To check that the container is indeed running:
    ```
    >> docker container ls
    CONTAINER ID   IMAGE                  COMMAND                  CREATED         STATUS         PORTS      NAMES
    15a536cea7d8   yolox-movenet:latest   "/entrypoint.sh /run…"   2 minutes ago   Up 2 minutes   8080/tcp  yolox-movenet
    ```
    If nothing appears, add the `-a` flag, which includes stopped containers. It is very likely that the container has stopped running due to a bug.

6. To stop any container:
    ```
    >> docker stop <CONTAINER ID>
    ```
    Then:
    ```
    >> docker system prune
    ```
    Which will remove stopped containers and images.

7. Lastly, to remove any images (after container has been stopped):
    ```
    >> docker image rm <IMAGE ID>
    ```

## Troubleshooting

1. If you encounter issues, it's always useful to retrieve logs from the container to help with debugging:
    ```
    docker logs <CONTAINER ID>
    ```

2. If logs don't provide enough clues, consider 'remoting' into the container using `docker exec`. You can use `vim` to quickly change code (without having to edit, build, push, and pull a new container which takes a long time), and try running again.
    ```
    # General command
    >> docker exec -it <CONTAINER ID> <CMD>

    # Example
    >> docker exec -it 15a536cea7d8 /bin/bash
    root@15a536cea7d8:/Repositories# python main.py
    ... your code runs nicely (hopefully)...

    # To get out of the docker container
    >> exit
    ```
    `-it` means "interactive", and you can interact with the code within your container.

## Receiving Traffic

This [StackOverflow post](https://stackoverflow.com/questions/22111060/what-is-the-difference-between-expose-and-publish-in-docker) gives a good explanation of the `EXPOSE` config in the Dockerfile versus the `-p` (publish) flag used when executing the command to run the container. `EXPOSE` just serves as documentation about which ports are intended to be published, but does not actually publish the port, so we’ll just focus on `-p` which is what really matters.

If your docker container needs to receive external traffic, the docker run command has to contain the `-p` flag with ports in this order: `-p <host port>:<container port>`. More details from [Docker documentation](https://docs.docker.com/config/containers/container-networking/).

Example:

- Your Flask app from within the container is listening on port 5000 → this is `<container port>`.
- You want to make a HTTP request to the host machine/VM on port 8000 (note that it can also be the same port number as `<container port>`) → This is `<host port>`.
- Thus for this example, you would run the container with the following command:
```
>> docker run -d -it -p 8000:5000 --name <container name> <name:tag>
```

## Optimising Docker Image Size

A large Docker image has many disadvantages, e.g. more time is required to push and pull images, container instances take more time to initialise, and failures may occur due to [long start-up times](https://cloud.google.com/blog/topics/developers-practitioners/3-ways-optimize-cloud-run-response-times). The table below shows how choosing a good base image and only installing required dependencies go a long way in reducing the image size. 

| Docker Image Size | Description | Link to Dockerfile |
|-------------------|-------------|--------------------|
| 17.1GB | Base image: Google Cloud's deep learning image with CUDA support | [Dockerfile_1](dockerfiles/Dockerfile_1) |
| 6.77GB | Base image: python:3.7 | [Dockerfile_2](dockerfiles/Dockerfile_2) |
| 3.87GB | Base image: python:3.7, removed Pytorch and Torchvision dependencies | [Dockerfile_3](dockerfiles/Dockerfile_3) |
| 3.50GB | Base image: python:3.7-slim, removed Pytorch and Torchvision dependencies | [Dockerfile_4](dockerfiles/Dockerfile_4) |

Note that while Alpine Linux is often used as a lightweight base image, but it is not recommended for Python with Docker for reasons listed in this [article](https://pythonspeed.com/articles/alpine-docker-python/).
