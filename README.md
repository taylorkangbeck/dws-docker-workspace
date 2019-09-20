# Purpose
A template for ML research projects that ensures isolation, portability, and ease of development.

# Getting Started
## Requirements
* Need sudo permission on remote host
### Dependencies
Local:
* OpenSSH >= 6.7
* docker, docker-compose
Remote:
* OpenSSH >= 6.7
* dockerd

  

## Conventions
TODO describe volume structure, startup scripts, etc

# Components
## Docker Container
The default docker image is Ubuntu with Nvidia CUDA support and PyTorch. The Dockerfile is minimal, installing the template's dependencies and exposing ports, while delegating environment dependencies to Conda.

## Conda Environment
All dependencies should be managed with Conda via the environment.yml file. For most cases, this means that environment.yml will be the single source of truth for environment configuration.

## Code Syncing with Mutagen
To facilitate development, code needs to be synced from the local development environment to the remote server.

## Cloud Deployment


# Troubleshooting
Won't connect to remote:
* is dockerd installed?
* was an instance of docker already running?
  * ssh into the remote host and run `sudo systemctl stop docker`

# Additional tools
* https://github.com/chdoig/conda-auto-env (maybe)


# Design Discussion
* should I check to see if dependencies have changed, and rebuild the image if so?
  * the only alternative is to dynamically download all deps at container start
    * deps probably won't change that much, and since Dockerfile is minimal and Docker caches steps, it shouldn't take too long
  * can also do for startup script if don't want to manage that in the syncing
  * what do I do if dependencies are updated and container is running?
    * have a script the bounces it after a warning?
  * answer: yes. see if building every time you deploy is ok thanks to caching 
* 

# To-do
test/verify: 
* local
    [x] base docker image builds and installs conda deps
    [x] docker-compose works
    [ ] mutagen sync works
* remote:
    [x] start_remote script works
    [ ] mutagen sync works
    

other:
[x] define docker-compose.yml with volumes
[x] enable startup script
[ ] user docker-machine or similar to spin up new cloud instance

