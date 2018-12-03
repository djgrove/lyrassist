FROM python:2.7

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app/

# get the dependency file
COPY ./requirements.txt .

# get dependencies for the project
RUN pip install -r requirements.txt --no-build-isolation

EXPOSE 8080
CMD ["python", "restful.py"]
