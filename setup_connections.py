import json
from time import sleep

import requests as requests
from requests.auth import HTTPBasicAuth

MAX_WAIT_TIME = 900
SLEEP_TIME = 20


def process_private_key(file_path):
    """Reads a private key file and formats it for JSON."""
    with open(file_path, 'r') as key_file:
        key = key_file.read()
        # Replace actual newlines with the string '\n'
        return key.replace('\n', '\\n')


def wait_and_setup_connection(basic_auth, private_key_path, connection_id):
    wait_time = 0
    while True:
        try:
            print("Checking if SSH connection exists...")
            response = requests.get("http://localhost:8080/api/v1/connections/ssh_spark_node", auth=basic_auth)
            print(f"{response.status_code}: {response.text}")

            if response.status_code == 404:
                print("SSH connection does not exist, setting up...")
                # Process the private key
                private_key = process_private_key(private_key_path)

                # Prepare the connection payload
                ssh_conn = {
                    "connection_id": connection_id,
                    "conn_type": "ssh",
                    "host": "spark-jupyter",
                    "login": "sparkuser",
                    "extra": f'{{"private_key": "{private_key}"}}'
                }

                # Post the connection
                requests.post("http://localhost:8080/api/v1/connections", json=ssh_conn, auth=basic_auth)
            return
        except requests.exceptions.ConnectionError as e:
            print(f"Connection error: {e}")
        sleep(SLEEP_TIME)
        wait_time += SLEEP_TIME
        if wait_time > MAX_WAIT_TIME:
            raise Exception("Could not connect to Airflow")



if __name__ == "__main__":
    basic_auth = HTTPBasicAuth('admin', 'test')
    wait_and_setup_connection(basic_auth, 'docker/ssh_keys/id_rsa', "ssh_spark_node")
    wait_and_setup_connection(basic_auth, 'docker/ssh_keys/id_rsa', "ssh-spark-connection")
