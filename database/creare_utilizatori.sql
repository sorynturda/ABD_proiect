CREATE USER u_casier WITH PASSWORD 'casier';
GRANT casier to u_casier;

CREATE USER u_ofiter WITH PASSWORD 'ofiter';
GRANT ofiter_politie TO u_ofiter;

GRANT USAGE ON SCHEMA public TO casier;
GRANT USAGE ON SCHEMA public TO ofiter_politie;