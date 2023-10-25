from RPA.Robocorp.Vault import Vault
from RPA.HTTP import HTTP
import ast
from json.decoder import JSONDecodeError
import os
import re

API_BASE_URL = "https://cloud.robocorp.com/api/v1/workspaces"
TEST_STRING = "WORK ITEM DATA:\n {'Name': 'Sol Heaton', 'Zip': 3695, 'Items': ['Sauce Labs Bolt T-Shirt',\n'Sauce Labs Fleece Jacket', 'Sauce Labs One']}\n WORK ITEM ID: 98faa4c9-3510-4ae3-8a01-eb032ef8164"


def extract_data_and_id(text):
    work_item_data_match = re.search(r"WORK.*ITEM.*DATA:.*(\{.*\})", text, re.DOTALL)
    work_item_id_match = re.search(r"WORK.*ITEM.*ID:\s*([\w|-]*)", text, re.DOTALL)
    if work_item_data_match and work_item_id_match:
        data = work_item_data_match.group(1)
        wid = work_item_id_match.group(1)
        try:
            data_as_json = ast.literal_eval(data)
        except JSONDecodeError:
            data = data.replace("'", '"')
            data_as_json = ast.literal_eval(data)
        return data_as_json, wid
    else:
        return None, None


def update_workitem(work_item_id, data):
    workspace_id = os.environ["RC_WORKSPACE_ID"]
    api_key = Vault().get_secret("webstore")
    headers = {"Authorization": f"RC-WSKEY {api_key}"}
    HTTP().session_less_post(
        headers=headers,
        url=f"{API_BASE_URL}/{workspace_id}/work-items/{work_item_id}/payload",
        json=data,
    )


def retry_workitem(work_item_id):
    workspace_id = os.environ["RC_WORKSPACE_ID"]
    api_key = Vault().get_secret("webstore")
    headers = {"Authorization": f"RC-WSKEY {api_key}"}
    data = {"batch_operation": "retry", "work_item_ids": [work_item_id]}
    HTTP().session_less_post(
        headers=headers,
        url=f"{API_BASE_URL}/{workspace_id}/work-items/batch",
        json=data,
    )


if __name__ == "__main__":
    data, work_item_id = extract_data_and_id(TEST_STRING)
    print(f"DATA = {data}")
    print(f"WID = {work_item_id}")
