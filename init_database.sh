#!/bin/bash
set -e

echo "Initializare baza de date..."

DB_NAME="evidenta"
DB_USER="postgres"

psql -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f init.sql
psql -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f triggere_2.sql
psql -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f proceduri_cursoare_3.sql
psql -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f vederi_4.sql
psql -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f securitate_triggere_5.sql

echo "Baza de date a fost inițializată cu succes"
