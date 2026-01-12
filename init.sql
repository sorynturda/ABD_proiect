DROP TABLE IF EXISTS plati CASCADE;
DROP TABLE IF EXISTS amenzi_emise CASCADE;
DROP TABLE IF EXISTS istoric_proprietari CASCADE;
DROP TABLE IF EXISTS vehicule CASCADE;
DROP TABLE IF EXISTS entitati CASCADE;
DROP TABLE IF EXISTS nomenclator_amenzi CASCADE;
DROP TABLE IF EXISTS agentii_emitente CASCADE;
DROP TABLE IF EXISTS log_operatiuni CASCADE;

DROP TYPE IF EXISTS tip_persoana;
DROP TYPE IF EXISTS status_amenda;
DROP TYPE IF EXISTS status_permis;

CREATE TYPE tip_persoana AS ENUM ('Fizica', 'Juridica');
CREATE TYPE status_amenda AS ENUM ('Neplatit', 'Platit');
CREATE TYPE status_permis AS ENUM ('Activ', 'Suspendat');

CREATE TABLE agentii_emitente (
    id SERIAL PRIMARY KEY,
    nume_institutie VARCHAR(100) NOT NULL,
    localitate VARCHAR(50),
    judet VARCHAR(50)
);

CREATE TABLE nomenclator_amenzi (
    id SERIAL PRIMARY KEY,
    cod_articol VARCHAR(20) UNIQUE NOT NULL,
    descriere TEXT NOT NULL,
    valoare_standard DECIMAL(10, 2) NOT NULL,
    puncte_penalizare INTEGER DEFAULT 0
);

CREATE TABLE entitati (
    id SERIAL PRIMARY KEY,
    nume VARCHAR(100) NOT NULL,
    cnp_cui VARCHAR(20) UNIQUE NOT NULL,
    adresa TEXT,
    telefon VARCHAR(15),
    tip tip_persoana NOT NULL,
    stare_permis status_permis DEFAULT 'Activ',
    CONSTRAINT chk_cnp_lungime CHECK (length(cnp_cui) >= 6)
);

CREATE TABLE vehicule (
    id SERIAL PRIMARY KEY,
    numar_inmatriculare VARCHAR(15) UNIQUE NOT NULL,
    serie_sasiu VARCHAR(17) UNIQUE NOT NULL,
    marca VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    data_expirare_itp DATE NOT NULL,
    data_expirare_rca DATE NOT NULL
);

CREATE TABLE log_operatiuni (
    id SERIAL PRIMARY KEY,
    nume_tabel VARCHAR(50),
    utilizator_db VARCHAR(50),
    data_operatie TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tip_operatie VARCHAR(10),
    detalii JSONB
);

CREATE TABLE istoric_proprietari (
    id SERIAL PRIMARY KEY,
    vehicul_id INTEGER REFERENCES vehicule(id) ON DELETE CASCADE,
    entitate_id INTEGER REFERENCES entitati(id) ON DELETE RESTRICT,
    data_start DATE DEFAULT CURRENT_DATE,
    data_sfarsit DATE,
    CONSTRAINT chk_perioada CHECK (data_sfarsit IS NULL OR data_sfarsit >= data_start)
);

CREATE TABLE amenzi_emise (
    id SERIAL PRIMARY KEY,
    vehicul_id INTEGER REFERENCES vehicule(id),
    entitate_id INTEGER REFERENCES entitati(id), -- Proprietarul responsabil
    agentie_id INTEGER REFERENCES agentii_emitente(id),
    nomenclator_id INTEGER REFERENCES nomenclator_amenzi(id),
    data_emitere DATE DEFAULT CURRENT_DATE,
    suma_initiala DECIMAL(10, 2), -- Preluata din nomenclator
    status status_amenda DEFAULT 'Neplatit'
);

CREATE TABLE plati (
    id SERIAL PRIMARY KEY,
    amenda_id INTEGER REFERENCES amenzi_emise(id) ON DELETE CASCADE,
    data_plata DATE DEFAULT CURRENT_DATE,
    suma_achitata DECIMAL(10, 2) NOT NULL
);
