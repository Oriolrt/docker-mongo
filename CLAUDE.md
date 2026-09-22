# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repo builds a custom Docker image (`oriolrt/mongo`) on top of the official `mongo:7.0` image. It adds an SSH server and a Linux user `student`/`student` so the container can be used as a remote, SSH-accessible MongoDB server (e.g. for teaching/lab environments).

## Architecture

- [Dockerfile](Dockerfile) — builds from `mongo:7.0`, installs `openssh-server`, `sudo`, `vim`, `numactl`, `apg`, runs [createUser.sh](createUser.sh) at build time to create the `student` user, prepares `/data/configdb` and `/home/student/scripts`, exposes ports `27017` (Mongo) and `22` (SSH), and sets [entrypoint.sh](entrypoint.sh) as the container entrypoint.
- [createUser.sh](createUser.sh) — creates/updates the `student` Linux user so its UID/GID match the host's, via the `HOST_UID`/`HOST_GID` env vars (defaults `1000`/`999`). This lets bind-mounted volumes (`/data/db`, `/data/configdb`, `/home/student/scripts`) keep correct host-side ownership. It runs both at image build time (with defaults) and again at container start (via `entrypoint.sh`) so a container started with `-e HOST_UID=... -e HOST_GID=...` gets the right ownership at runtime.
- [entrypoint.sh](entrypoint.sh) — container entrypoint. Re-runs `createUser.sh`, starts the `ssh` service, then execs `mongod` bound to all interfaces with a fixed 1GB WiredTiger cache. Note: `mongod` is currently launched as the `mongodb` OS user, not `student` — keep this in mind when changing user/permission logic, since `createUser.sh` only manages the `student` account.

## Building and running

Build the image:
```
docker build -t oriolrt/mongo .
```

Run (Mongo port only):
```
docker run -dti -p 55117:27017 --name mongo-1 oriolrt/mongo
```

Run with SSH access enabled:
```
docker run -dti -p 55117:27017 -p 55122:22 --name mongo-1 oriolrt/mongo
```

Run with host-owned volumes and matching host UID/GID (recommended for persistent data):
```
mkdir -p $HOME/docker_volumes/mongo/scripts $HOME/docker_volumes/mongo/data $HOME/docker_volumes/mongo/configdb
docker run -dti \
  -e HOST_UID=$(id -u $USER) \
  -e HOST_GID=$(id -g $USER) \
  -p 55117:27017 \
  -p 55122:22 \
  -v $HOME/docker_volumes/mongo/scripts:/home/student/scripts \
  -v $HOME/docker_volumes/mongo/data:/data/db \
  -v $HOME/docker_volumes/mongo/configdb:/data/configdb \
  --name mongo --hostname mongo \
  oriolrt/mongo
```

Connect via SSH (student/student):
```
ssh -p 55122 student@localhost
```

## Notes for changes

- There are no automated tests or CI in this repo; validate changes by building the image and running the container (check `docker logs`, SSH in, and confirm `mongod` is listening on 27017).
- Shell scripts mix Catalan comments with English identifiers — follow the existing convention when editing them.
