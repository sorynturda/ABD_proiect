-- 5.1 Trigger DDL (Preventie stergere tabele)
CREATE OR REPLACE FUNCTION fn_prevent_drop()
RETURNS event_trigger AS $$
BEGIN
    RAISE EXCEPTION 'Este interzisa stergerea tabelelor in productie!';
END;
$$ LANGUAGE plpgsql;

-- trigger pentru a preveni drop-ul la tabele 
-- CREATE EVENT TRIGGER trg_no_drop ON ddl_command_start WHEN TAG IN ('DROP TABLE') EXECUTE FUNCTION fn_prevent_drop();


-- 5.2 Roluri si Utilizatori
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'ofiter_politie') THEN
    CREATE ROLE ofiter_politie;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'casier') THEN
    CREATE ROLE casier;
  END IF;
END
$$;

-- Granturi
GRANT SELECT, INSERT, UPDATE ON amenzi_emise, entitati TO ofiter_politie;
GRANT SELECT ON amenzi_emise TO casier;
GRANT INSERT ON plati TO casier;
