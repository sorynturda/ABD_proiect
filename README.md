#### Run the following script to create the docker postgres database

```bash
$ ./create_docker_postgres.sh
```

then insinde the docker container, in **/scripts** folder run:

```bash
$ ./init_database.sh
```

this will create all the tables, procedures, triggers, cursors and views.

Open **PgAdmin**, connect to the database (the port is exposed on 5432) and populate the database, which is **populare_db.sql** then test it.