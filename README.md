# Purpose

`dws` is a simple tool for developing in Docker containers, both local and remote.

# Getting Started
## Dependencies
On Local:
* OpenSSH >= 6.7
* docker, docker-compose
* yq
  * `brew install yq`
* [mutagen](https://mutagen.io)

On Remote:
* OpenSSH >= 6.7
* dockerd

## Other Requirements
On Remote:
* Need sudo permission

## Installation
1. Clone the repo
2. Ensure all dependencies above are installed correctly and are on your PATH
3. Execute `bash setup.sh` in the root of the repo (It creates the alias `dws` in your shell and appends it to ~/.bashrc).
4. Add any remote hosts you intend to access to `~/.ssh/config` with User and IdentityFile defined (This tool doesn't support manually passing in ssh arguments yet).

## Project Setup
*See `dws-example-project` for examples.*
The example provided is targeted for PyTorch deep learning projects.

Add the following files to your project root:
* Dockerfile
  * defines base Docker image
* docker-compose.yml
  * defines container deployment settings
* mutagen.yml
  * defines Mutagen file syncing configutation

Optional for python projects:
* environment.yml (Conda)
  * define environment with project dependencies
  * activate it in Dockerfile

# Usage
Run all `dws` commands from your project's root directory, where your `docker-compose.yml` lives.

## Commands:
`dws attach [ssh_hostname]`
* Connects to the Docker daemon on `ssh_hostname` if provided, otherwise uses your local Docker installation
* If the Docker daemon doesn't have an image for this project yet, it builds one
* If a container isn't already running, it starts one
* Attaches terminal to running container
* Begins continuously syncing your project directory to the container
* *On terminal exit (Ctrl-d):*
  * Stops syncing your project directory
  * Disconnects from remote docker daemon
  * Note: Container will continue running

`dws stop [ssh_hostname]`
* Stops the associated container

`dws rebuild [ssh_hostname]`
* Stops container and forces a rebuild of the Docker image before attaching normally

`dws detach`
* Forces syncing to stop and ssh tunnels to close. Only really needed if you end up in a weird state.


# Troubleshooting
* First try running `dws detach` to refresh your project's state.
* Won't connect to remote:
  * Is dockerd installed?
  * Was an instance of docker already running?
    * ssh into the remote host and run `sudo systemctl stop docker`
* `ERROR: Cannot kill container: unknown error after kill: runc did not terminate sucessfully: container_linux.go:388: signaling init process caused "permission denied" : unknown`
  * If docker was installed via snap (like on a remote ubuntu server), you may have conflicting AppArmor profiles.
    * SSH into the server and run `sudo aa-remove-unknown`  (from https://stackoverflow.com/q/47223280)
* `ERROR: Cannot start service: driver failed programming external connectivity on endpoint: Bind for 0.0.0.0:8888 failed: port is already allocated`
  * You already have a container that is bound to that local port (eg 8888). You either need to change your docker-compose.yml or stop the other container manually. Make sure you stop containers before changing your docker-compose.yml
* Hangs after "Building <project>..."
  * It may just be taking a while to upload large files. How big is your Docker build context? Do you have any large files? They could be in a hidden folder like .git
  * Delete unnecessary files, or add them to a `.dockerignore` in the project root
