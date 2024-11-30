import time

from behave import *
from hamcrest import assert_that

from features.steps import utils
from features.steps.cdo_apis import delete_insights, verify_insight_type_and_state
from features.steps.metrics_generator_apis import update_timeseries, create_metric, get_all_metrics, delete_timeseries
from features.steps.utils import execute_docker_compose_command


@step('the insights are cleared')
def step_impl(context):
    delete_insights()


@step('verify if an {insight_type} insight with state {insight_state} is created')
def step_impl(context, insight_type, insight_state):
    assert_that(verify_insight_type_and_state(insight_type, insight_state))


@step('verify if an {insight_type} insight with state {insight_state} is created with a timeout of {timeout} minutes')
def step_impl(context, insight_type, insight_state, timeout):
    for i in range(int(timeout) * 6):
        if verify_insight_type_and_state(insight_type, insight_state):
            assert_that(True)
            return
        time.sleep(10)
    assert_that(verify_insight_type_and_state(insight_type, insight_state))


@step('keep checking for {duration} minute(s) if an {insight_type} insight with state {insight_state} is created')
def step_impl(context, duration, insight_type, insight_state):
    for i in range(int(duration)):
        if verify_insight_type_and_state(insight_type, insight_state):
            assert_that(True)
            return
        time.sleep(60)
    assert_that(False)


@given('the mock generator is started')
def step_impl(context):
    command = ["docker compose", "up", "-d"]
    execute_docker_compose_command(command)
    # Give some time for the mock generator to start
    time.sleep(2)


@step('the mock generator should be up and running')
def step_impl(context):
    get_all_metrics()


@then('create the following metrics')
def step_impl(context):
    for row in context.table:
        create_metric(row['name'], row['data_type'], row['help'], [s.strip() for s in row['labels'].split(',')])


@then(
    'increase/update the value of the metric {metric_name} to {metric_value} for the time series {timeseries_name} with '
    'label values')
def step_impl(context, metric_name, metric_value, timeseries_name):
    if context.tenant_id is None:
        raise Exception("Tenant ID not found in context")
    labels = {
        "tenant_uuid": context.tenant_id
    }
    if context.table is not None:
        for row in context.table:
            labels[row['label_name']] = row['label_value']

    # Store the time series in the context
    utils.store_ts_in_context(context, labels, timeseries_name, metric_name)

    # Update the time series - Send HTTP POST to update metrics
    update_timeseries(metric_name, labels, float(metric_value))


@then('increase/update the value of timeseries {ts} to {value}')
def step_impl(context, ts, value):
    metric_name = ''
    print(context.timeseries)
    for name, timeseries_dict in context.timeseries.items():
        if ts in timeseries_dict.keys():
            metric_name = name

    if metric_name == '':
        raise Exception(f"Time series {ts} not found in context")

    update_timeseries(metric_name, context.timeseries[metric_name][ts], float(value))


@then('delete timeseries {ts}')
def step_impl(context, ts):
    metric_name = ''
    print(context.timeseries)
    for name, timeseries_dict in context.timeseries.items():
        if ts in timeseries_dict.keys():
            metric_name = name

    if metric_name == '':
        raise Exception(f"Time series {ts} not found in context")

    req_dict = {
        'labels': context.timeseries[metric_name][ts]
    }
    delete_timeseries(metric_name, req_dict)


@step('delete all time series')
def step_impl(context):
    for metric_name, timeseries in context.timeseries.items():
        for timeseries_name, ts in timeseries.items():
            req_dict = {
                'labels': ts
            }
            delete_timeseries(metric_name, req_dict)


@step('wait for {duration} {unit}')
def step_impl(context, duration, unit):
    if unit == "seconds" or unit == "second":
        time.sleep(int(duration))
    elif unit == "minutes" or unit == "minute":
        time.sleep(int(duration) * 60)
    else:
        raise Exception(f"Unsupported unit: {unit}")


@step('stop the mock generator')
def step_impl(context):
    command = ["docker compose", "down"]
    execute_docker_compose_command(command)


@then(
    'keep updating the following timeseries with a periodicity of {duration} {unit} for {num_iterations} times and verify if an {insight_type} insight with state {insight_state} is created')
def step_impl(context, duration, unit, num_iterations, insight_type, insight_state):
    initial_values = {}
    for row in context.table:
        initial_values[row['timeseries_name']] = float(row['initial_value'])

    for i in range(int(num_iterations)):
        for row in context.table:
            context.execute_steps(
                f"\nThen increase/update the value of timeseries {row['timeseries_name']} to {initial_values[row['timeseries_name']] + float(row['increment_delta'])}")
            initial_values[row['timeseries_name']] += float(row['increment_delta'])
        # If the insight has been created, exit
        if verify_insight_type_and_state(insight_type, insight_state):
            assert_that(True)
            return
        context.execute_steps(f"\nThen wait for {duration} {unit}")
    assert_that(False)
