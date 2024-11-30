import random
import uuid

from behave import *

from features.steps import utils
from features.steps.metrics_generator_apis import update_timeseries


@step('create {} timeseries for the metric {} with random values for the labels {}')
def step_impl(context, timeseries, metric_name, labels):
    print(context)
    for i in range(int(timeseries)):
        labels_values_to_set = {}
        rand_uuid = str(uuid.uuid4())
        rand_value = random.randint(1, 100)
        for label in labels.split(','):
            labels_values_to_set[label] = rand_uuid
        # Store the time series in the context
        utils.store_ts_in_context(context, labels_values_to_set, rand_uuid, metric_name)

        # Update the time series - Send HTTP POST to update metrics
        update_timeseries(metric_name, labels_values_to_set, rand_value)
