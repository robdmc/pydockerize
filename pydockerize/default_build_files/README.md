# Files to build your own base image
This directory contains the files that are used to build
the default docker image.  You can customize them to your liking here.

Make sure you update the default docker image name using `dp.config`
This will ensure that any project templates you make will use your
custom-build image.

## Directory Structure
```
my_build_files/
├── Dockerfile
├── README.md
├── build.sh
├── files
│   ├── .bash_profile
│   ├── .bashrc
│   ├── .inputrc
│   └── .vimrc
└── push.sh
```

# Commands
Run `build.sh` to build your custom docker image with your edited dockerfile
Optionally run `push.sh` to push the image to your docker account
