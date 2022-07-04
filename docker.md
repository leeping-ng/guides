# Docker Quick Reference

This Docker quick reference guide is a compilation of useful commands and lessons learnt from my experiences with Docker at work.

## Table of Contents
- [Creating a Dockerfile](#creating-a-dockerfile)
- [Common Commands](#common-commands)
- [Troubleshooting](#troubleshooting)
- [Receiving Traffic](#receiving-traffic)

## Creating a Dockerfile

For reference, see example of a [Dockerfile](Dockerfile) used for a deep learning application.

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

3. To run the container:
    ```
    # General command
    >> docker container run -d -it --name <container name> <name:tag>

    # Example
    >> docker container run -d -it --name yolox-movenet yolox-movenet:latest
    ```
    - If you exclude `-d`, you'll be able to see the output of the container in terminal.
    - `-p` (publish) flag can be added to publish a port. More on this in the [Receiving Traffic](#receiving-traffic) section.
        ```
        -p <host port>:<container port>
        ```
    - `-v` (volume) flag can be added to attach a persistent volume.
        ```
        -v <path of persistent vol>:/<name to call this persistent vol>
        ```

4. To check that the container is indeed running:
    ```
    >> docker container ls
    CONTAINER ID   IMAGE                  COMMAND                  CREATED         STATUS         PORTS      NAMES
    15a536cea7d8   yolox-movenet:latest   "/entrypoint.sh /run…"   2 minutes ago   Up 2 minutes   8080/tcp  yolox-movenet
    ```
    If nothing appears, add the `-a` flag, which includes stopped containers. It is very likely that the container has stopped running due to a bug.

5. To stop any container:
    ```
    >> docker stop <CONTAINER ID>
    ```
    Then:
    ```
    >> docker system prune
    ```
    Which will remove stopped containers and images.

6. Lastly, to remove any images (after container has been stopped):
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
