-- Testare Procedura Plata fara Reducere
-- ID-ul amenzii lui Vasile
SELECT id, suma_initiala, data_emitere FROM amenzi_emise WHERE entitate_id = (SELECT id FROM entitati WHERE nume LIKE 'Batranul%');

-- Se plateste jumatate (750). Ar trebeui sa dea eroare "Termen reducere depasit".
CALL prc_inregistreaza_plata(4, 750);