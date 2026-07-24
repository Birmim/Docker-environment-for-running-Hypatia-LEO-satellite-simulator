
# Hypatia (LEO Satellite Network Simulator) — Docker Environment

Reproducible environment to run [Hypatia](https://github.com/snkas/hypatia),
a LEO satellite mega-constellation simulation framework (ns-3 + Python) that
originally requires Ubuntu 18.04 and Python 3.7, that are versions incompatible with
modern Linux distributions.

## How to use

```bash
docker compose run hypatia
```

This builds the image (first run only — probably takes more than 20 minutes,
since it compiles ns-3 from source). It then opens a terminal inside the
environment, with a persistent folder at `./hypatia-workspace`, mounted as a
volume so it survives across different container runs.

## How to run step by step

### 1. Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running.
- [Git](https://git-scm.com/downloads) installed.

### 2. Clone this repository
```bash
git clone https://github.com/Birmim/Docker-environment-for-running-Hypatia-LEO-satellite-simulator.git
cd Docker-environment-for-running-Hypatia-LEO-satellite-simulator
```

### 3. Build and start the environment
```bash
docker compose run hypatia
```
- First run: builds the image from the `Dockerfile` (Ubuntu 18.04 + Python 3.7
  + ns-3 compilation), then drops you into a bash terminal inside the container.
- The prompt will look like `root@<container-id>:/root/hypatia#` — you are now
  inside the Hypatia environment.

### 4. Verify the installation (optional)
**note:** It was already executed as part of the Dockerfile build to verify that everything is working correctly. Running it again is optional, as it can take a long time to complete.
\
Inside the container:
```bash
bash hypatia_run_tests.sh
```
This runs the official Hypatia test suite. All tests should report `PASS`,
ending with `Hypatia tests were run and passed.`

### 5. Working with persistent files
Anything you want to keep between runs (simulation outputs, custom scripts,
generated visualizations) should be saved inside `/root/hypatia/workspace`
while inside the container — this folder is mirrored to `./hypatia-workspace`
on your host machine, and will still be there even after the container stops.

Example:
```bash
cd /root/hypatia/workspace
echo "test" > file.txt
```
Check `./hypatia-workspace/file.txt` on your host machine, it should be there.

### 6. Exiting and coming back later
- To leave the container: type `exit`.
- To start a **new** session later: run `docker compose run hypatia` again.
  This creates a fresh container each time (nothing installed manually inside
  the container persists, only what you saved in `/root/hypatia/workspace`).
- If you want to reuse the *same* stopped container instead of creating a new
  one: `docker compose start hypatia` followed by `docker compose exec hypatia bash`.

## Solved Problems

Running the official Hypatia install script against modern tooling surfaced
5 version incompatibilities, each fixed in the Dockerfile:

| Problem | Cause | Fix |
|---|---|---|
| `pip` fails on `astropy` (`ModuleNotFoundError: extension_helpers`) | Ubuntu 18.04's old `pip` doesn't support PEP 517/518 | Reinstall pip via `get-pip.py` |
| `cartopy` requires GEOS 3.7.2+ | Ubuntu 18.04 only ships GEOS 3.6.2 | Pin `cartopy==0.18.0` |
| `ImportError: cannot import name lgeos` | Shapely 2.0+ removed the interface used by older cartopy | Pin `shapely<2.0` |
| `unzip: command not found` | Not included in the minimal base image | Added to `apt-get install` |
| `screen: not found` | `exputilpy` uses screen to manage simulation runs | Added to `apt-get install` |

## Stack
Ubuntu 18.04 · Python 3.7 · ns-3 · Docker Compose