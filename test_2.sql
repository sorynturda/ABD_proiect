-- Testare Trigger Suspendare Permis

-- 1. Verificare starii inainte
SELECT nume, stare_permis FROM entitati WHERE nume = 'Viteazu George';

-- 2. Primeste inca o amenda (Telefon la volan - 6 puncte)
INSERT INTO amenzi_emise (vehicul_id, entitate_id, agentie_id, nomenclator_id) 
VALUES (
    (SELECT id FROM vehicule WHERE numar_inmatriculare='B-666-BAD'), 
    (SELECT id FROM entitati WHERE nume='Viteazu George'), 
    1, 
    (SELECT id FROM nomenclator_amenzi WHERE cod_articol='TEL-01')
);

-- 3. Verifcarea starii dupa (ar trebui sa fie SUSPENDAT)
SELECT nume, stare_permis FROM entitati WHERE nume = 'Viteazu George';