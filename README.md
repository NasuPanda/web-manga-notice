# RailsAPI ×　React-ts (vite) by Docker

## TODOs

- 本番環境でも使える構成なのか試す
- 記事を書く
  - 導入してあるリンター、フォーマッタの説明を追記する

## 入っているもの

- [Ruby](https://www.ruby-lang.org/en/) 3.0.0
- [Rails](https://rubyonrails.org/) 6.1.4
- [RSpec](https://rspec.info/)
- [rubocop](https://docs.rubocop.org/)
- [Solargraph](https://solargraph.org/) : Ruby のコード補完
- [Node](https://nodejs.org/ja/) 18.7.0
- [React](https://reactjs.org/) 18.2.0
- [TypeScript](https://www.typescriptlang.org/) 4.8.2
- [Docker](https://docs.docker.com/)
- [PostgreSQL](https://www.postgresql.org/) 11

## セットアップ

### 開発環境
```shell
git clone https://github.com/NasuPanda/web-manga-notice.git && cd web-manga-notice

docker-compose run frontend yarn
docker-compose run backend bin/rails db:create db:migrate
docker-compose run backend bin/rails g rspec:install

# コンテナの起動
docker-compose up -d

# localhost:3000/greetings/hello => Rails動作確認
# localhost:9999 => React動作確認

# pre-commit の登録
cp pre-commit .git/hooks/pre-commit
```

### 本番環境

- `.env` ファイルの中身を修正
- `credentials.yml.enc` と `master.key` が必要

```sh
git clone https://github.com/NasuPanda/web-manga-notice.git && cd web-manga-notice

# ローカルの `master.key` を `backend/config` 配下にコピーしてくる
vim backend/config/master.key

# 本番環境設定で実行する
docker-compose -f docker-compose.production.yml run frontend yarn \
  && docker-compose -f docker-compose.production.yml run backend bin/rails db:setup RAILS_ENV=production \
  && docker-compose -f docker-compose.production.yml run backend bin/rails g rspec:install

# コンテナの起動
docker-compose -f docker-compose.production.yml up -d
```


## メモ: 環境構築手順

どのような手順で環境構築したか。

### フロントエンド

`/frontend` ディレクトリを作成。

次のような `package.json` と、各種設定ファイルを用意。

```json
{
  "name": "presentation-container-timer",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "scripts": {
    "start": "vite --port 9999 --host",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "lint:es": "eslint 'src/**/*.{js,jsx,ts,tsx}'",
    "lint:es:fix": "eslint --fix 'src/**/*.{js,jsx,ts,tsx}'",
    "lint:style": "stylelint 'src/**/*.{css,less,sass,scss}'",
    "lint:style:fix": "stylelint --fix 'src/**/*.{css,less,sass,scss}'",
    "lint": "npm run --silent lint:style; npm run --silent lint:es",
    "lint:fix": "npm run --silent lint:style:fix; npm run --silent lint:es:fix",
    "format": "prettier --write --loglevel=warn 'src/**/*.{js,jsx,ts,tsx,html,json,gql,graphql}'",
    "fix": "npm run --silent format; npm run --silent lint:fix",
    "preinstall": "npx typesync || :",
    "prepare": "npx simple-git-hooks || :"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/eslint": "^8.4.5",
    "@types/prettier": "^2.7.0",
    "@types/react": "^18.0.18",
    "@types/react-dom": "^18.0.6",
    "@typescript-eslint/eslint-plugin": "^5.33.1",
    "@vitejs/plugin-react": "^2.0.1",
    "eslint": "^8.22.0",
    "eslint-config-prettier": "^8.5.0",
    "eslint-config-standard-with-typescript": "^22.0.0",
    "eslint-plugin-import": "^2.26.0",
    "eslint-plugin-jsx-a11y": "^6.6.1",
    "eslint-plugin-n": "^15.2.4",
    "eslint-plugin-promise": "^6.0.0",
    "eslint-plugin-react": "^7.30.1",
    "eslint-plugin-react-hooks": "^4.6.0",
    "lint-staged": "^13.0.3",
    "prettier": "^2.7.1",
    "simple-git-hooks": "^2.8.0",
    "stylelint": "^14.10.0",
    "stylelint-config-recess-order": "^3.0.0",
    "stylelint-config-standard": "^27.0.0",
    "stylelint-order": "^5.0.0",
    "typescript": "^4.8.2",
    "vite": "^3.0.9",
    "vite-tsconfig-paths": "^3.5.0"
  },
  "lint-staged": {
    "src/**/*.{js,jsx,ts,tsx}": [
      "prettier --write --loglevel=warn",
      "eslint --fix --quiet"
    ],
    "src/**/*.{css,less,sass,scss}": [
      "stylelint --fix --quiet"
    ],
    "src/**/*.{html,json,gql,graphql}": [
      "prettier --write --loglevel=error"
    ]
  },
  "simple-git-hooks": {
    "pre-commit": ". ./lint-staged-each.sh"
  }
}
```

設定ファイル

- `.gitignore`
- `.eslintignore`
- `.eslintrc.json`
- `.prettierrc.json`
- `.stylelintrc.json`
- `tsconfig.json`
- `tsconfig.node.json`
- `vite.config.ts`

#### vite

vite を使う場合。

参考

- [Configuring Vite | Vite](https://vitejs.dev/config/)
- [Env Variables and Modes | Vite](https://vitejs.dev/guide/env-and-mode.html#env-files)

##### `--host` オプション

`vite` コマンドに `--host` オプションを付ける。方法は次のいずれか。

- `package.json` の `scripts` に `"vite --host"` と書く
- `vite.config.ts` に `host: true` というオプションを書く(下に例)

```ts
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tsconfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  plugins: [react(), tsconfigPaths()],
  // server settings
  server: {
    host: true,
  },
});
```

##### 環境変数

環境変数 `HOST` に値をセットしておく。
vite はデフォルトで `.env` もしくは `.env.[environment]` (environment には development, production などが入る) を読み込むので、その中に記述する。

```.env
HOST=0.0.0.0
```

環境変数をアプリケーションから使用したい場合、`/src` 配下に `app-env.d.ts` というファイルを用意。
`.env` ファイルに記述した環境変数の型を定義する。

```ts
/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_APP_TITLE: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
```

参照する時は以下のようにする。

```ts
console.log(import.meta.env.VITE_APP_TITLE);
console.dir(import.meta.env);
```

### バックエンド

インストールしたい gem を記述した `Gemfile` , 必要なディレクトリを用意。

#### RSpec

`Gemfile` に以下を追記。

```rb
group :development, :test do
  # 省略...
  # RSpec
  gem 'rspec-rails'
	gem 'factory_bot_rails'
end
```

セットアップ。

```shell
# RSpecのセットアップ
docker-compose run backend bin/rails g rspec:install
```

#### Rubocop

`Gemfile` に必要な gem を追記、 `rubocop.yml` を作成。

```rb
group :development do
  # 省略...

  # Rubocop
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  # パフォーマンス低下につながるコードを指摘
	gem 'rubocop-performance', require: false
end
```

`.rubocop.yml` を追加する。

#### Gitフック

Rubocop をコミット前、プッシュ前に実行したい。

参考 : [Docker環境でもGitのcommitやpushの前にRubocopのチェックをする](https://zenn.dev/yamat47/articles/a9b0b4d937ce03b695e9)

`pre-commit` , `pre-push` を `.git/hooks` に作成する。

```sh
#!/bin/sh

# pre-commit

#!/bin/sh

INITIAL_MESSAGE="Rubocop(pre-commit)"
ERROR_MESSAGE="FailedToCommit."
SUCCESS_MESSAGE="CommitSucceeded."

if git diff --cached --name-only --diff-filter=AM | grep '\.rb$'; then
  echo -e "\e[32m$INITIAL_MESSAGE\e[m"
  # sedコマンド : /backend => .
  # ex: /backend/app => ./app
  git diff --cached --name-only --diff-filter=AM \
  | grep '\.rb$' \
    | sed -e "s/backend/./g" \
    | xargs docker-compose exec -T backend bundle exec rubocop \
        --fail-level R \
        --display-only-fail-level-offenses \
    && echo -e "\e[32m$SUCCESS_MESSAGE \e[m" \
    || echo -e "\e[31m$ERROR_MESSAGE \e[m"
fi
```

```sh
#!/bin/sh

# pre-push

#!/bin/sh

INITIAL_MESSAGE="Rubocop(pre-commit)"
ERROR_MESSAGE="FailedToCommit."
SUCCESS_MESSAGE="CommitSucceeded."

echo -e "\e[32m$INITIAL_MESSAGE\e[m"
docker-compose exec -T backend bundle exec rubocop ./**/*.rb \
  --fail-level R \
  --display-only-fail-level-offenses \
  && echo -e "\e[32m$SUCCESS_MESSAGE \e[m" \
  || echo -e "\e[31m$ERROR_MESSAGE \e[m"
```

```sh
cp pre-commit .git/hooks/
cp pre-push .git/hooks/
chmod a+x .git/hooks/pre-push
chmod a+x .git/hooks/pre-commit
```

#### Solagraph

`settings.json` に以下を追記。

```json
  // Solgagraph
  "solargraph.externalServer": {
    "host": "localhost",
    "port": 7658
  },
  "solargraph.transport": "external",
  "solargraph.logLevel": "debug",
  "solargraph.diagnostics": true,
  "solargraph.hover": false,
```

```Dockerfile
FROM ruby:3.0.0-alpine

RUN apk update
RUN apk add --no-cache --virtual .build-deps gcc make musl-dev build-base libxml2-dev libxslt-dev bash
RUN gem install solargraph
RUN solargraph download-core

WORKDIR /app

# Create Gemfile
RUN bundle init
RUN echo "gem 'solargraph'" >> Gemfile
# gem のインストール先を設定
RUN mkdir /bundle
RUN bundle config set --local path './bundle'
RUN bundle install

EXPOSE 7658
```

```yml
  # Ruby の補完に使う
  solargraph:
    container_name: solargraph
    build:
      context: .
      dockerfile: Dockerfile.solargraph
    command: bundle exec solargraph socket --host=0.0.0.0 --port=7658
    ports:
      - "7658:7658"
```

## 参考

[りあクト！ TypeScriptで始めるつらくないReact開発 第4版【① 言語・環境編】 - くるみ割り書房 ft. React - BOOTH](https://oukayuka.booth.pm/items/2368045)

[ohbarye/rails-react-typescript-docker-example: An example app built on Ruby on Rails + React.js + TypeScript + Docker Compose](https://github.com/ohbarye/rails-react-typescript-docker-example)

[Docker でフロントエンドとAPIを開発してみた - to-R Media](https://www.to-r.net/media/docer-cra/)

[Docker環境でsolargraphを使う方法 - Qiita](https://qiita.com/belion_freee/items/9e7ea981653237072d1e)

[Docker環境でもGitのcommitやpushの前にRubocopのチェックをする](https://zenn.dev/yamat47/articles/a9b0b4d937ce03b695e9)

[npakk/docker-solargraph: 開発環境で使うsolargraphをDockerコンテナとして利用する](https://github.com/npakk/docker-solargraph)
