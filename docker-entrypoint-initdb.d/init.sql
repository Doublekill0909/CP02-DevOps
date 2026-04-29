CREATE DATABASE IF NOT EXISTS yugioh;
USE yugioh;

CREATE TABLE IF NOT EXISTS cartas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    tipo VARCHAR(100),
    ataque INT,
    defesa INT,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO cartas (nome, tipo, ataque, defesa) VALUES
('Blue-Eyes White Dragon', 'Dragão', 3000, 2500),
('Dark Magician', 'Mago', 2500, 2100),
('Red-Eyes Black Dragon', 'Dragão', 2400, 2000),
('Summoned Skull', 'Demônio', 2500, 1200),
('Exodia the Forbidden One', 'Lendária', 1000, 1000);