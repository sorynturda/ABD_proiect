-- 3.1 Procedura de Plata cu Logica de Reducere (Business Logic)
-- Daca platesti in <15 zile, acceptam jumatate din minim.
CREATE OR REPLACE PROCEDURE prc_inregistreaza_plata(
    p_amenda_id INT, 
    p_suma_oferita DECIMAL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_data_emitere DATE;
    v_suma_standard DECIMAL;
    v_suma_redusa DECIMAL;
BEGIN
    SELECT data_emitere, suma_initiala INTO v_data_emitere, v_suma_standard
    FROM amenzi_emise WHERE id = p_amenda_id;
    
    v_suma_redusa := v_suma_standard / 2;
    
    IF (CURRENT_DATE - v_data_emitere) <= 15 THEN
        IF p_suma_oferita >= v_suma_redusa THEN
            INSERT INTO plati(amenda_id, suma_achitata) VALUES (p_amenda_id, p_suma_oferita);
            UPDATE amenzi_emise SET status = 'Platit' WHERE id = p_amenda_id;
            RAISE NOTICE 'Plata acceptata cu reducere!';
        ELSE
            RAISE EXCEPTION 'Suma insuficienta. Necesar minim: % (Redus)', v_suma_redusa;
        END IF;
    ELSE
        IF p_suma_oferita >= v_suma_standard THEN
            INSERT INTO plati(amenda_id, suma_achitata) VALUES (p_amenda_id, p_suma_oferita);
            UPDATE amenzi_emise SET status = 'Platit' WHERE id = p_amenda_id;
            RAISE NOTICE 'Plata integrala acceptata.';
        ELSE
            RAISE EXCEPTION 'Termen reducere depasit. Necesar: %', v_suma_standard;
        END IF;
    END IF;
END;
$$;

-- 3.2 Procedura cu CURSOR (Raportare Restantieri)
CREATE OR REPLACE PROCEDURE prc_raport_restantieri()
LANGUAGE plpgsql
AS $$
DECLARE
    cur_datornici CURSOR FOR 
        SELECT e.nume, a.suma_initiala, a.data_emitere
        FROM amenzi_emise a
        JOIN entitati e ON a.entitate_id = e.id
        WHERE a.status = 'Neplatit';
        
    rec RECORD;
BEGIN
    OPEN cur_datornici;
    LOOP
        FETCH cur_datornici INTO rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Datornic: % | Suma: % | Data: %', rec.nume, rec.suma_initiala, rec.data_emitere;
    END LOOP;
    CLOSE cur_datornici;
END;
$$;
-- 3.3 Procedura care va fi rulată de Job
CREATE OR REPLACE PROCEDURE prc_job_verificare_itp_zilnic()
LANGUAGE plpgsql
AS $$
DECLARE
    v_nr_expirate INT;
BEGIN
    SELECT COUNT(*) INTO v_nr_expirate 
    FROM vehicule 
    WHERE data_expirare_itp < CURRENT_DATE;

    IF v_nr_expirate > 0 THEN
        INSERT INTO log_operatiuni(nume_tabel, utilizator_db, tip_operatie, detalii)
        VALUES (
            'vehicule', 
            'SYSTEM_JOB', 
            'ALERT', 
            jsonb_build_object('mesaj', 'Job zilnic: Vehicule cu ITP expirat identificate', 'cantitate', v_nr_expirate)
        );
        
        RAISE NOTICE 'Job finalizat: Au fost gasite % vehicule cu ITP expirat.', v_nr_expirate;
    ELSE
        RAISE NOTICE 'Job finalizat: Nicio neregula gasita astazi.';
    END IF;
END;


$$;
-- 3.3 Procedura Reinnoire ITP
CREATE OR REPLACE PROCEDURE prc_reinnoire_itp(
    p_numar_inmatriculare VARCHAR,
    p_statie_itp VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_vehicul_id INT;
    v_data_noua DATE;
BEGIN
    SELECT id INTO v_vehicul_id FROM vehicule WHERE numar_inmatriculare = p_numar_inmatriculare;
    
    IF v_vehicul_id IS NULL THEN
        RAISE EXCEPTION 'Vehiculul cu numarul % nu exista!', p_numar_inmatriculare;
    END IF;

    v_data_noua := CURRENT_DATE + INTERVAL '1 year';

    UPDATE vehicule 
    SET data_expirare_itp = v_data_noua 
    WHERE id = v_vehicul_id;

    INSERT INTO log_operatiuni(nume_tabel, utilizator_db, tip_operatie, detalii)
    VALUES (
        'vehicule', 
        CURRENT_USER, 
        'ITP_RENEW', 
        jsonb_build_object(
            'nr_inmatriculare', p_numar_inmatriculare, 
            'statie', p_statie_itp,
            'data_noua_expirare', v_data_noua
        )
    );

    RAISE NOTICE 'ITP reinnoit cu succes pentru % pana la data de %', p_numar_inmatriculare, v_data_noua;
END;
$$;