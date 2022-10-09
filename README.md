# RailsAPI ×　React-ts (vite) by Docker

## TODOs

- RSpec, RuboCop 等の設定を追加する
- 本番環境でも使える構成なのか試す
  - db周りの設定の意味を理解
  - `Dockerfile` の中身を完全に理解
- 記事を書く
  - 導入してあるリンター、フォーマッタの説明を追記する

## バージョン情報

- [Ruby](https://www.ruby-lang.org/en/) 3.0.0
- [Rails](https://rubyonrails.org/) 6.1.4
- [React](https://reactjs.org/) 18.2.0
- [TypeScript](https://www.typescriptlang.org/) 4.8.2
- [Docker](https://docs.docker.com/)
- [PostgreSQL](https://www.postgresql.org/) 11

## セットアップ

```shell
$ git clone https://github.com/NasuPanda/rails-react-ts-vite-docker-example.git && cd rails-react-ts-vite-docker-example

# セットアップの実行
$ docker-compose run frontend yarn
$ docker-compose run backend bin/rails db:create db:migrate

# コンテナの起動
$ docker-compose up -d
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

### backend

次のような `Gemfile` , その他ディレクトリ等を用意。

```ruby
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.6'
# gem 'rails', '~> 6.0.3'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 5.6'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.11'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 3.0'
  gem 'listen', '~> 3.7'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  # Automate routing spec
  gem 'route_mechanic'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'rack-cors', require: 'rack/cors'
```

ディレクトリ構成

```
.
├── Gemfile
├── Gemfile.lock
├── LICENSE
├── README.md
├── Rakefile
├── app
├── bin
├── config
├── config.ru
├── db
├── lib
├── log
├── prehook
├── public
├── test
├── tmp
└── vendor
```

## 参考

[りあクト！ TypeScriptで始めるつらくないReact開発 第4版【① 言語・環境編】 - くるみ割り書房 ft. React - BOOTH](https://oukayuka.booth.pm/items/2368045)

[ohbarye/rails-react-typescript-docker-example: An example app built on Ruby on Rails + React.js + TypeScript + Docker Compose](https://github.com/ohbarye/rails-react-typescript-docker-example)

[Docker でフロントエンドとAPIを開発してみた - to-R Media](https://www.to-r.net/media/docer-cra/)
