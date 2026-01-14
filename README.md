#### Run docker compose up to create the databases. If volume is cached, remove it. 

```bash
$ docker compose up -d --build
```


this will create all the tables, procedures, triggers, cursors and views.

Open **PgAdmin**, connect to the database (the port is exposed on 5432) and populate the database, which is **populare_db.sql** then test it.

Restore from a backup:

```bash
$ docker exec -it scheduler bash -c "psql -h abd -U postgres -d evidenta < backup_file.sql"
```