# app_intelligence

Ubuntuコンテナで動く、最小のDjango開発環境です。

- Ubuntu 24.04 LTS / Python 3.12.3 / Django 5.2.19
- CPU版PyTorch 2.8.0もDockerfileに固定して導入済み
- Macのこのフォルダをコンテナ内 `/var/www/html` に共有
- Djangoがコンテナの8000番で応答し、Macの http://localhost:8000 で表示

```text
app_intelligence/
├── Dockerfile
├── compose.yaml
├── manage.py
├── config/          Djangoの設定・URL・WSGI/ASGI
└── .devcontainer/   VS Code用
```

起動:

```sh
cd app_intelligence
docker compose up --build -d
```

Macのファイルを編集するとコンテナからも同じ内容が見え、Pythonの変更は開発サーバーが再読み込みします。最初はDjango標準の起動成功画面が表示されます。独自アプリ、AI機能、HTMLテンプレートはまだ追加していません。

VS Codeでこのフォルダを開き、「Dev Containers: Reopen in Container」を実行すると同じWebサーバーの `/var/www/html` が開きます。起動済みコンテナへ接続する場合は `app-intelligence-web` を選びます。以前の `app-intelligence-ubuntu` は別のコンテナです。

```sh
docker compose exec django python --version
docker compose exec django python -m django --version
docker compose exec django python -c "import torch; print(torch.__version__)"
docker compose logs -f django
docker compose down
```

Djangoの `runserver` はローカル開発用です。インターネットへの公開用途ではありません。Macの127.0.0.1だけに公開します。ユーザーはdeveloper、bashあり、sudoなし。コンテナ内のPython仮想環境は `/opt/venv` です。

DockerfileはPythonのUbuntuパッケージリビジョンも固定しています。将来そのリビジョンが配信終了した場合は `PYTHON_DEB_VERSION` の明示更新が必要です。

DjangoのSECRET_KEYは環境変数 `DJANGO_SECRET_KEY` で渡せます。未指定の場合は起動時に生成します。秘密情報・ローカルDB・モデルファイルはGitへ含めません。
