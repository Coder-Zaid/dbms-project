import os
import json
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = int(os.getenv("DB_PORT", 3306))
DB_NAME = os.getenv("DB_NAME", "dairy_farm_db")
DB_USER = os.getenv("DB_USER", "root")

def get_dbeaver_password():
    """
    Safely retrieves saved MySQL password from local DBeaver configuration if available.
    """
    dbeaver_cred_path = os.path.expanduser(r"~\AppData\Roaming\DBeaverData\workspace6\General\.dbeaver\credentials-config.json")
    if os.path.exists(dbeaver_cred_path):
        try:
            data = open(dbeaver_cred_path, "rb").read()
            signed_bytes = [-70, -69, 74, -97, 119, 74, -72, 83, -55, 108, 45, 101, 61, -2, 84, 74]
            key = bytes([(b + 256) % 256 for b in signed_bytes])
            iv = data[:16]
            encrypted = data[16:]
            cipher = Cipher(algorithms.AES(key), modes.CBC(iv))
            decryptor = cipher.decryptor()
            decrypted = decryptor.update(encrypted) + decryptor.finalize()
            pad = decrypted[-1]
            decrypted = decrypted[:-pad]
            obj = json.loads(decrypted.decode("utf-8"))
            for conn_id, conn_data in obj.items():
                if "#connection" in conn_data:
                    pwd = conn_data["#connection"].get("password")
                    if pwd:
                        return pwd
        except Exception:
            pass
    return os.getenv("DB_PASSWORD", "")

DB_PASSWORD = get_dbeaver_password()
