-- 1. Agențiile (Cine dă amenda)
INSERT INTO agentii_emitente (nume_institutie, localitate, judet) VALUES 
('Brigada Rutiera Bucuresti', 'Bucuresti', 'Bucuresti'),
('IPJ Cluj - Serviciul Rutier', 'Cluj-Napoca', 'Cluj'),
('Politie Locala Sector 1', 'Bucuresti', 'Bucuresti'),
('CNAIR - Control Rovinieta', 'National', 'Toata tara'),
('IPJ Timis', 'Timisoara', 'Timis');

-- 2. Nomenclatorul de Amenzi (Diverse gravitați)
INSERT INTO nomenclator_amenzi (cod_articol, descriere, valoare_standard, puncte_penalizare) VALUES
('VIT-10', 'Depasire viteza 10-20 km/h', 290.00, 2),
('VIT-30', 'Depasire viteza 31-40 km/h', 870.00, 4),
('VIT-50', 'Depasire viteza 50+ km/h', 1305.00, 9), -- Periculos
('CENT-01', 'Nepurtarea centurii de siguranta', 435.00, 2),
('TEL-01', 'Folosirea telefonului la volan', 580.00, 6),
('PRC-INTERZIS', 'Oprire interzisa', 290.00, 2),
('RCA-LIPSA', 'Lipsa asigurare RCA', 2000.00, 0), -- Fara puncte, doar bani
('ITP-EXP', 'ITP Expirat', 1500.00, 0);

-- 3. Entitatile
INSERT INTO entitati (nume, cnp_cui, adresa, tip, stare_permis) VALUES
-- Persoane Fizice
('Popescu Ion', '1900101123456', 'Str. Lalelelor 1, Bucuresti', 'Fizica', 'Activ'), -- Sofer normal
('Ionescu Maria', '2950505123456', 'Str. Pacii 10, Cluj', 'Fizica', 'Activ'), -- Sofer model (fara amenzi)
('Viteazu George', '1880808123456', 'Bd. Unirii 5, Bucuresti', 'Fizica', 'Activ'), -- Candidat la suspendare
('Batranul Vasile', '1500101123456', 'Sat Viscri, Brasov', 'Fizica', 'Activ'), -- Are masina veche

-- Persoane Juridice
('SC TRANSPORT RAPID SRL', 'RO998877', 'Zona Industriala Vest', 'Juridica', 'Activ'), -- Flota mare
('SC PIZZA DELIVERY SRL', 'RO112233', 'Centru Vechi', 'Juridica', 'Activ');

-- 4. Populăm Vehiculele
INSERT INTO vehicule (numar_inmatriculare, serie_sasiu, marca, model, data_expirare_itp, data_expirare_rca) VALUES
('B-101-POP', 'SASIULOGAN001', 'Dacia', 'Logan', '2026-05-20', '2026-06-01'), -- Masina lui Ion
('CJ-20-MAR', 'SASIUFORD002', 'Ford', 'Focus', '2025-12-01', '2026-01-15'), -- Masina Mariei
('B-666-BAD', 'SASIBMW003', 'BMW', 'X6', '2026-08-01', '2026-08-01'), -- Masina lui George (Viteazu)
('BV-50-OLD', 'SASIDACIA1300', 'Dacia', '1310', '2023-01-01', '2023-01-01'), -- ITP si RCA Expirate (Vasile)
('B-99-TRN', 'SASITRUCK01', 'Mercedes', 'Sprinter', '2025-10-10', '2025-11-11'), -- Transport SRL
('B-98-TRN', 'SASITRUCK02', 'Mercedes', 'Sprinter', '2025-10-10', '2025-11-11'), -- Transport SRL
('IF-01-PIZ', 'SASIMATIZ01', 'Daewoo', 'Matiz', '2026-02-01', '2026-02-01'); -- Pizza SRL

