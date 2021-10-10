from firebase_admin import initialize_app, credentials
from ..utils.dir import certificate

app = initialize_app(credentials.Certificate(certificate))
