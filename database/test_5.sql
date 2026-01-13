-- Testare Trigger Audit

UPDATE amenzi_emise SET status = 'Platit' WHERE id = 1;

-- Verificam logul
SELECT * FROM log_operatiuni ORDER BY id DESC;