-- 5. Istoric Proprietari
INSERT INTO istoric_proprietari (vehicul_id, entitate_id, data_start, data_sfarsit) VALUES
-- Proprietari actuali
(1, 1, '2020-01-01', NULL), -- Ion are Loganul
(2, 2, '2022-06-01', NULL), -- Maria are Fordul
(3, 3, '2023-01-01', NULL), -- George are BMW-ul
(4, 4, '2010-01-01', NULL), -- Vasile are Dacia veche
(5, 5, '2021-01-01', NULL), -- Firma Transport
(6, 5, '2021-01-01', NULL), -- Firma Transport
(7, 6, '2023-05-01', NULL), -- Firma Pizza

-- Istoric vechi (Masina vanduta)
(3, 1, '2019-01-01', '2022-12-31'); -- Ion a avut BMW-ul inainte sa il vanda lui George

-- 6. Generare Amenzi

-- Scenariul 1: George "Viteazu" acumuleaza puncte (dar inca nu e suspendat, are nevoie de inca una)
-- Luam ID-ul lui George si al BMW-ului
INSERT INTO amenzi_emise (vehicul_id, entitate_id, agentie_id, nomenclator_id, data_emitere, status) VALUES
((SELECT id FROM vehicule WHERE numar_inmatriculare='B-666-BAD'), (SELECT id FROM entitati WHERE nume='Viteazu George'), 1, (SELECT id FROM nomenclator_amenzi WHERE cod_articol='VIT-50'), CURRENT_DATE - INTERVAL '10 days', 'Neplatit'), -- 9 puncte
((SELECT id FROM vehicule WHERE numar_inmatriculare='B-666-BAD'), (SELECT id FROM entitati WHERE nume='Viteazu George'), 1, (SELECT id FROM nomenclator_amenzi WHERE cod_articol='TEL-01'), CURRENT_DATE - INTERVAL '5 days', 'Neplatit');  -- 6 puncte (Total 15)

-- Scenariul 2: Firma Transport primeste amenda (NU trebuie sa primeasca puncte, chiar daca soferul a gresit, amenda e pe firma)
INSERT INTO amenzi_emise (vehicul_id, entitate_id, agentie_id, nomenclator_id, data_emitere, status) VALUES
((SELECT id FROM vehicule WHERE numar_inmatriculare='B-99-TRN'), (SELECT id FROM entitati WHERE nume='SC TRANSPORT RAPID SRL'), 4, (SELECT id FROM nomenclator_amenzi WHERE cod_articol='RCA-LIPSA'), CURRENT_DATE - INTERVAL '2 days', 'Neplatit');

-- Scenariul 3: Vasile are amenda veche neplatita (mai veche de 15 zile - nu mai prinde reducere)
INSERT INTO amenzi_emise (vehicul_id, entitate_id, agentie_id, nomenclator_id, data_emitere, status) VALUES
((SELECT id FROM vehicule WHERE numar_inmatriculare='BV-50-OLD'), (SELECT id FROM entitati WHERE nume='Batranul Vasile'), 2, (SELECT id FROM nomenclator_amenzi WHERE cod_articol='ITP-EXP'), CURRENT_DATE - INTERVAL '40 days', 'Neplatit');

-- Scenariul 4: Popescu Ion a platit deja o amenda
INSERT INTO amenzi_emise (vehicul_id, entitate_id, agentie_id, nomenclator_id, data_emitere, status) VALUES
((SELECT id FROM vehicule WHERE numar_inmatriculare='B-101-POP'), (SELECT id FROM entitati WHERE nume='Popescu Ion'), 3, (SELECT id FROM nomenclator_amenzi WHERE cod_articol='PRC-INTERZIS'), CURRENT_DATE - INTERVAL '20 days', 'Platit');

-- Inregistram si plata in istoric pentru scenariul 4
INSERT INTO plati (amenda_id, data_plata, suma_achitata) VALUES
((SELECT id FROM amenzi_emise WHERE entitate_id = (SELECT id FROM entitati WHERE nume='Popescu Ion') AND status='Platit' LIMIT 1), CURRENT_DATE - INTERVAL '18 days', 145.00);