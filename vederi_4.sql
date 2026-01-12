-- Vedere complexa: Dosarul masinii
CREATE OR REPLACE VIEW v_dosar_auto AS
SELECT 
    v.numar_inmatriculare,
    v.marca,
    e.nume AS proprietar_curent,
    CASE 
        WHEN v.data_expirare_itp < CURRENT_DATE THEN 'ITP EXPIRAT'
        ELSE 'ITP VALID'
    END AS stare_itp,
    COUNT(a.id) AS total_amenzi
FROM vehicule v
JOIN istoric_proprietari ip ON v.id = ip.vehicul_id AND ip.data_sfarsit IS NULL
JOIN entitati e ON ip.entitate_id = e.id
LEFT JOIN amenzi_emise a ON v.id = a.vehicul_id
GROUP BY v.id, e.nume, v.data_expirare_itp;
