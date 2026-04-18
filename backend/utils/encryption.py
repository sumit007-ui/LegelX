import os
import secrets
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.primitives.kdf.hkdf import HKDF
from cryptography.hazmat.primitives import hashes
from functools import wraps

MASTER_KEY = os.environ.get("MASTER_KEY", os.urandom(32))

def derive_session_key(salt: bytes) -> bytes:
    hkdf = HKDF(
        algorithm=hashes.SHA256(),
        length=32,
        salt=salt,
        info=b'secure-transient-session'
    )
    # Ensure MASTER_KEY is bytes
    key_material = MASTER_KEY if isinstance(MASTER_KEY, bytes) else MASTER_KEY.encode()
    return hkdf.derive(key_material)

class SecureBuffer:
    """Implement memory safety by overwriting plaintext with null bytes after use."""
    def __init__(self, data: bytes):
        self._data = bytearray(data)

    def get_str(self) -> str:
        return self._data.decode('utf-8', errors='ignore')

    def get_bytes(self) -> bytes:
        return bytes(self._data)

    def wipe(self):
        # Overwrite in RAM
        for i in range(len(self._data)):
            self._data[i] = 0

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.wipe()

def encrypt_data(data: bytes) -> dict:
    """Module A / Client-Side Entry Encryption"""
    salt = secrets.token_bytes(16)
    key = derive_session_key(salt)
    aesgcm = AESGCM(key)
    nonce = secrets.token_bytes(12)
    ciphertext = aesgcm.encrypt(nonce, data, None)
    return {
        "ciphertext": ciphertext.hex(),
        "nonce": nonce.hex(),
        "salt": salt.hex()
    }

def decrypt_data(encrypted_payload: dict) -> bytes:
    salt = bytes.fromhex(encrypted_payload["salt"])
    key = derive_session_key(salt)
    aesgcm = AESGCM(key)
    nonce = bytes.fromhex(encrypted_payload["nonce"])
    ciphertext = bytes.fromhex(encrypted_payload["ciphertext"])
    return aesgcm.decrypt(nonce, ciphertext, None)

def secure_transient_processing(func):
    """Module B / Secure Transient Processing Decorator"""
    @wraps(func)
    def wrapper(self, payload, *args, **kwargs):
        # If the input is not our expected dictionary format, just pass it through 
        # (to maintain compatibility with existing non-encrypted usages)
        if not isinstance(payload, dict) or "ciphertext" not in payload:
            return func(self, payload, *args, **kwargs)
            
        # Decrypt into SecureBuffer
        plaintext_bytes = decrypt_data(payload)
        with SecureBuffer(plaintext_bytes) as buffer:
            # Reconstruct plaintext payload to maintain original function signature
            # We extract it as a string since AI parsers operate on text
            plaintext_str = buffer.get_str()
            # Call original inference model
            return func(self, plaintext_str, *args, **kwargs)
            
    return wrapper
