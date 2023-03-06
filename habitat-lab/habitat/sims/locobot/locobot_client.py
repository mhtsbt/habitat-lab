import requests


class LocobotClient:

    def __init__(self, locobot_url):
        self.locobot_url = locobot_url

    def _get(self, url):
        try:
            x = requests.get(
                f"{self.locobot_url}/{url}")
            if x.status_code == 200:
                return True
            else:
                print(f"Status code locobot: {x.status_code}")
                return False
        except Exception as ex:
            print(ex)
            return False

    def move(self, action_name, amount):
        return self._get(url=f"move?action_name={action_name}&amount={amount}")
