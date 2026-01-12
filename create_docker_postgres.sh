#!/bin/bash

docker run -d \
-e POSTGRES_USER=postgres \
-e POSTGRES_PASSWORD=postgres \
-e POSTGRES_DB=evidenta \
-p 5432:5432 \
--name abd \
-v abd_data:/var/lib/postgresql/data \
-v $(pwd):/scripts \
postgres:16
