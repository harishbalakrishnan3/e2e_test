Feature: Onboard and Offboard testing
  # This feature tests onboard and offboard scenarios

  Scenario: Test offboard
    Given the tenant onboard state is ONBOARDED
    Then perform a tenant offboard
    Then verify if the onboard status changes to NOT_ONBOARDED with a timeout of 2 minute(s)
    Then wait for 1 minute

  Scenario: Test onboard
    Given the tenant onboard state is NOT_ONBOARDED
    Then perform a tenant onboard
    Then verify if the onboard status changes to ONBOARDED with a timeout of 5 minute(s)