# A Data Science Project Template for Docker
`pydockerize` is a tool for creating and distributing dockerized python projects.  The main focus of its design
has been to quickly get up and running with a full complement of data-science tools ready for use.  **It is still a work in progress.** 
You can think of it as being a take on [cookiecutter](https://cookiecutter.readthedocs.io/en/1.7.2/), but for docker containers.

`pydockerize` is a small, pure-python package with only two dependencies,
[pyyaml](https://github.com/yaml/pyyaml), and [click](https://palletsprojects.com/p/click/).  Installation will give put
a few commands in your bash path that all start with `pd.`  You can use bash completion to see these commands by simply
typing `pd.[tab]`.

The tool you will most frequenly use is `pd.initialize`.  This tool was inspired by the way Django allows you to create projects, and the workflow is very similar.

* You use `pd.initialize` to create a project directory that plays nicely with `pydockerize`.
* You edit the
[environment.yml](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html) in the project directory to specify what packages you want installed into your python environment.
* You edit the `docker-compose.yml` file to specify what services you want. (Defaults to shell and notebook)
* You check all the files currently in the directory into your version control system.
* You build your python env in the container
* You run your project

# Quick Start
## Install
```bash
pip install pydockerize
```

# Create a project
Here are the stpes for creating a project in a directory named `myproject`.  this directory will contain an environment file for specifying
the python packages you want to use, and a docker-compose file for specifying what services you want to run.  You 
will also see a couple default commands in the directory named `pd.run_notebook` and `pd.run_shell`.  Thes will do
what their names imply and run either a jupyter notebook or bash shell in a container.
```bash
pd.initialize -d myproject
```

# View/Modify package specifications
You don't have to make any changes, but the default is a pretty minimal data-science install.
```bash
cd myproject
vim environment.yml
```

# Build the Python environment in a container
All you need to do to build your python environment is run the provided build script in your project directory.
Depending on how complex your python environmnet is, this could take a while.
```bash
pd.build_env
```

If you ever update your environment.yml file with new packages, you don't need to completely rebuild
the environment.  You can just run `pd.update_env`.

# Run your project
You are now ready to create/run notebooks with your project environment.  The default directory
for the notebook will be your project directory which has been mounted into the container.

```bash
# Open Jupyter pointing to the project directory on your host
pd.run_note_book -p  # The -p is important.  It maps ports from container to host.
```
or

```bash
# Drop into a bash shell on the container
pd.run_shell. # without the -p, no port binding happens, so hosts can't connect to your services
```

Note that the following directories are also mounted into the container from your host computer.
* `/host -> your_host_home_directory`
* `/project -> your_project_directory`


# How it works
The `pd.build_env` does the following:
* Pulls a prebuilt ubuntu image from docker-hub.
* Creates a docker volume that will persist you python environment.
* Use miniconda to create you python environment and install requested packages into your container.

The `pd.run_*` commands simply run services described in the docker-compose.yml file.  You can edit
this file to add any additional services you desire.

