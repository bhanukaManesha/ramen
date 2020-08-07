#!/usr/bin/env python3
import glob
from fabric import Connection
from invoke import task

HOST        = 'ec2-3-0-139-199.ap-southeast-1.compute.amazonaws.com'
USER        = 'ubuntu'
ROOT        = 'ramen'
TBPORT      =  6006
REMOTE      = '{user}@{host}:{root}'.format(user=USER, host=HOST, root=ROOT)
VENV        = 'pytorch_p36'
MODEL       = 'models'
OUTPUT      = 'output_tests'
LOGS        = 'logs'
DATA        = 'data'
DATASET_LOCATION = 'honours-datasets/dataset'
GIT_REPO = 'https://github.com/bhanukaManesha/ramen.git'

PYTHON_SCRIPTS = [
    'lib',
    'common.py',
    'generator.py',
    'test.py',
    'train.py'
]

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
    # ctx.conn.run('sudo apt install -y dtach')
    ctx.conn.run('curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"')
    ctx.conn.run('unzip awscliv2.zip')
    ctx.conn.run('sudo ./aws/install')
    ctx.conn.run('git clone {}'.format(GIT_REPO))
    # PIP
    ctx.conn.put('requirements.in', remote='{}/requirements.in'.format(ROOT))
    with ctx.conn.cd(ROOT):
        with ctx.conn.prefix('source activate {}'.format(VENV)):
            ctx.conn.run('pip install -U pip')
            ctx.conn.run('pip install -U -r requirements.in')

    with ctx.conn.cd(ROOT):
        ctx.conn.run('aws s3 sync s3://{} dataset/'.format(DATASET_LOCATION))



@task(pre=[connect], post=[close])
def getfroms3(ctx):
    with ctx.conn.cd(ROOT):
        ctx.conn.run('aws s3 sync s3://{} dataset/'.format(DATASET_LOCATION))

@task(pre=[connect], post=[close])
def pushtos3(ctx):
    with ctx.conn.cd(ROOT):
        ctx.conn.run('aws s3 sync dataset/ s3://{} --delete'.format(DATASET_LOCATION))

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

# Generate the data

# @task(pre=[connect], post=[close])
# def generate(ctx, model=''):
#     ctx.run('rsync -rv {files} {remote}'.format(files=' '.join(ALL), remote=REMOTE))
#     with ctx.conn.cd(ROOT):
#         with ctx.conn.prefix('source activate tensorflow2_p36'):
#             ctx.conn.run('dtach -A /tmp/{} python generator.py'.format(ROOT), pty=True)


# Train

# @task(pre=[connect], post=[close])
# def train(ctx, model=''):
#     ctx.run('rsync -rv {files} {remote}'.format(files=' '.join(PYTHON_SCRIPTS), remote=REMOTE))
#     model = sorted([fp for fp in glob.glob('models/*') if model and model in fp], reverse=True)
#     if model:
#         ctx.run('rsync -rv {folder}/ {remote}/{folder}'.format(remote=REMOTE, folder=model[0]))
#
#     with ctx.conn.cd(ROOT):
#         with ctx.conn.prefix('source activate tensorflow2_p36'):
#             ctx.conn.run('dtach -A /tmp/{} python train.py -e 0'.format(ROOT), pty=True)
#
#
#     ctx.run('rsync -r {remote}/{folder}/ {folder}'.format(remote=REMOTE, folder=MODEL))
#     ctx.run('rsync -r {remote}/{folder}/ {folder}'.format(remote=REMOTE, folder=OUTPUT))
#     ctx.run('rsync -r {remote}/{folder}/ {folder}'.format(remote=REMOTE, folder=LOGS))



# @task(pre=[connect], post=[close])
# def resume(ctx):
#     ctx.conn.run('dtach -a /tmp/{}'.format(ROOT), pty=True)


# Test

# @task(pre=[connect], post=[close])
# def test(ctx, model=''):
#     ctx.run('rsync -rv {files} {remote}'.format(files=' '.join(PYTHON_SCRIPTS), remote=REMOTE))
#     model = sorted([fp for fp in glob.glob('models/*') if model and model in fp], reverse=True)
#     if model:
#         ctx.run('rsync -rv {folder}/ {remote}/{folder}'.format(remote=REMOTE, folder=model[0]))
#
#     with ctx.conn.cd(ROOT):
#         with ctx.conn.prefix('source activate tensorflow2_p36'):
#             ctx.conn.run('python test.py {}'.format(model), pty=True)
#
#     ctx.run('rsync -r {remote}/{folder}/ {folder}'.format(remote=REMOTE, folder=MODEL))
#     ctx.run('rsync -r {remote}/{folder}/ {folder}'.format(remote=REMOTE, folder=OUTPUT))



# Tensorboard
#
# @task(pre=[connect], post=[close])
# def tbrun(ctx):
#     with ctx.conn.cd(ROOT):
#         with ctx.conn.prefix('source activate {}'.format(VENV)):
#             ctx.conn.run('tensorboard --logdir logs/hparam_tuning --port={}'.format(TBPORT))
#
# @task
# def tbtunnel(ctx):
#     print("Tunnel Started")
#     webbrowser.open_new_tab('localhost:{}'.format(TBPORT))
#     os.system("ssh -N -L localhost:{}:localhost:{} {}@{}".format(TBPORT,TBPORT,USER,HOST))
#
#
# @task(pre=[connect], post=[close])
# def tbclean(ctx):
#     ctx.conn.run('rm -rf {}/models'.format(ROOT), pty=True)
#     ctx.conn.run('rm -rf {}/logs'.format(ROOT), pty=True)



