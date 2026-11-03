"""Uploads an Android App Bundle to a Google Play testing track (docs/PLAY_STORE.md, Play'e yükleme).

Usage: python deploy/play-upload.py <bundle.aab> [--track alpha] [--notes "Türkçe sürüm notu"]

Needs `pip install google-api-python-client google-auth` and the service account key of
gway-play-publisher@grupx-512513.iam.gserviceaccount.com at ~/.grupx/play-publisher.json (never in the repository).
The account may only release to testing tracks.
"""
import argparse
import pathlib

import httplib2
from google.oauth2 import service_account
from google_auth_httplib2 import AuthorizedHttp
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

PACKAGE = 'com.gway.app'
KEY = pathlib.Path.home() / '.grupx' / 'play-publisher.json'

# Play reads the whole bundle before it answers the last chunk; the default 60 s timeout ran out on 2026-11-03.
TIMEOUT_SECONDS = 900
CHUNK_BYTES = 8 * 1024 * 1024


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('bundle')
    parser.add_argument('--track', default='alpha')
    parser.add_argument('--notes', default='Hata düzeltmeleri ve iyileştirmeler.')
    args = parser.parse_args()

    credentials = service_account.Credentials.from_service_account_file(
        str(KEY), scopes=['https://www.googleapis.com/auth/androidpublisher'])
    base = httplib2.Http(timeout=TIMEOUT_SECONDS)
    # 308 means "resume incomplete" in a chunked upload, not a redirect (as googleapiclient's own build_http does).
    base.redirect_codes = base.redirect_codes - {308}
    http = AuthorizedHttp(credentials, http=base)
    edits = build('androidpublisher', 'v3', http=http, cache_discovery=False).edits()

    edit_id = edits.insert(packageName=PACKAGE, body={}).execute()['id']
    media = MediaFileUpload(args.bundle, mimetype='application/octet-stream', resumable=True, chunksize=CHUNK_BYTES)
    version = edits.bundles().upload(packageName=PACKAGE, editId=edit_id, media_body=media).execute(num_retries=3)['versionCode']
    print(f'uploaded version code {version}')

    edits.tracks().update(packageName=PACKAGE, editId=edit_id, track=args.track, body={
        'track': args.track,
        'releases': [{
            'versionCodes': [str(version)],
            'status': 'completed',
            'releaseNotes': [{'language': 'tr-TR', 'text': args.notes}],
        }],
    }).execute()
    edits.commit(packageName=PACKAGE, editId=edit_id).execute()
    print(f'released {version} to {args.track}')


if __name__ == '__main__':
    main()
