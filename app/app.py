"""Sample app that only calls FedRAMP-authorized vendors."""

import requests

OKTA_URL = "https://login.okta.com/oauth2/v1/token"
METRICS_URL = "https://api.datadoghq.com/api/v1/series"


def exchange_token(payload: dict) -> dict:
    response = requests.post(OKTA_URL, json=payload, timeout=5)
    return response.json()


def emit_metric(series: dict) -> None:
    requests.post(METRICS_URL, json=series, timeout=5)
