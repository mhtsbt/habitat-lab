import requests
import numpy as np
import io
import zlib
import cv2


class LocobotClient:

    def __init__(self, locobot_url):
        self.locobot_url = locobot_url

    def _uncompress_nparr(self, bytestring):
        return np.load(io.BytesIO(zlib.decompress(bytestring)))

    def _get(self, url):
        try:
            x = requests.get(f"{self.locobot_url}/{url}")
            if x.status_code == 200:
                return True, x
            else:
                print(f"Status code locobot: {x.status_code}")
                return False, None
        except Exception as ex:
            print(ex)
            return False, None

    def move(self, action_name, amount):
        return self._get(url=f"move?action_name={action_name}&amount={amount}")

    def get_depth(self):
        success, depth_resp = self._get(url="depth")
        if success:
            data = self._uncompress_nparr(depth_resp.content)
            data = data.astype(np.float32)*0.001
            data = cv2.resize(data, (256, 256))
            return data
