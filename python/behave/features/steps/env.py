import os


class Path:
    BEHAVE_FEATURES_ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                                        os.pardir))
    PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(BEHAVE_FEATURES_ROOT)))
    DOCKER_COMPOSE_PATH = os.path.join(PROJECT_ROOT, "docker")
    PYTHON_UTILS_ROOT = os.path.join(PROJECT_ROOT, "python", "utils")


class Url:
    METRICS_URL = "http://localhost:8123/metrics"
    INSIGHTS_URL = "https://edge.staging.cdo.cisco.com/api/platform/ai-ops-insights/v1/insights"
    TENANT_ONBOARD_URL = "https://edge.staging.cdo.cisco.com/api/platform/ai-ops-orchestrator/v1/onboard/tenant"
    TENANT_GCM_STACK_CONFIG_URL = "https://edge.staging.cdo.cisco.com/api/platform/ai-ops-tenant-services/v1/timeseries-stack"
    PROMETHEUS_RELOAD_URL = "http://localhost:8122/-/reload"
    PROMETHEUS_RANGE_QUERY_URL = "https://edge.staging.cdo.cisco.com/api/platform/ai-ops-data-query/v1/healthmetrics/queryRange"
    TRIGGER_MANAGER_URL = "https://edge.staging.cdo.cisco.com/api/platform/ai-ops-orchestrator/v1/trigger"
    FMC_DETAILS_URL = "https://staging.dev.lockhart.io/aegis/rest/v1/services/targets/devices?q=deviceType:FMCE"
    DEVICE_GATEWAY_COMMAND_URL = "https://staging.dev.lockhart.io/api/platform/device-gateway/command"
