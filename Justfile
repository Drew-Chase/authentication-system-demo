#!/usr/bin/env just --justfile

set windows-shell := ["powershell.exe", "-NoLogo", "-NoProfile", "-Command"]
set shell := ["bash", "-c"]

default:
    @just --list

install:
    composer install
    pnpm i

dev: install
    pnpm run dev

[windows]
build: clean install
    pnpm run build
    @echo "Coping Environment variables and PHP"
    @Copy-Item ./api, ./.env.production, ./.htaccess, ./nginx.conf, ./composer.json, ./set_root.php ./dist/ -Recurse -Force
    @Rename-Item ./dist/.env.production .env -Force

[linux]
[macos]
build: install
    pnpm run build
    @cp -r ./api ./.env ./.htaccess ./nginx.conf ./composer.json ./set_root.php ./dist/

[windows]
rename name="":
    @powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File ./scripts/rename.ps1 "{{ name }}"

[linux]
[macos]
rename name="":
    @bash ./scripts/rename.sh "{{ name }}"

[windows]
clean:
    @if (Test-Path .\dist\) { Remove-Item .\dist\ -Force -Recurse }

[linux]
clean:
    @rm -rf ./dist

[macos]
clean:
    @rm -rdf ./dist
