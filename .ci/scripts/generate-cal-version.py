# generate_version.py
import requests
import datetime
import os

version = os.getenv('INPUT_VERSION')
gh_repo = os.getenv('GH_REPO')

response = requests.get(f'https://api.github.com/repos/{gh_repo}/releases')
releases = [release['tag_name'] for release in response.json()]
if version in releases:
    raise ValueError(f"A release with version {version} already exists.")

if not version:
    date = datetime.datetime.now().strftime('%Y.%m.%d')
    version = date
    suffix = 2
    while version in releases:
        version = f'{date}-{suffix}'
        suffix += 1

print(version)
