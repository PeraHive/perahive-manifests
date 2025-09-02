# perahive-manifests

This repository defines the **workspace composition** for the Perahive drone system using [vcstool](https://github.com/dirk-thomas/vcstool).

- **Core** → `perahive-core` repository, which contains multiple packages (shared by all projects).
- **Projects** → each project has one or more repos, usually one repo = one package.
- **Manifests** → `.repos` files that describe which repos to fetch for core, for a project, or for optional overlays.
- **Lockfiles** → pinned manifests with exact commit SHAs for reproducible builds.

---

## 📂 Repository layout

```
perahive-manifests/
├─ manifests/
│  ├─ perahive-core.repos        # core repo
│  ├─ project-falcon.repos       # sample project manifest
│  ├─ project-raven.repos        # another project
│  ├─ overlays/                  # optional extras
│  │   └─ sim.repos
│  └─ locks/                     # reproducible lockfiles
│      ├─ falcon.lock.repos
│      └─ raven.lock.repos
├─ scripts/
│  └─ bootstrap.sh               # helper script to create a workspace
├─ README.md
└─ .gitignore
```

---

## 🚀 Getting started (developers)

### 1. Install prerequisites

```bash
# Git
sudo apt-get update && sudo apt-get install -y git

# vcstool
sudo apt-get install -y python3-vcstool

# (if using ROS/colcon build system)
sudo apt-get install -y python3-colcon-common-extensions
```

### 2. Clone this repo

```bash
git clone git@github.com:your-org/perahive-manifests.git
cd perahive-manifests
```

### 3. Bootstrap a workspace

Use the provided script:

```bash
./scripts/bootstrap.sh falcon
```

This will:

- Create `~/perahive/ws/src`
- Import **core** repos
- Import **project-falcon** repos
- Update repos and generate a lockfile

Then build:

```bash
cd ~/perahive/ws
colcon build
```

### 4. Reproduce a locked workspace

If you want a **release-exact checkout** (e.g., CI, reproducible build):

```bash
mkdir -p ~/perahive/ws/src
vcs import ~/perahive/ws/src < manifests/locks/falcon.lock.repos
cd ~/perahive/ws
colcon build
```

---

## 📜 Manifests explained

- **Core**  
  `manifests/perahive-core.repos`

  ```yaml
  repositories:
    perahive-core:
      type: git
      url: git@github.com:your-org/perahive-core.git
      version: main
  ```

- **Project (example: Falcon)**  
  `manifests/project-falcon.repos`

  ```yaml
  repositories:
    perahive-falcon-nav:
      type: git
      url: git@github.com:your-org/perahive-falcon-nav.git
      version: main
    perahive-falcon-ui:
      type: git
      url: git@github.com:your-org/perahive-falcon-ui.git
      version: main
  ```

- **Overlay (optional)**  
  `manifests/overlays/sim.repos`

  ```yaml
  repositories:
    perahive-sim-tools:
      type: git
      url: git@github.com:your-org/perahive-sim-tools.git
      version: main
  ```

---

## 🔒 Lockfiles

To freeze your current workspace to **exact SHAs**:

```bash
vcs export --exact ~/perahive/ws/src > manifests/locks/falcon.lock.repos
git add manifests/locks/falcon.lock.repos
git commit -m "Update falcon lockfile"
git push
```

Later, reproduce that exact state:

```bash
vcs import ~/perahive/ws/src < manifests/locks/falcon.lock.repos
```

---

## 🛠 Common vcstool commands

```bash
# Import repos from a .repos file
vcs import ws/src < manifests/perahive-core.repos

# Update all repos
vcs pull ws/src

# Show status across repos
vcs status ws/src

# Show diff across repos
vcs diff ws/src

# Run a git command across repos
vcs custom --args git rev-parse --abbrev-ref HEAD ws/src

# Export current workspace (branches)
vcs export ws/src > ws/current.repos

# Export current workspace (exact SHAs)
vcs export --exact ws/src > ws/current.lock.repos
```

---

## 🔄 Workflow summary

1. Developer clones `perahive-manifests`.
2. Runs `./scripts/bootstrap.sh <project>`.
3. Builds workspace with `colcon build`.
4. When stable, team creates/updates a lockfile.
5. CI uses the lockfile for reproducible builds.

---

## 🤖 CI example (GitHub Actions)

```yaml
name: Build
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install tools
        run: |
          sudo apt-get update
          sudo apt-get install -y python3-vcstool python3-colcon-common-extensions

      - name: Prepare workspace
        run: mkdir -p ws/src

      - name: Import exact workspace (falcon)
        run: vcs import ws/src < manifests/locks/falcon.lock.repos

      - name: Build
        run: cd ws && colcon build
```

---

## ❓ Troubleshooting

- **Branch change in manifest doesn’t reflect**  
  vcstool does not overwrite existing repos. Either:
  - `git checkout <branch>` manually inside the repo, or
  - delete the repo folder and re-import.

- **Duplicate repo names**  
  Ensure each `repositories:` key (or `local-name`) is unique.

- **Detached HEAD when using lockfiles**  
  Normal — repos are pinned to SHAs. You can still build.

- **Want a fork or feature branch**  
  Add an overlay `.repos` file pointing the repo to your fork, then import it last.

---

## 📖 References

- vcstool: [https://github.com/dirk-thomas/vcstool](https://github.com/dirk-thomas/vcstool)
- colcon: [https://colcon.readthedocs.io](https://colcon.readthedocs.io)

## Create Pacakges
```
cd ~/perahive/ws/src/perahive-core
```

```
ros2 pkg create perahive_pkgname \
  --build-type ament_python \
  --dependencies rclpy std_msgs
```

```
cd ~/perahive/ws
colcon build --packages-select perahive_pkgname
source install/setup.bash
```

```
ros2 launch perahive_mavros esp-now.launch.py
```

