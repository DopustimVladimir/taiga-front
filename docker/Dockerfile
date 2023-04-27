# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL

FROM nginx:1.24-bullseye
LABEL maintainer="support@taiga.io"

COPY docker/default.conf /etc/nginx/conf.d/default.conf
COPY docker/conf.json.template /conf.json.template
COPY docker/config_env_subst.sh /docker-entrypoint.d/30_config_env_subst.sh

COPY . /taiga-front
WORKDIR /taiga-front

RUN apt update; \
    apt install -y \
        bash \
        curl \
        git \
        subversion; \
    # Install nvm
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash; \
    export NVM_DIR="$HOME/.nvm"; \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; \
    # Install taiga-front core
    nvm install; \
    nvm use; \
    npm ci; \
    npx gulp deploy; \
    mv /conf.json.template dist/conf.json.template; \
    mv /taiga-front/dist/* /usr/share/nginx/html; \
    # Install taiga-front contribs
    mkdir /taiga/dist/plugins; \
    cd /taiga/dist/plugins; \
    svn export "https://github.com/kaleidos-ventures/taiga-contrib-slack/tags/6.6.0/front/dist" "slack"; \
    svn export "https://github.com/kaleidos-ventures/taiga-contrib-github-auth/tags/6.6.0/front/dist" "github-auth"; \
    svn export "https://github.com/kaleidos-ventures/taiga-contrib-gitlab-auth/tags/6.6.0/front/dist" "gitlab-auth"; \
    cd /; \
    # Prepare entrypoint
    chmod +x /docker-entrypoint.d/30_config_env_subst.sh; \
    # Remove garbage
    apt purge -y \
        bash \
        curl \
        git \
        subversion; \
    apt autoremove -y; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf /root/.cache; \
    rm -rf /taiga-front
