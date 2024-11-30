Feature: Correlation testing
  # This feature tests if the desired alerts are raised for various correlation scenarios

  Scenario: Create metrics
    Given the mock generator is started
    Then create the following metrics
      | name                   | data_type | help                   | labels                                     |
      | cpu                    | gauge     | CPU consumption        | tenant_uuid, cpu, uuid                     |
      | mem                    | gauge     | Memory consumption     | tenant_uuid, mem, uuid                     |
      | conn_stats             | gauge     | Connection Statistics  | tenant_uuid, conn_stats, description, uuid |
      | interface              | counter   | Connection Statistics  | tenant_uuid, interface, description, uuid  |
      | deployed_configuration | gauge     | Deployed configuration | deployed_configuration ,tenant_uuid, uuid  |
      | snort                  | gauge     | Snort Data             | description , snort  , tenant_uuid, uuid   |
    Then the mock generator should be up and running

  # Firing Test scenarios
  Scenario: Push data and test correlation alerts for CPU_LINA_THRESHOLD_BREACH
    Given the mock generator is started
    And the insights are cleared
    Then push timeseries for next 60 minutes of which send last 2 minute(s) of timeseries in live mode
      | metric_name            | label_values                                                                         | start_value | end_value | start_spike_minute | spike_duration_minutes |
      | cpu                    | cpu=lina_dp_avg, uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8                           | 5           | 85        | 1                  | 60                     |
      | cpu                    | cpu=lina_cp_avg, uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8                           | 12          | 90        | 1                  | 60                     |
      | conn_stats             | conn_stats=connection, description=in_use, uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8 | 12          | 90        | 1                  | 60                     |
      | interface              | description=input_bytes , interface=all , uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8  | 12          | 12        | 1                  | 60                     |
      | interface              | description=input_packets, interface=all , uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8 | 12          | 90        | 1                  | 60                     |
      | deployed_configuration | deployed_configuration=number_of_ACEs , uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8    | 12          | 90        | 1                  | 60                     |
    Then keep checking for 10 minute(s) if an CPU_LINA_THRESHOLD_BREACH insight with state ACTIVE is created
    Then push timeseries for next 2 minutes of which send last 2 minute(s) of timeseries in live mode
      | metric_name | label_values                                               | start_value | end_value | start_spike_minute | spike_duration_minutes |
      | cpu         | cpu=lina_dp_avg, uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8 | 60          | 60        | 0                  | 1                      |
    Then keep checking for 10 minute(s) if an CPU_LINA_THRESHOLD_BREACH insight with state RESOLVED is created

  Scenario: Push data and test correlation alerts for CPU_SNORT_THRESHOLD_BREACH
    Given the mock generator is started
    And the insights are cleared
    Then push timeseries for next 60 minutes of which send last 2 minute(s) of timeseries in live mode
      | metric_name | label_values                                                                                 | start_value | end_value | start_spike_minute | spike_duration_minutes |
      | cpu         | cpu=snort_avg, uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8                                     | 5           | 85        | 1                  | 60                     |
      | cpu         | cpu=lina_cp_avg, uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8                                   | 60          | 90        | 1                  | 60                     |
      | conn_stats  | conn_stats=connection, description=in_use, uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8         | 12          | 90        | 1                  | 60                     |
      | interface   | description=input_bytes , interface=all , uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8          | 12          | 12        | 1                  | 60                     |
      | interface   | description=input_packets, interface=all , uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8         | 12          | 90        | 1                  | 60                     |
      | interface   | description=input_avg_packet_size, interface=all , uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8 | 12          | 90        | 1                  | 60                     |
      | snort       | description=denied_flow_events, snort=stats , uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8      | 12          | 90        | 1                  | 60                     |
    Then keep checking for 10 minute(s) if an CPU_SNORT_THRESHOLD_BREACH insight with state ACTIVE is created
    Then push timeseries for next 2 minutes of which send last 2 minute(s) of timeseries in live mode
      | metric_name | label_values                                             | start_value | end_value | start_spike_minute | spike_duration_minutes |
      | cpu         | cpu=snort_avg, uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8 | 60          | 60        | 0                  | 1                      |
    Then keep checking for 10 minute(s) if an CPU_SNORT_THRESHOLD_BREACH insight with state RESOLVED is created

  Scenario: Push data and test correlation alerts for MEMORY_LINA_THRESHOLD_BREACH
    Given the mock generator is started
    And the insights are cleared
    Then push timeseries for next 60 minutes of which send last 2 minute(s) of timeseries in live mode
      | metric_name            | label_values                                                                         | start_value | end_value | start_spike_minute | spike_duration_minutes |
      | mem                    | mem=used_percentage_lina, uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8                  | 5           | 85        | 1                  | 60                     |
      | conn_stats             | conn_stats=connection, description=in_use, uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8 | 12          | 90        | 1                  | 60                     |
      | interface              | description=input_bytes , interface=all , uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8  | 12          | 12        | 1                  | 60                     |
      | interface              | description=input_packets, interface=all , uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8 | 12          | 90        | 1                  | 60                     |
      | deployed_configuration | deployed_configuration=number_of_ACEs , uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8    | 12          | 90        | 1                  | 60                     |
    Then keep checking for 10 minute(s) if an MEMORY_LINA_THRESHOLD_BREACH insight with state ACTIVE is created
    Then push timeseries for next 2 minutes of which send last 2 minute(s) of timeseries in live mode
      | metric_name | label_values                                                        | start_value | end_value | start_spike_minute | spike_duration_minutes |
      | mem         | mem=used_percentage_lina, uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8 | 60          | 60        | 0                  | 1                      |
    Then keep checking for 10 minute(s) if an MEMORY_LINA_THRESHOLD_BREACH insight with state RESOLVED is created

  Scenario: Push data and test correlation alerts for MEMORY_SNORT_THRESHOLD_BREACH
    Given the mock generator is started
    And the insights are cleared
    Then push timeseries for next 60 minutes of which send last 2 minute(s) of timeseries in live mode
      | metric_name | label_values                                                                         | start_value | end_value | start_spike_minute | spike_duration_minutes |
      | mem         | mem=used_percentage_snort, uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8                 | 5           | 85        | 1                  | 60                     |
      | conn_stats  | conn_stats=connection, description=in_use, uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8 | 12          | 90        | 1                  | 60                     |
      | interface   | description=input_bytes , interface=all , uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8  | 12          | 12        | 1                  | 60                     |
      | interface   | description=input_packets, interface=all , uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8 | 12          | 90        | 1                  | 60                     |
    Then keep checking for 10 minute(s) if an MEMORY_SNORT_THRESHOLD_BREACH insight with state ACTIVE is created
    Then push timeseries for next 2 minutes of which send last 2 minute(s) of timeseries in live mode
      | metric_name | label_values                                                         | start_value | end_value | start_spike_minute | spike_duration_minutes |
      | mem         | mem=used_percentage_snort, uuid=dc0a991a-8f67-11ef-ae8c-c13256d79bc8 | 60          | 60        | 0                  | 1                      |
    Then keep checking for 10 minute(s) if an MEMORY_SNORT_THRESHOLD_BREACH insight with state RESOLVED is created

  #  Run this after confirming the alert has been triggered
  Scenario: Delete all timeseries and shutdown the mock generator
    Given the mock generator should be up and running
    Then delete all time series
    Then stop the mock generator