import os
import yaml
import jwt

from dotenv import load_dotenv
import docker

from features.steps.cdo_apis import get, post
from features.steps.env import Path, Url

timeseries = {}


def before_all(context):
    # Creating an empty timeseries dictionary - this will be populated in the due course of test execution
    context.timeseries = timeseries

    # Loading the CDO token from the .env file and adding it to the environment variables
    load_dotenv()
    cdo_token = os.getenv('CDO_TOKEN')
    os.environ['CDO_TOKEN'] = cdo_token

    # Adding the tenant_id to the context
    if cdo_token != "" and cdo_token is not None:
        decoded = jwt.decode(cdo_token, options={"verify_signature": False})
        context.tenant_id = decoded['parentId']

    # Updating the remote write config in the prometheus.yml file
    update_remote_write_config(context)


def before_scenario(context, scenario):
    client = docker.from_env()
    try:
        container = client.containers.get('prometheus')
        if container.status == 'running':
            update_remote_write_config(context)
            post(Url.PROMETHEUS_RELOAD_URL)
        else:
            print(f"Prometheus is not running. Status: {container.status}")
    except:
        print(f"Prometheus not found. Not updating remote write config.")


def update_remote_write_config(context):
    prometheus_config = load_prometheus_config()
    gcm_stack_config = get(Url.TENANT_GCM_STACK_CONFIG_URL)
    for remote_write_config in prometheus_config['remote_write']:
        if remote_write_config['name'] == 'staging-aiops':
            remote_write_config['url'] = '/'.join([gcm_stack_config['hmInstancePromUrl'], 'api/prom/push'])
            remote_write_config['basic_auth']['username'] = gcm_stack_config['hmInstancePromId']
            remote_write_config['basic_auth']['password'] = gcm_stack_config['prometheusToken']
            context.remote_write_config = {
                "url": remote_write_config['url'],
                "username": remote_write_config['basic_auth']['username'],
                "password": remote_write_config['basic_auth']['password']
            }

    with open(os.path.join(Path.PROJECT_ROOT, "prometheus.yml"), 'w') as file:
        yaml.dump(prometheus_config, file)


def load_prometheus_config():
    prometheus_config_file = os.path.join(Path.PROJECT_ROOT, "prometheus.yml")
    with open(prometheus_config_file, 'r') as file:
        prometheus_config = yaml.safe_load(file)
    return prometheus_config
