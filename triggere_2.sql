-- 2.1 Trigger pentru Popularea Automata a Sumei (la emitere)
CREATE OR REPLACE FUNCTION fn_setare_suma_amenda()
RETURNS TRIGGER AS $$
BEGIN
    SELECT valoare_standard INTO NEW.suma_initiala 
    FROM nomenclator_amenzi WHERE id = NEW.nomenclator_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_insert_amenda_suma
BEFORE INSERT ON amenzi_emise
FOR EACH ROW EXECUTE FUNCTION fn_setare_suma_amenda();


-- 2.2 Trigger Audit (Cerința: Trigger DML)
-- Salvează în log_operatiuni orice UPDATE pe amenzi
CREATE OR REPLACE FUNCTION fn_audit_amenzi()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO log_operatiuni(nume_tabel, utilizator_db, tip_operatie, detalii)
        VALUES ('amenzi_emise', CURRENT_USER, 'UPDATE', 
                jsonb_build_object('id_amenda', OLD.id, 'status_vechi', OLD.status, 'status_nou', NEW.status));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_update_amenzi
AFTER UPDATE ON amenzi_emise
FOR EACH ROW EXECUTE FUNCTION fn_audit_amenzi();


-- 2.3 Trigger Puncte Penalizare (Suspendare Permis)
CREATE OR REPLACE FUNCTION fn_check_puncte()
RETURNS TRIGGER AS $$
DECLARE
    total_puncte INT;
    v_tip tip_persoana;
BEGIN
    SELECT tip INTO v_tip FROM entitati WHERE id = NEW.entitate_id;
    
    IF v_tip = 'Fizica' THEN
        SELECT COALESCE(SUM(n.puncte_penalizare), 0) INTO total_puncte
        FROM amenzi_emise a
        JOIN nomenclator_amenzi n ON a.nomenclator_id = n.id
        WHERE a.entitate_id = NEW.entitate_id 
          AND a.data_emitere > (CURRENT_DATE - INTERVAL '180 days');
          
        IF total_puncte >= 20 THEN
            UPDATE entitati SET stare_permis = 'Suspendat' WHERE id = NEW.entitate_id;
            RAISE NOTICE 'ATENTIE: Permisul proprietarului % a fost suspendat! Puncte: %', NEW.entitate_id, total_puncte;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_after_insert_amenda
AFTER INSERT ON amenzi_emise
FOR EACH ROW EXECUTE FUNCTION fn_check_puncte();
