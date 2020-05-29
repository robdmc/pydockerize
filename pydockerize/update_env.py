import os
import subprocess
import contextlib
import sys

import click


class EnvBuilder:
    REQUIRED_PROJECT_FILES = [
        'environment.yml',
        'docker-compose.yml'
    ]

    def __init__(self, project_path):
        self.project_path = self.ensure_files(project_path)
        self.script_stack_index = 0

    def ensure_files(self, project_path):
        project_path = os.path.realpath(os.path.expanduser(project_path))
        full_paths = [os.path.join(project_path, f) for f in self.REQUIRED_PROJECT_FILES]
        for full_path in full_paths:
            if not os.path.isfile(full_path):
                raise RuntimeError(f'\nRequired file not found: {full_path}\n')
        return project_path

    @contextlib.contextmanager
    def working_script(self, commands):
        if not hasattr(self, 'script_stack_index'):
            self.script_stack_index = 0
        self.script_stack_index += 1
        file_name = os.path.join(self.project_path, f'_pydockerize_working_script{self.script_stack_index}.sh')
        with open(file_name, 'w') as buff:
            buff.write('\n'.join(commands))
        try:
            yield file_name
        finally:
            os.unlink(file_name)
            self.script_stack_index -= 1

    def rebuild_volumes(self):
        print('========================================= (Re)building volumes', file=sys.stderr)
        commands = [
            'docker volume rm pydockerize_opt 2>/dev/null || true',
            'docker volume create pydockerize_opt',
            'docker volume rm pydockerize_ssh 2>/dev/null || true',
            'docker volume create pydockerize_ssh',
        ]

        with self.working_script(commands) as script_file:
            subprocess.check_call(['bash', script_file], cwd=self.project_path)

    def install_conda(self):
        self.rebuild_volumes()
        print('========================================= Installing Conda', file=sys.stderr)
        url = 'https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh' 
        container_commands = [
            f'wget --quiet {url} -O ~/miniconda.sh && \\',
            '/bin/bash ~/miniconda.sh -b -p /opt/conda && \\',
            'rm ~/miniconda.sh && \\',
            'ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh',
        ]

        with self.working_script(container_commands) as container_script_file:
            container_script_file = os.path.basename(container_script_file)
            container_script_file = os.path.join('/project', container_script_file)
            compose_file = os.path.join(self.project_path, 'docker-compose.yml')
            host_commands = [
                f'docker-compose -f {compose_file} down || true',
                f'docker-compose -f {compose_file} run --rm shell bash {container_script_file}',
            ]
            with self.working_script(host_commands) as host_script_file:
                subprocess.check_call(['bash', host_script_file])

    def update_env(self):
        print('========================================= Building Env', file=sys.stderr)
        container_commands = [
            '/opt/conda/bin/conda update -y -n base -c defaults conda',
            '/opt/conda/bin/conda env update  --file /project/environment.yml',
        ]
        with self.working_script(container_commands) as container_script_file:
            container_script_file = os.path.basename(container_script_file)
            container_script_file = os.path.join('/project', container_script_file)
            compose_file = os.path.join(self.project_path, 'docker-compose.yml')
            host_commands = [
                f'docker-compose -f {compose_file} down || true',
                f'docker-compose -f {compose_file} run --rm shell bash {container_script_file}',
            ]
            with self.working_script(host_commands) as host_script_file:
                subprocess.check_call(['bash', host_script_file])


def run(directory, with_build):
    directory = os.path.realpath(os.path.expanduser(directory))
    activate_script = os.path.join(directory, 'bash_hooks', 'activate_env.sh')
    if not os.path.isfile(activate_script):
        msg = 'No activation script found.  Did you initialize your project?'
        print(msg, sys.stderr)
        exit(1)

    builder = EnvBuilder(directory)
    if with_build:
        builder.install_conda()
    builder.update_env()

@click.command()
@click.option('-d', '--directory', required=True, help='The initialized project directory')
def build(directory):
    run(directory, with_build=True)

@click.command()
@click.option('-d', '--directory', required=True, help='The initialized project directory')
def update(directory):
    run(directory, with_build=False)











# # Install conda into the container
# docker-compose -f $compose_file down || true
# docker-compose -f $compose_file run --rm shell bash /docker/initialize/container_scripts/install_conda.sh
# docker-compose -f $compose_file run --rm shell bash /docker/initialize/container_scripts/build_environment.sh

# # Initialize ssh
# docker-compose -f $compose_file down || true
# docker-compose -f $compose_file run --rm shell ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa

# if __name__ == '__main__':
#     builder = EnvBuilder('/tmp/myproj')
#     builder.install_conda()
#     builder.update_env()
#     # builder.make_activation_hook()
