import json

import requests
from hamcrest import assert_that

from features.steps.env import Url


def create_metric(metric_name, data_type, description, labels):
    req_dict = {
        'data_type': data_type,
        'name': metric_name,
        'help': description,
        'labels': labels
    }
    print("Request: ", req_dict)
    response = requests.post(Url.METRICS_URL, json=req_dict, headers={"Content-Type": "application/json"})
    print("Response Code: ", response.status_code)
    assert_that(response.status_code == 200)
    print("Response Body: ", response.json())
    assert_that(response.json()['message'] == "Metric created successfully")


def get_all_metrics():
    response = requests.get(Url.METRICS_URL)
    assert response.status_code == 200, f"GET request to {Url.METRICS_URL} failed with status code {response.status_code}"
    print("GET request to {url} succeeded with status code {status_code}".format(url=Url.METRICS_URL,
                                                                                 status_code=response.status_code))
    return response


def update_timeseries(metric_name, labels, value):
    req_dict = {
        'value': float(value),
        'labels': labels
    }
    post_url = f"{Url.METRICS_URL}/{metric_name}"
    print("Request: ", json.dumps(req_dict))
    response = requests.post(post_url, data=json.dumps(req_dict), headers={"Content-Type": "application/json"})
    print("Response: ", response.json())
    assert_that(response.status_code == 200)
    assert_that(response.json()['value'] == float(value))
    assert_that(response.json()['message'] == "Metric updated successfully")


def delete_timeseries(metric_name, req_dict=None):
    delete_url = f"{Url.METRICS_URL}/{metric_name}"
    print("Request: ", json.dumps(req_dict))
    response = requests.delete(delete_url, data=json.dumps(req_dict), headers={"Content-Type": "application/json"})
    print("Response: ", response.json())
    assert_that(response.status_code == 200)
    assert_that(response.json()['message'] == "Time series deleted successfully")
