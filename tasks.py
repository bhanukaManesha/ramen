#!/usr/bin/env python3
import glob
from fabric import Connection
from invoke import task

HOST        = 'ec2-54-255-176-171.ap-southeast-1.compute.amazonaws.com'
STORAGE     = '172.31.43.166'
USER        = 'ubuntu'
ROOT        = '/mnt/efs/ramen'
TRAINROOT   = f'/home/{USER}/ramen'
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
    'requirements.in',
    'scripts',
    'preprocess',
    'models',
    'run_network.py',
    'dataset.py',
    'train.py'
]



TRAIN_DATASET = 'VQACP'
TEST_DATASET = 'VQACP'
MODEL_NAME = 'ramen'



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

    with ctx.conn.cd(f'/home/{USER}'):
        ctx.conn.run('sudo mkdir ramen')

    with ctx.conn.cd('/mnt/'):
        ctx.conn.run('sudo rsync -r --exclude dataset /home/ubuntu/ramen/')
        ctx.conn.run('sudo mkdir /home/ubuntu/ramen/dataset/')



@task(pre=[connect], post=[close])
def fix(ctx):
    # locked error
    ctx.conn.run('sudo killall apt apt-get')

@task(pre=[connect], post=[close])
def gpustats(ctx):
    with ctx.conn.prefix('source activate pytorch_p36'):
        ctx.conn.run('watch -n0.1 nvidia-smi', pty=True)

@task(pre=[connect], post=[close])
def cpustats(ctx):
    with ctx.conn.prefix('source activate pytorch_p36'):
        ctx.conn.run('htop', pty=True)


@task
def push(ctx):
    ctx.run('rsync -rv --progress {files} {remote}'.format(files=' '.join(ALL), remote=REMOTE))

@task
def pull(ctx):
    for file in ALL:
        ctx.run(f'rsync -rv --progress {REMOTE}/{file} .')


@task(pre=[connect], post=[close])
def clean(ctx):
    ctx.conn.run('rm -rf {}/models'.format(ROOT), pty=True)
    ctx.conn.run('rm -rf {}/output_tests'.format(ROOT), pty=True)
    ctx.conn.run('rm -rf {}/output_renders'.format(ROOT), pty=True)

def move_results_back_to_efs(ctx):
    with ctx.conn.cd('/mnt/efs/ramen/'):
        ctx.conn.run(f'sudo rsync -r --progress /home/ubuntu/ramen/dataset/{TRAIN_DATASET}/{TRAIN_DATASET}_results {ROOT}/dataset/{TRAIN_DATASET}/')

@task(pre=[connect], post=[close])
def train(ctx, model=''):
    # ctx.run('rsync -rv --progress {files} {remote}'.format(files=' '.join(ALL), remote=REMOTE))
    with ctx.conn.cd('/mnt/efs/ramen/'):
        ctx.conn.run('sudo rsync -r --progress --exclude dataset . /home/ubuntu/ramen/')
        # ctx.conn.run(f'sudo rsync -r --copy-links -h --progress dataset/{DATASET} /home/ubuntu/ramen/dataset/')

    with ctx.conn.cd(TRAINROOT):
        with ctx.conn.prefix('source activate pytorch_p36'):
            ctx.conn.run(f'dtach -A /tmp/{PROJECT_NAME} ./scripts/{TRAIN_DATASET}/{MODEL_NAME}_{TEST_DATASET}.sh', pty=True)


@task(pre=[connect], post=[close])
def test(ctx, model=''):
    # ctx.run('rsync -rv --progress {files} {remote}'.format(files=' '.join(ALL), remote=REMOTE))
    with ctx.conn.cd(TRAINROOT):
        with ctx.conn.prefix('source activate pytorch_p36'):
            ctx.conn.run(f'dtach -A /tmp/{PROJECT_NAME} ./scripts/{TRAIN_DATASET}/test_{MODEL_NAME}_{TEST_DATASET}.sh', pty=True)


@task(pre=[connect], post=[close])
def resume(ctx):
    ctx.conn.run('dtach -a /tmp/{}'.format(PROJECT_NAME), pty=True)