import json
import os.path
import subprocess
import time
from datetime import datetime
from datetime import timedelta
from string import Template

from behave import *
from mockseries.noise import GaussianNoise
from mockseries.seasonality import DailySeasonality
from mockseries.trend import LinearTrend
from mockseries.utils import datetime_range

from features.steps.cdo_apis import get, post
from features.steps.env import Url, Path

t = Template("""# HELP $metric_name $description
# TYPE $metric_name gauge
$metric_name{$labels_1} $value $timestamp
$metric_name{$labels_2} $value $timestamp
""")


@step('backfill RAVPN metrics for a suitable device')
def step_impl(context):
    if context.remote_write_config is None:
        print("Remote write config not found. Skipping backfill.")
        assert False

    if context.tenant_id is None:
        print("Tenant ID not found. Skipping backfill.")
        assert False

    ts_values, time_points = generate_timeseries()

    metric_name = "vpn"
    common_labels = {
        "instance": "127.0.0.2:9273",
        "job": "metrics_generator:8123",
        "uuid": get_device_id(),
        "tenant_uuid": context.tenant_id
    }
    labels_1 = {**common_labels, "vpn": "active_ravpn_tunnels"}
    labels_2 = {**common_labels, "vpn": "inactive_ravpn_tunnels"}
    description = "Currently active and inactive RAVPN tunnels"
    labels_1 = ",".join([f"{k}=\"{v}\"" for k, v in labels_1.items()])
    labels_2 = ",".join([f"{k}=\"{v}\"" for k, v in labels_2.items()])
    with open(os.path.join(Path.PYTHON_UTILS_ROOT, "historical_data.txt"), 'w') as file:
        for i in range(len(time_points)):
            multiline_text = t.substitute(value=ts_values[i], timestamp=int(time_points[i].timestamp()),
                                          metric_name=metric_name, labels_1=labels_1, labels_2=labels_2,
                                          description=description)
            file.write(multiline_text)
        file.write("# EOF")

    remote_write_config = context.remote_write_config

    subprocess.run([os.path.join(Path.PYTHON_UTILS_ROOT, "backfill.sh"),
                    remote_write_config["url"].removesuffix("/api/prom/push"),
                    remote_write_config["username"], remote_write_config["password"], Path.PYTHON_UTILS_ROOT])

    # Calculate the start and end times
    start_time = datetime.now() - timedelta(days=14)
    end_time = datetime.now() - timedelta(days=1)

    # Convert to epoch seconds
    start_time_epoch = int(start_time.timestamp())
    end_time_epoch = int(end_time.timestamp())

    query = "?query=" + metric_name + "&start=" + str(start_time_epoch) + "&end=" + str(
        end_time_epoch) + "&step=5m"
    endpoint = Url.PROMETHEUS_RANGE_QUERY_URL + query

    count = 0
    success = False
    while True:
        # Exit after 30 minutes
        if count > 30:
            print("Data not ingested in Prometheus. Exiting.")
            break

        count += 1

        # Check for data in Prometheus
        response = get(endpoint)
        if len(response["data"]["result"]) > 0:
            success = True
            break

        time.sleep(60)
        # TODO: Ingest live data till backfill data is available
    assert success


@step('trigger the RAVPN forecasting workflow')
def step_impl(context):
    payload = ""
    trigger_payload_file = os.path.join(Path.BEHAVE_FEATURES_ROOT, "resources", "trigger_forecast_workflow.json")
    with open(trigger_payload_file, 'r') as file:
        payload = file.read()

    post(Url.TRIGGER_MANAGER_URL, payload)


def generate_timeseries():
    # Trend component
    trend = LinearTrend(coefficient=0.2, time_unit=timedelta(hours=0.95), flat_base=5)

    # Seasonality component
    seasonality = DailySeasonality(
        {timedelta(hours=0): 1., timedelta(hours=2): 10.8, timedelta(hours=4): 18.1, timedelta(hours=6): 19.5,
         timedelta(hours=8): 17.6, timedelta(hours=10): 15.8, timedelta(hours=12): 14.1, timedelta(hours=14): 12.8,
         timedelta(hours=16): 10.3, timedelta(hours=18): 8.7, timedelta(hours=20): 3.6, timedelta(hours=22): 1.8,
         })

    # Noise component
    noise = GaussianNoise(mean=0, std=3)

    # Combine components
    timeseries = trend + seasonality + noise

    # Generate timeseries
    time_points = datetime_range(
        granularity=timedelta(minutes=5),
        start_time=datetime.now() - timedelta(days=14),
        end_time=datetime.now()
    )
    ts_values = timeseries.generate(time_points=time_points)
    return ts_values, time_points


def get_device_id():
    # Get cdFMC UID
    resp = get(Url.FMC_DETAILS_URL)
    uid = ""
    for d in resp:
        uid = d['uid']

    if uid == "":
        raise Exception("FMCE device not found")

    # Get the device id for which VPN is enabled
    req = {
        "deviceUid": uid,
        "request": {
            "commands": [
                {
                    "method": "GET",
                    "link": "/api/fmc_config/v1/domain/e276abec-e0f2-11e3-8169-6d9ed49b625f/health/ravpngateways",
                    "body": ""
                }
            ]
        }
    }

    resp = post(Url.DEVICE_GATEWAY_COMMAND_URL, json.dumps(req))
    print(resp.json())
    resp_body = json.loads(resp.json()['data']['responseBody'])

    device_id = ""
    for item in resp_body:
        device_id = item['device']['id']

    if device_id == "":
        raise Exception("RA-VPN gateway not found")

    return device_id
