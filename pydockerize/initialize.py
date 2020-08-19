import glob
import os
import click
import shutil
import stat
import subprocess

import yaml

from pydockerize.config import Config


class Initializer:
    def __init__(self, project_dir, env_name=None):
        self.project_dir = os.path.realpath(os.path.expanduser(project_dir))
        if env_name is None:
            self.env_name = os.path.basename(self.project_dir)
        else:
            self.env_name = env_name

        self._set_path_attributes()

    def _set_path_attributes(self):
        self.subdir = os.path.join(self.project_dir, '_pydockerize_')
        self.hook_path = os.path.join(self.subdir, 'bash_hooks')
        self.container_file_path = os.path.join(self.subdir, 'env_build_scripts')

        # Set up information for the source of default files
        file_dir = os.path.realpath(__file__)
        base_dir = os.path.dirname(file_dir)
        source_path = os.path.join(base_dir, 'default_project_files', 'default')

        self.env_source = os.path.join(source_path, 'environment.yml')
        self.env_target = os.path.join(self.project_dir, os.path.basename(self.env_source))

        self.compose_source = os.path.join(source_path, 'docker-compose.yml')
        self.compose_target = os.path.join(self.project_dir, os.path.basename(self.compose_source))

        self.service_script_source = os.path.join(
            base_dir, 'default_project_files', 'service_template.sh')

    def make_required_directories(self):
        # Make sure the directories exist
        os.makedirs(self.hook_path, exist_ok=True)
        os.makedirs(self.container_file_path, exist_ok=True)

    def _render_single_template(self, source, target, context):
        shutil.copy(source, target)

        with open(target) as buff:
            contents = buff.read()
        contents = contents.format(**context)
        with open(target, 'w') as buff:
            buff.write(contents)

    def _get_env_name_from_file(self):
        with open(self.env_target) as buff:
            obj = yaml.load(buff, Loader=yaml.FullLoader)
        env_name = obj['name']
        return env_name

    def render_template_files(self):
        context = dict(
            image_name=Config().blob['image_name'],
            env_name=self.env_name
        )
        if os.path.isfile(self.env_target):
            self.env_name = self._get_env_name_from_file()
        else:
            self._render_single_template(self.env_source, self.env_target, context)

        if not os.path.isfile(self.compose_target):
            self._render_single_template(self.compose_source, self.compose_target, context)

    def _make_script(self, commands, file_name, executable=False):
        with open(file_name, 'w') as buff:
            buff.write('\n'.join(commands) + '\n')

        if executable:
            st = os.stat(file_name)
            os.chmod(file_name, st.st_mode | stat.S_IEXEC)

    def make_bash_hooks(self):
        commands = [f'conda activate {self.env_name}']
        file_name = os.path.join(self.hook_path, 'bash_hooks.sh')
        self._make_script(commands, file_name, executable=True)

    @property
    def opt_volume(self):
        return f'pydockerize_opt_{self.env_name}'

    @property
    def ssh_volume(self):
        return f'pydockerize_ssh_{self.env_name}'

    def _make_compose_script(self, compose_script, target_script, with_volume_rebuild=False):
        name_on_host = os.path.join(self.container_file_path, compose_script)
        name_on_container = os.path.join('/project', os.path.relpath(name_on_host, self.project_dir))
        compose_file = os.path.join(self.project_dir, 'docker-compose.yml')

        if with_volume_rebuild:
            commands = [
                '#! /usr/bin/env bash',
                f'docker volume rm {self.opt_volume} 2>/dev/null || true',
                f'docker volume create {self.opt_volume}',
                f'docker volume rm {self.ssh_volume} 2>/dev/null || true',
                f'docker volume create {self.ssh_volume}',
            ]
        else:
            commands = ['#! /usr/bin/env bash']

        commands.extend([
            f'docker-compose -f {compose_file} down 2>/dev/null || true',
            f'docker-compose -f {compose_file} run --rm shell bash {name_on_container}',
        ])

        file_name = os.path.join(self.project_dir, target_script)
        self._make_script(commands, file_name, executable=True)

    def make_uninstall_script(self):
        commands = [
            '#! /usr/bin/env bash',
            f'docker volume rm {self.opt_volume} 2>/dev/null || true',
            f'docker volume rm {self.ssh_volume} 2>/dev/null || true',
            f'docker network rm {os.path.basename(self.project_dir)}_default 2>/dev/null || true',
        ]
        file_name = os.path.join(self.project_dir, 'pd.uninstall_project')
        self._make_script(commands, file_name, executable=True)

    def make_build_env_script(self):
        self._make_compose_script('build_environment.sh', 'pd.build_env', with_volume_rebuild=True)

    def make_update_env_script(self):
        self._make_compose_script('update_environment.sh', 'pd.update_env')

    def make_build_env_for_container(self):
        url = 'https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh'
        commands = [
            'rm -rf /opt/conda 2>/dev/null || true',
            f'wget --quiet {url} -O ~/miniconda.sh && \\',
            '/bin/bash ~/miniconda.sh -b -p /opt/conda && \\',
            'rm ~/miniconda.sh && \\',
            'ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \\',
            '/opt/conda/bin/conda update -y -n base -c defaults conda && \\',
            '/opt/conda/bin/conda env update  --file /project/environment.yml',
        ]
        file_name = os.path.join(self.container_file_path, 'build_environment.sh')
        self._make_script(commands, file_name)

    def make_update_env_for_container(self):
        commands = [
            '/opt/conda/bin/conda update -n base -c defaults conda',
            '/opt/conda/bin/conda env update  --file /project/environment.yml',
        ]

        file_name = os.path.join(self.container_file_path, 'update_environment.sh')
        self._make_script(commands, file_name)

    def make_single_service_script(self, template, context):
        script = template.format(**context)
        service = context['service']
        file_name = os.path.join(self.project_dir, f'pd.run_{service}')
        with open(file_name, 'w') as buff:
            buff.write(script)
        st = os.stat(file_name)
        os.chmod(file_name, st.st_mode | stat.S_IEXEC)

    def make_service_scripts(self):
        glob_str = os.path.join(self.project_dir, 'pd.run_*')
        files = glob.glob(glob_str)
        for ff in files:
            os.unlink(ff)

        # cmd = f'rm {glob}'
        # subprocess.run(cmd, stderr=subprocess.PIPE)
        with open(self.service_script_source) as buff:
            template = buff.read()

        cmd = f'docker-compose -f {self.compose_target} config --services'
        proc = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
        services = proc.communicate()[0].decode('utf-8').split('\n')
        for service in [s for s in services if s]:
            context = dict(service=service)
            self.make_single_service_script(template, context)

    def initialize(self):
        # Sets up the required directory structure
        self.make_required_directories()

        # Renders default files if they are missing
        self.render_template_files()

        # Make the bash_hook that will activate conda env o
        # .bashrc run i
        self.make_bash_hooks()

        # Create scripts for building env
        # self.make_rebuild_volumes_script()
        self.make_build_env_script()
        self.make_build_env_for_container()

        # Create scrips for updating env
        self.make_update_env_script()
        self.make_update_env_for_container()

        # Create scripts for running services
        self.make_service_scripts()

        # Make a script for uninstalling
        self.make_uninstall_script()


@click.command()
@click.option('-d', '--directory', required=True, help='Prepare all files for building a project')
@click.option('-n', '--name', help='The env name (defaults to directory name. Overriden by name in env file')
def main(directory, name):
    project_dir = os.path.realpath(os.path.expanduser(directory))
    if name is None:
        name = os.path.basename(project_dir)

    init = Initializer(directory, env_name=name)
    init.initialize()


if __name__ == '__main__':
    main()
