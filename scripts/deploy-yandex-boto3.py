#!/usr/bin/env python3
"""Deploy static site to Yandex Object Storage (no awscli). Reads keys from yc-keys.local.env."""
import os
import mimetypes
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
KEYS = Path(__file__).resolve().parent / 'yc-keys.local.env'
BUCKET = 'edecorus.ru'
ENDPOINT = 'https://storage.yandexcloud.net'
REGION = 'ru-central1'

EXCLUDE_PREFIXES = (
    '.git/', '.github/', '.vscode/', '.cursor/', 'scripts/', 'drive-archive/', 'docs/',
)
EXCLUDE_NAMES = {'.gitignore', 'clone.ps1', 'CONTEXT.md'}
EXCLUDE_SUFFIXES = ('.md',)


def load_keys():
    if not KEYS.exists():
        raise SystemExit(f'Create {KEYS} from yc-keys.local.env.example')
    for line in KEYS.read_text(encoding='utf-8').splitlines():
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        k, _, v = line.partition('=')
        v = v.strip().strip('"').strip("'")
        if 'xxxx' in v or v.startswith('PASTE'):
            continue
        os.environ[k.strip()] = v
    ak = os.environ.get('AWS_ACCESS_KEY_ID')
    sk = os.environ.get('AWS_SECRET_ACCESS_KEY')
    if not ak or not sk:
        raise SystemExit('Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in yc-keys.local.env')
    return ak, sk


def should_upload(rel: str) -> bool:
    p = rel.replace('\\', '/')
    if any(p.startswith(x) for x in EXCLUDE_PREFIXES):
        return False
    name = Path(p).name
    if name in EXCLUDE_NAMES:
        return False
    if any(p.endswith(s) for s in EXCLUDE_SUFFIXES):
        return False
    return True


def main():
    load_keys()
    import boto3
    from botocore.config import Config

    session = boto3.session.Session(
        aws_access_key_id=os.environ['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key=os.environ['AWS_SECRET_ACCESS_KEY'],
        region_name=REGION,
    )
    s3 = session.client('s3', endpoint_url=ENDPOINT, config=Config(signature_version='s3v4'))

    uploaded = 0
    for path in ROOT.rglob('*'):
        if not path.is_file():
            continue
        rel = path.relative_to(ROOT).as_posix()
        if not should_upload(rel):
            continue
        ctype, _ = mimetypes.guess_type(str(path))
        extra = {'ContentType': ctype or 'application/octet-stream'}
        if rel.endswith('.html'):
            extra['ContentType'] = 'text/html; charset=utf-8'
        elif rel.endswith('.css'):
            extra['ContentType'] = 'text/css; charset=utf-8'
        elif rel.endswith('.js'):
            extra['ContentType'] = 'application/javascript; charset=utf-8'
        s3.upload_file(str(path), BUCKET, rel, ExtraArgs={**extra, 'ACL': 'public-read'})
        uploaded += 1
        print(rel)

    print(f'Done: {uploaded} files -> https://{BUCKET}.website.yandexcloud.net')


if __name__ == '__main__':
    main()
