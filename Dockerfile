# 1. Python 이미지를 베이스로 사용
FROM python:3.9-slim

# 2. 작업 디렉토리 설정
WORKDIR /app

# 3. 시스템 의존성 설치
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# 4. requirements.txt를 컨테이너에 복사하고 의존성 설치
COPY mysite/requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# 4-1. MySQL 연동을 위한 파이썬 패키지 설치
RUN pip install --no-cache-dir mysqlclient

# 5. Django 애플리케이션 소스 복사
COPY . /app/

# 6. 정적 파일 및 미디어 파일을 Django가 사용할 디렉토리로 설정
RUN mkdir -p /app/staticfiles /app/media

# 7. 환경 변수 설정 (필요한 경우)
ENV PYTHONUNBUFFERED 1

# 8. 마이그레이션 및 정적 파일 수집
WORKDIR /app/mysite
# RUN python manage.py makemigrations
# RUN python manage.py migrate
RUN python manage.py collectstatic --noinput || true

# 9. 애플리케이션 실행
CMD ["python3", "manage.py", "runserver", "0.0.0.0:8000"]
EXPOSE 8000

