"""Pushes only the three auth email templates (12 languages, supabase/templates/*.html) to the cloud project.

`supabase config push` would also overwrite the cloud's other auth settings (site URL, MFA, Google, hooks) with the
local development values, so this script changes the email subjects and bodies and nothing else.

Usage (from the repo root):
  SUPABASE_ACCESS_TOKEN=<personal access token> python deploy/push-email-templates.py <project-ref>
A token is created at https://supabase.com/dashboard/account/tokens; delete it afterwards if it was made for this.
"""
import json
import os
import pathlib
import sys
import urllib.request

TEMPLATES = ['confirmation', 'recovery', 'email_change']
SUBJECT = 'GWAY'  # the subject cannot follow the language, so it is the app name (supabase/config.toml)


def main(ref):
    token = os.environ.get('SUPABASE_ACCESS_TOKEN')
    if not token:
        sys.exit('SUPABASE_ACCESS_TOKEN is not set')
    root = pathlib.Path(__file__).resolve().parents[1] / 'supabase' / 'templates'
    body = {}
    for name in TEMPLATES:
        body[f'mailer_subjects_{name}'] = SUBJECT
        body[f'mailer_templates_{name}_content'] = (root / f'{name}.html').read_text(encoding='utf-8')
    request = urllib.request.Request(
        f'https://api.supabase.com/v1/projects/{ref}/config/auth',
        data=json.dumps(body).encode('utf-8'),
        method='PATCH',
        headers={'Authorization': f'Bearer {token}', 'Content-Type': 'application/json', 'User-Agent': 'gway-deploy'},
    )
    with urllib.request.urlopen(request, timeout=60) as response:
        saved = json.loads(response.read())
    for name in TEMPLATES:
        ok = saved.get(f'mailer_templates_{name}_content') == body[f'mailer_templates_{name}_content']
        print(f'{name}: {"ok" if ok else "NOT SAVED"}')


if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    main(sys.argv[1])
