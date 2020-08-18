#!/usr/bin/env python3
import glob
from fabric import Connection
from invoke import task

HOST        = 'ec2-13-229-58-15.ap-southeast-1.compute.amazonaws.com'
STORAGE     = '172.31.43.166'
USER        = 'ubuntu'
ROOT        = '/mnt/efs/ramen'
PROJECT_NAME= 'ramen'
TBPORT      =  6006
REMOTE      = '{user}@{host}:{root}'.format(user=USER, host=HOST, root=ROOT)
VENV        = 'pytorch_p36'
MODEL       = 'models'
OUTPUT      = 'output_tests'
LOGS        = 'logs'
DATA        = 'data'
DATASET_LOCATION = 'honours-datasets/dataset'
GIT_REPO = 'https://github.com/bhanukaManesha/ramen.git'

ALL = [
    'scripts',
    'preprocess',
    'models',
    'run_network.py',
    'dataset.py'
]

@task
def connect(ctx):
    ctx.conn = Connection(host=HOST, user=USER)

@task
def close(ctx):
    ctx.conn.close()

@task(pre=[connect], post=[close])
def ls(ctx):
    with ctx.conn.cd(ROOT):
        ctx.conn.run('find | sed \'s|[^/]*/|- |g\'')

@task(pre=[connect], post=[close])
def reset(ctx):
    ctx.conn.run('rm -rf {}'.format(ROOT), pty=True)

@task(pre=[connect], post=[close])
def killpython(ctx):
    ctx.conn.run('pkill -9 python', pty=True)


# Setup the environment
@task(pre=[connect], post=[close])
def setup(ctx):
    ctx.conn.run('sudo apt-get update')
    ctx.conn.run('sudo apt install -y dtach')
    ctx.conn.run('sudo apt-get install nfs-common -y')
    with ctx.conn.cd('/mnt/'):
        ctx.conn.run('sudo mkdir efs')
        ctx.conn.run(f'sudo mount -t nfs4 {STORAGE}:/ /mnt/efs')

@task(pre=[connect], post=[close])
def fix(ctx):
    # locked error
    ctx.conn.run('sudo killall apt apt-get')

@task
def push(ctx, model=''):
    ctx.run('rsync -rv --progress {files} {remote}'.format(files=' '.join(ALL), remote=REMOTE))
    # model = sorted([fp for fp in glob.glob('models/*') if model and model in fp], reverse=True)
    # if model:
    #     ctx.run('rsync -rv {folder}/ {remote}/{folder}'.format(remote=REMOTE, folder=model[0]))

@task
def pulldata(ctx):
    ctx.run('rsync -rv --progress {remote}/{folder}/ {folder}'.format(remote=REMOTE, folder=DATA))

@task
def pull(ctx):
    ctx.run('rsync -rv --progress {remote}/{folder}/ {folder}'.format(remote=REMOTE, folder=MODEL))
    ctx.run('rsync -rv --progress {remote}/{folder}/ {folder}'.format(remote=REMOTE, folder=OUTPUT))
    ctx.run('rsync -rv --progress {remote}/{folder}/ {folder}'.format(remote=REMOTE, folder=LOGS))

@task(pre=[connect], post=[close])
def clean(ctx):
    ctx.conn.run('rm -rf {}/models'.format(ROOT), pty=True)
    ctx.conn.run('rm -rf {}/output_tests'.format(ROOT), pty=True)
    ctx.conn.run('rm -rf {}/output_renders'.format(ROOT), pty=True)


@task(pre=[connect], post=[close])
def train(ctx, model=''):
    ctx.run('rsync -rv --progress {files} {remote}'.format(files=' '.join(ALL), remote=REMOTE))
    with ctx.conn.cd(ROOT):
        with ctx.conn.prefix('source activate pytorch_p36'):
            ctx.conn.run('dtach -A /tmp/{} ./scripts/ramen_VQA2.sh'.format(PROJECT_NAME), pty=True)


@task(pre=[connect], post=[close])
def test(ctx, model=''):
    ctx.run('rsync -rv --progress {files} {remote}'.format(files=' '.join(ALL), remote=REMOTE))
    with ctx.conn.cd(ROOT):
        with ctx.conn.prefix('source activate pytorch_p36'):
            ctx.conn.run('dtach -A /tmp/{} ./scripts/ramen_VQA2_test.sh'.format(PROJECT_NAME), pty=True)


@task(pre=[connect], post=[close])
def resume(ctx):
    ctx.conn.run('dtach -a /tmp/{}'.format(PROJECT_NAME), pty=True)