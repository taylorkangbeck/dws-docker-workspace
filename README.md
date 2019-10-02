# Purpose

`dws` is a very simple tool for running containerized Python projects in the cloud. It stands for Docker WorkSpace.

With a simple command, you can continuously sync local project code to and from a custom docker container in an IDE-agnostic way.

(WIP - Sorry in advance for the stdout vomit!)

# Getting Started
## Requirements
* Need sudo permission on remote host
### Dependencies
On Local:
* OpenSSH >= 6.7
* docker, docker-compose
* [mutagen](mutagen.io)
Remote:
* OpenSSH >= 6.7
* dockerd

## Setup
1. After installing dependencies manually and ensuring they are on your PATH, execute `source setup.sh` in the root of this repo. It creates the alias `dws` in your shell and appends it to ~/.bashrc.

2. Add the following files to your project root:
   * Dockerfile
     * define base Docker image
   * docker-compose.yml
     * define container deployment settings

   Optional for python projects:
   * environment.yml (Conda)
     * define environment with project dependencies
     * activate it in Dockerfile

    See `dws-example-project` for examples.

3. Add any remote hosts to your `~/.ssh/config` with User and IdentityFile defined. Currently this tool doesn't support passing these values in as CLI args.


# Basic Usage
Run all `dws` commands from your project's root directory.
## Spin up docker container and attach shell

`dws attach`
   * This command spins up a docker container using your project's Dockerfile, starts a real-time background sync of your project code to the host, and connects to the container's shell.
   * When you exit the docker shell (ctrl-D), the container will continue running until you stop it. Note that project code will continue to sync as well.
   * You can only attach to one container/workspace at a time. You'll be automatically detached from the previous container if you attach to a new one.
   * Note that the first time you use `dws attach` will take a few minutes because Docker will have to build your image on your host. It will be cached for subsequent runs, so you won't have to wait again unless you make changes to Dockerfile (or environment.yml)
  
`dws attach <name-of-ssh-host>`
  * Does the same as `dws attach` but tunnels over SSH to a remote host's docker daemon.

`dws detach`
  * Stops syncing code to the previous container kills the SSH tunnel if it exists

`dws stop`
  * Detaches and stops the previous container.

## Using docker commands
The `dws` alias edits the value of the DOCKER_HOST environment variable. This allows you to use the regular `docker` and `docker-compose` CLIs for hands-on management of containers.


# dws-example-project
The example provided is targeted PyTorch deep learning projects.
## Docker Container
The default docker image is Ubuntu with Nvidia CUDA support and PyTorch. The Dockerfile is minimal, installing the template's dependencies and exposing ports, while delegating environment dependencies to Conda.

## Conda Environment
All dependencies should be managed with Conda via the environment.yml file. For most cases, this means that environment.yml will be the single source of truth for environment configuration.

## Cloud Deployment
TODO: automatically provision a host through a configured cloud provider

# Troubleshooting
* Won't connect to remote:
  * Is dockerd installed?
  * Was an instance of docker already running?
    * ssh into the remote host and run `sudo systemctl stop docker`
* ERROR: `Cannot kill container: unknown error after kill: runc did not terminate sucessfully: container_linux.go:388: signaling init process caused "permission denied" : unknown`
  * If docker was installed via snap (like on a remote ubuntu server), you may have conflicting AppArmor profiles.
    * SSH into the server and run `sudo aa-remove-unknown`  (from https://stackoverflow.com/q/47223280)
* ERROR: Couldn't connect to Docker daemon. You might need to start Docker for Mac.
  * If you're connecting to a remote server, this error is misleading. It's actually having trouble connecting to the ssh-tunneled docker.sock file. Try deleting it from /usr/local/var/dws/docker.sock and rerunning dws attach
* ERROR: Cannot start service: driver failed programming external connectivity on endpoint: Bind for 0.0.0.0:8888 failed: port is already allocated
  * You already have a container that is bound to that local port (eg 8888). You either need to change your docker-compose.yml or stop the other container manually. Make sure you stop containers before changing your docker-compose.yml
* Hangs after "Building <project>..."
  * If your docker daemon was already running before using dws, it may be listening to an unexpected socket.
    * You can check this with `ps aux | grep dockerd` and see whether dockerd was run with the --host/-H arg set. If so, kill the daemon and rerun dws attach