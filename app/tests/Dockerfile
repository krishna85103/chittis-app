FROM python:3.12-alpine

WORKDIR /tests

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY test_app.py .

CMD ["pytest", "-v", "test_app.py"]
