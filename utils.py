from RPA.Robocorp.Vault import Vault
from RPA.HTTP import HTTP
import os

API_BASE_URL = "https://cloud.robocorp.com/api/v1/workspaces"

def update_workitem(work_item_id, data):
    workspace_id = os.environ["RC_WORKSPACE_ID"]
    api_key = Vault().get_secret("webstore")
    headers = {"Authorization": f"RC-WSKEY {api_key}"}
    HTTP.session_less_post(
        headers=headers,
        url=f"{API_BASE_URL}/{workspace_id}/work-items/{work_item_id}/payload",
        json=data)

def retry_workitem(work_item_id):
    workspace_id = os.environ["RC_WORKSPACE_ID"]
    api_key = Vault().get_secret("webstore")
    headers = {"Authorization": f"RC-WSKEY {api_key}"}
    data = {"batch_operation": "retry", "work_item_ids": [work_item_id]}
    HTTP.session_less_post(
        headers=headers,
        url=f"{API_BASE_URL}/{workspace_id}/work-items/batch",
        json=data)
