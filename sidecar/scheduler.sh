#!/bin/bash

echo "--- Scheduler pornit. Astept baza de date... ---"
sleep 10

while true; do
    CURRENT_DATE=$(date +%Y%m%d_%H%M%S)
    
    echo "[$CURRENT_DATE] Rulare task-uri programate..."

    # --- JOB 1: Mentenanta (Procedura SQL: Verificare ITP) ---
    export PGPASSWORD=$POSTGRES_PASSWORD
    psql -h abd -U $POSTGRES_USER -d $POSTGRES_DB -c "CALL prc_job_verificare_itp_zilnic();"
    
    # --- JOB 2: Backup Strategy (pg_dump pe volumul partajat) ---
    BACKUP_FILE="/backups/backup_$CURRENT_DATE.sql"
    pg_dump -h abd -U $POSTGRES_USER $POSTGRES_DB > $BACKUP_FILE
    
    echo "Status: Job ITP rulat. Backup salvat in: $BACKUP_FILE"

    ls -tp /backups/backup_*.sql | tail -n +4 | xargs -I {} rm -- {}

    echo "Astept 60 de secunde pana la urmatoarea rulare..."
    sleep 60 # 86400
done