Feature: Testing Elephant Flows
  # This feature tests if the desired alerts are raised for the single stack GCM architecture
  # Test setup is as follows:
  #   Two devices generating elephant flows:
  #    Device 22222222-2222-2222-2222-222222222222: YouTube - 1 Flow, WebEx - 1 Flow
  #    Device 99999999-9999-9999-9999-999999999999: WebEx - 1 Flow
  #
  # Once the ACTIVE Insight is created, the tenant is offboarded so as to test the RESOLVED Insight

  Scenario: Create metrics
    Given the mock generator is started
    Then create the following metrics
      | name                  | data_type | help                         | labels                                                                                                                                             |
      | efd_cpu_usage         | gauge     | Elephant Flow Duress         | destination_ip, destination_port, ef_detection_time, instance, job, protocol, session_start_time, source_ip, source_port, uuid, appid, tenant_uuid |
      | asp_drops             | gauge     | ASP Drops                    | asp_drops, description, instance, job, uuid, tenant_uuid                                                                                           |
      | efd_total_bytes       | gauge     | Throughput for various flows | destination_ip, destination_port, protocol, source_ip, source_port, uuid, tenant_uuid                                                              |
      | elephant_flow_enabled | gauge     | Elephant Flow Enabled        | tenant_uuid                                                                                                                                        |
    Then the mock generator should be up and running

  Scenario: Elephant flow FIRING alert for three devices spread across two tenants
    Given the mock generator is started
    And the tenant onboard state is ONBOARDED
    And the insights are cleared
    # efd_ts_1 -> Tenant 1, YouTube, FMC 1, Flow 1
    Then increase/update the value of the metric efd_cpu_usage to 66.66 for the time series efd_ts_1 with label values
      | label_name         | label_value                          |
      | destination_ip     | 20.20.0.98                           |
      | destination_port   | 98                                   |
      | ef_detection_time  | 1711367316                           |
      | instance           | 127.0.0.3:9273                       |
      | job                | 10.10.5.139                          |
      | protocol           | 6                                    |
      | session_start_time | 1711367315                           |
      | source_ip          | 10.10.0.98                           |
      | source_port        | 43000                                |
      | uuid               | 22222222-2222-2222-2222-222222222222 |
      | appid              | 929                                  |
    # efd_ts_2 -> Tenant 1, WebEx, FMC 1, Flow 1
    Then increase/update the value of the metric efd_cpu_usage to 77.77 for the time series efd_ts_2 with label values
      | label_name         | label_value                          |
      | destination_ip     | 20.20.0.97                           |
      | destination_port   | 97                                   |
      | ef_detection_time  | 1711367316                           |
      | instance           | 127.0.0.3:9273                       |
      | job                | 10.10.5.139                          |
      | protocol           | 6                                    |
      | session_start_time | 1711367315                           |
      | source_ip          | 10.10.0.98                           |
      | source_port        | 43001                                |
      | uuid               | 22222222-2222-2222-2222-222222222222 |
      | appid              | 905                                  |
    # efd_ts_3 -> Tenant 1, WebEx, FMC 2, Flow 1
    Then increase/update the value of the metric efd_cpu_usage to 88.88 for the time series efd_ts_3 with label values
      | label_name         | label_value                          |
      | destination_ip     | 20.20.0.97                           |
      | destination_port   | 97                                   |
      | ef_detection_time  | 1711367316                           |
      | instance           | 127.0.0.3:9273                       |
      | job                | 10.10.5.139                          |
      | protocol           | 6                                    |
      | session_start_time | 1711367315                           |
      | source_ip          | 10.10.0.98                           |
      | source_port        | 43001                                |
      | uuid               | 99999999-9999-9999-9999-999999999999 |
      | appid              | 905                                  |
    # efd_tpt_1 ->  Tenant 1, YouTube, FMC 1, Flow 1
    Then increase/update the value of the metric efd_total_bytes to 227966366 for the time series efd_tpt_1 with label values
      | label_name       | label_value                          |
      | destination_ip   | 20.20.0.98                           |
      | destination_port | 98                                   |
      | protocol         | 6                                    |
      | source_ip        | 10.10.0.98                           |
      | source_port      | 43000                                |
      | uuid             | 22222222-2222-2222-2222-222222222222 |
    # efd_tpt_2 ->  Tenant 1, WebEx, FMC 1, Flow 1
    Then increase/update the value of the metric efd_total_bytes to 237966366 for the time series efd_tpt_2 with label values
      | label_name       | label_value                          |
      | destination_ip   | 20.20.0.97                           |
      | destination_port | 97                                   |
      | protocol         | 6                                    |
      | source_ip        | 10.10.0.98                           |
      | source_port      | 43001                                |
      | uuid             | 22222222-2222-2222-2222-222222222222 |
    # efd_tpt_3 ->  Tenant 1, WebEx, FMC 2, Flow 1
    Then increase/update the value of the metric efd_total_bytes to 247966388 for the time series efd_tpt_3 with label values
      | label_name       | label_value                          |
      | destination_ip   | 20.20.0.97                           |
      | destination_port | 97                                   |
      | protocol         | 6                                    |
      | source_ip        | 10.10.0.97                           |
      | source_port      | 43001                                |
      | uuid             | 99999999-9999-9999-9999-999999999999 |
    # asp_ts_1 -> Tenant 1, FMC 1
    Then increase/update the value of the metric asp_drops to 120000 for the time series asp_ts_1 with label values
      | label_name  | label_value                           |
      | asp_drops   | snort-busy-not-fp                     |
      | description | snort instance busy not in full proxy |
      | instance    | 127.0.0.3:9273                        |
      | job         | 10.10.5.139                           |
      | uuid        | 22222222-2222-2222-2222-222222222222  |
    # asp_ts_2 -> Tenant 1, FMC 2
    Then increase/update the value of the metric asp_drops to 130000 for the time series asp_ts_2 with label values
      | label_name  | label_value                           |
      | asp_drops   | snort-busy-not-fp                     |
      | description | snort instance busy not in full proxy |
      | instance    | 127.0.0.3:9273                        |
      | job         | 10.10.5.139                           |
      | uuid        | 99999999-9999-9999-9999-999999999999  |
    # efd_enabled_ts_1 -> Tenant 1
    Then increase/update the value of the metric elephant_flow_enabled to 1 for the time series efd_enabled_ts_1 with label values
    Then keep updating the following timeseries with a periodicity of 15 seconds for 20 times and verify if an ELEPHANT_FLOW insight with state ACTIVE is created
      | timeseries_name | initial_value | increment_delta |
      | asp_ts_1        | 100000        | 10000           |
      | asp_ts_2        | 110000        | 10000           |
      | efd_tpt_1       | 177966388     | 100000000       |
      | efd_tpt_2       | 187966388     | 100000000       |
      | efd_tpt_3       | 197966388     | 100000000       |

  Scenario: Elephant flow RESOLVED alert for the same devices and tenants
    Given delete all time series
    Then keep checking for 7 minute(s) if an ELEPHANT_FLOW insight with state RESOLVED is created

  Scenario: Shutdown the mock generator
    Given the mock generator should be up and running
    Then stop the mock generator