#!/bin/bash
set -e

echo "Initializare baza de date..."

DB_NAME="evidenta"
DB_USER="postgres"

psql -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f /scripts/init.sql
psql -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f /scripts/triggere_2.sql
psql -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f /scripts/proceduri_cursoare_3.sql
psql -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f /scripts/vederi_4.sql
psql -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f /scripts/securitate_triggere_5.sql

echo "Baza de date a fost inițializată cu succes"
