-- Testare Procedura Plata cu Reducere

-- Pas 1: Aflam ID-ul amenzii neplatite a firmei
SELECT id, suma_initiala, data_emitere FROM amenzi_emise WHERE entitate_id = (SELECT id FROM entitati WHERE nume = 'SC TRANSPORT RAPID SRL');
-- prc_inregistreaza_plata(id_amenda, suma_de_plata)
-- Pas 2: Incercam sa platim prea putin (ex: 500 RON). Procedura trebuie sa dea eroare.
CALL prc_inregistreaza_plata(3, 500); 

-- Pas 3: Se plateste suma corecta redusa (1000 RON). Procedura trebuie sa accepte.
CALL prc_inregistreaza_plata(3, 1000);

-- Pas 4: Verificare status statusul
SELECT * FROM amenzi_emise WHERE id = 3;