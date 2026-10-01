import ssl
import os
import sys

print("Injecting Zscaler SSL patch...", file=sys.stderr, flush=True)

ZSCALER_CERT = "/opt/zscaler-fix/zscaler-root-ca.pem"
COMBINED_BUNDLE = "/tmp/zscaler-combined-ca.pem"

if not os.path.exists(ZSCALER_CERT):
    raise FileNotFoundError(f"ERROR: Cannot find Zscaler certificate at {ZSCALER_CERT}.")

if not os.path.exists(COMBINED_BUNDLE):
    try:
        import certifi
        base_bundle = certifi.where()
    except ImportError:
        base_bundle = "/etc/ssl/certs/ca-certificates.crt"
    
    with open(COMBINED_BUNDLE, 'w') as combined:
        if os.path.exists(base_bundle):
            with open(base_bundle, 'r') as base:
                combined.write(base.read())
        combined.write("\n")
        with open(ZSCALER_CERT, 'r') as zs:
            combined.write(zs.read())
        combined.write("\n")


os.environ["REQUESTS_CA_BUNDLE"] = COMBINED_BUNDLE
os.environ["AWS_CA_BUNDLE"] = COMBINED_BUNDLE
os.environ["CURL_CA_BUNDLE"] = COMBINED_BUNDLE
os.environ["SSL_CERT_FILE"] = COMBINED_BUNDLE

_orig_wrap_socket = ssl.SSLContext.wrap_socket

def _patched_wrap_socket(self, *args, **kwargs):
    self.verify_flags &= ~ssl.VERIFY_X509_STRICT
    return _orig_wrap_socket(self, *args, **kwargs)

ssl.SSLContext.wrap_socket = _patched_wrap_socket

_orig_ctx = ssl.create_default_context
def _patched_ctx(*args, **kwargs):
    ctx = _orig_ctx(*args, **kwargs)
    ctx.verify_flags &= ~ssl.VERIFY_X509_STRICT
    return ctx

ssl.create_default_context = _patched_ctx
if hasattr(ssl, "_create_default_https_context"):
    ssl._create_default_https_context = _patched_ctx
