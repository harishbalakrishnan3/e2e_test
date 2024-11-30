Feature: Onboard and Offboard testing
  # This feature tests onboard and offboard scenarios

  Scenario: Test offboard
    Given perform a tenant offboard
    Then verify if the onboard status changes to NOT_ONBOARDED with a timeout of 2 minute(s)

  Scenario: Test onboard
    Given the tenant onboard state is NOT_ONBOARDED
    Then perform a tenant onboard
    Then verify if the onboard status changes to ONBOARDED with a timeout of 5 minute(s)