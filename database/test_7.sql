CALL prc_reinnoire_itp('BV-50-OLD', 'Service Auto Total SRL');

SELECT numar_inmatriculare, data_expirare_itp FROM vehicule WHERE numar_inmatriculare = 'BV-50-OLD';

SELECT * FROM log_operatiuni WHERE tip_operatie = 'ITP_RENEW' ORDER BY id DESC;