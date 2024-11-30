Feature: Testing RA-VPN forecasting
  # This feature tests if the desired alerts are raised for various RA-VPN forecasting scenarios

  Scenario: Testing RA-VPN forecasting
    Given the tenant onboard state is ONBOARDED
    And the insights are cleared
    Then backfill RAVPN metrics for a suitable device
    Then trigger the RAVPN forecasting workflow
    Then verify if an RAVPN_MAX_SESSIONS_BREACH_FORECAST insight with state ACTIVE is created with a timeout of 10 minutes