# Created by hbalakr2 at 18/09/24
Feature: Testing maximum payload size of SNS
  # This feature creates multiple time series for the metric 'sns_test' such that the corresponding rule in GCM ( sns_test > 0) is triggered and it creates multiple alert instances
  # The goal is to see if modifying the alert manager config through group_by, group_wait, etc could help split the alert instances into separate SNS messages and avoid the 256KB limit

  Scenario: Create metrics
    Given the mock generator is started
    Then create the following metrics
      | name     | data_type | help        | labels      |
      | sns_test | gauge     | SNS Testing | tenant_uuid |
    Then the mock generator should be up and running

  Scenario: Create time series
    Given create 900 timeseries for the metric sns_test with random values for the labels tenant_uuid

#  Run this after confirming the alert has been triggered
  Scenario: Delete all timeseries and shutdown the mock generator
    Given the mock generator should be up and running
    Then delete all time series
    Then stop the mock generator

# Disabling grouping of alerts in alertmanager solves the problem - each alert comes in separate SNS message