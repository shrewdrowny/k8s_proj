#!/bin/bash

set -euo pipefail

PROJECT_DIR=/home/vagrant/django_git/mysite

TEMP_DIR=/home/vagrant/django_git/__deploy_tmp__

REPO_URL=https://github.com/shrewdrowny/k8s_proj.git

BRANCH=main
# 또는 master

echo "[INFO] Deploying into: ${PROJECT_DIR}"

# 0) TEMP DIR 준비
rm -rf "${TEMP_DIR}"
mkdir -p "${TEMP_DIR}"

# 1) repo를 TEMP_DIR 에 clone
git clone -b ${BRANCH} "${REPO_URL}" "${TEMP_DIR}"

# 2) repo 안의 mysite/ 내용만 실제 PROJECT_DIR 로 복사
mkdir -p "${PROJECT_DIR}"
cp -r ${TEMP_DIR}/mysite/* "${PROJECT_DIR}/"

# TEMP 삭제
rm -rf "${TEMP_DIR}"

# 3) 가상환경
cd "${PROJECT_DIR}"
python3 -m venv venv || true
source venv/bin/activate

pip install --upgrade pip
pip install -r requirements.txt

# 4) Django 작업
python3 manage.py makemigrations --noinput || true
python3 manage.py migrate --noinput
python3 manage.py collectstatic --noinput

# 5) 기존 runserver 종료
pkill -f "manage.py runserver" || true

# 6) runserver 재시작
nohup python3 manage.py runserver 0.0.0.0:8000 \
    > ${PROJECT_DIR}/mysite_run.log 2>&1 &

echo "DEPLOY_OK $(date)"

