from RPA.Robocorp.Vault import Vault
from RPA.HTTP import HTTP
import ast
from json.decoder import JSONDecodeError
import re
from bs4 import BeautifulSoup

API_BASE_URL = "https://cloud.robocorp.com/api/v1/workspaces"
TEST_STRING = "WORK ITEM DATA:\n {'Name': 'Sol Heaton', 'Zip': 3695, 'Items': ['Sauce Labs Bolt T-Shirt',\n'Sauce Labs Fleece Jacket', 'Sauce Labs One']}\n WORK ITEM ID: 98faa4c9-3510-4ae3-8a01-eb032ef8164b"


def extract_data_and_id(text):
    work_item_data_match = re.search(r"WORK.*ITEM.*DATA:.*({.*})", text, re.DOTALL)
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
    secrets = Vault().get_secret("webstore")
    api_key = secrets["api_key"]
    workspace_id = secrets["workspace_id"]
    headers = {"Authorization": f"RC-WSKEY {api_key}"}
    HTTP().session_less_post(
        headers=headers,
        url=f"{API_BASE_URL}/{workspace_id}/work-items/{work_item_id}/payload",
        json={"payload": data or {}},
    )


def retry_workitem(work_item_id):
    secrets = Vault().get_secret("webstore")
    api_key = secrets["api_key"]
    workspace_id = secrets["workspace_id"]
    headers = {"Authorization": f"RC-WSKEY {api_key}"}
    data = {"batch_operation": "retry", "work_item_ids": [work_item_id]}
    HTTP().session_less_post(
        headers=headers,
        url=f"{API_BASE_URL}/{workspace_id}/work-items/batch",
        json=data,
    )

def dict_to_html_table(d, work_item_id):
    html = f'<h5>WORK ITEM ID: {work_item_id}</h5><table id="{work_item_id}" style="width:100%; border-collapse: collapse;">\n'
    html += '<colgroup><col style="width:50%;"><col style="width:50%;"></colgroup>\n'
    html += '<thead>\n<tr><th style="text-align:center; background-color:#f2f2f2; border: 1px solid #dddddd; padding: 8px;">key</th><th style="text-align:center; background-color:#f2f2f2; border: 1px solid #dddddd; padding: 8px;">val</th></tr>\n</thead>\n<tbody>\n'
    for k, v in d.items():
        html += f'<tr><td style="text-align:center; border: 1px solid #dddddd; padding: 8px;">{k}</td><td style="text-align:center; border: 1px solid #dddddd; padding: 8px;">{v}</td></tr>\n'
    html += '</tbody>\n</table><br>'
    return html

def html_tables_to_dicts(html):
    soup = BeautifulSoup(html, 'html.parser')
    tables = soup.find_all('table')
    result = []
    for table in tables:
        table_id = table.get('id', None)
        d = {}
        for row in table.find_all('tr')[1:]:
            cells = row.find_all('td')
            key = cells[0].text
            val = cells[1].text
            d[key] = val
        result.append((d, table_id))
    return result


if __name__ == "__main__":
    print(f"TEST_STRING = {TEST_STRING}")
    data, work_item_id = extract_data_and_id(TEST_STRING)
    print(f"DATA = {data}")
    print(f"WID = {work_item_id}")
    update_workitem(work_item_id, data)
    retry_workitem(work_item_id)
