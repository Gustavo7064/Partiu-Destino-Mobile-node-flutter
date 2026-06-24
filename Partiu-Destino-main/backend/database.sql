-- Criar o banco de dados
CREATE DATABASE IF NOT EXISTS partiu_destino;
USE partiu_destino;

-- 1. Tabela de usuários
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('user', 'admin') DEFAULT 'user',
    profile_image LONGTEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabela de hotéis/destinos (Catálogo Dinâmico)
CREATE TABLE IF NOT EXISTS hotels (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    description TEXT,
    image_url LONGTEXT,
    price_per_night DECIMAL(10, 2) NOT NULL,
    rating DECIMAL(3, 1) DEFAULT 5.0,
    checkin_time VARCHAR(50) DEFAULT '14:00',
    checkout_time VARCHAR(50) DEFAULT '12:00',
    amenities TEXT, 
    bedrooms INT DEFAULT 1,
    bathrooms INT DEFAULT 1,
    tvs INT DEFAULT 1,
    has_ac BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Tabela de viagens/reservas (Com todas as colunas necessárias)
CREATE TABLE IF NOT EXISTS trips (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    hotel_name VARCHAR(255) NOT NULL,
    travel_date DATE NOT NULL, -- Check-in
    checkout_date DATE,        -- Check-out
    total_price DECIMAL(10, 2),
    guests_json LONGTEXT,      -- Detalhes dos participantes e documentos
    policies_json TEXT,        -- Políticas aceitas
    room_type VARCHAR(100),    -- Tipo de quarto selecionado
    children_count INT DEFAULT 0, -- Quantidade de crianças
    channel VARCHAR(50) DEFAULT 'App Mobile', -- Canal de reserva (App, Web, etc)
    status ENUM('pendente', 'concluida', 'cancelada') DEFAULT 'pendente',
    rating INT,
    review TEXT,
    notes TEXT,                -- Observações do admin
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 4. Tabela de Favoritos
CREATE TABLE IF NOT EXISTS favorites (
    user_id INT NOT NULL,
    hotel_id INT NOT NULL,
    PRIMARY KEY (user_id, hotel_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (hotel_id) REFERENCES hotels(id) ON DELETE CASCADE
);

-- 5. Tabela de pedidos de viagem personalizados
CREATE TABLE IF NOT EXISTS custom_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    user_name VARCHAR(255),
    user_email VARCHAR(255),
    user_phone VARCHAR(50),
    allow_whatsapp BOOLEAN DEFAULT TRUE,
    has_children BOOLEAN DEFAULT FALSE,
    people_count INT NOT NULL,
    reason VARCHAR(255),
    budget VARCHAR(100),
    objectives TEXT,
    activities TEXT,
    extra_info TEXT,
    interests TEXT,
    suggested_destination VARCHAR(255),
    status ENUM('pendente', 'contatado') DEFAULT 'pendente',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

INSERT INTO hotels (name, location, description, image_url, price_per_night) VALUES
    ('Rio de Janeiro', 'Brasil, São Paulo (Origem)', 'Pacote completo para conhecer as praias e pontos turísticos do Rio de Janeiro.', 'https://images.unsplash.com/photo-1483729558449-99ef09a8c325?w=700&q=80', 1200.00 ),
    ('Bahia', 'Brasil, São Paulo (Origem)', 'Experiência incrível em resort all inclusive na Bahia.', 'https://images.unsplash.com/photo-1591233055842-a984961b71af?w=800&q=80', 980.00 ),
    ('Ceará', 'Brasil, São Paulo (Origem)', 'Conheça as belas praias do Ceará.', 'https://images.unsplash.com/photo-1538565756327-7e5b9dc67c3f?w=700&q=80', 850.00 ),
    ('Califórnia', 'Brasil, São Paulo (Origem)', 'Conheça Los Angeles, praias e parques famosos da Califórnia.', 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=700&q=80', 8500.00 ),
    ('Flórida', 'Brasil, São Paulo (Origem)', 'Explore os parques e praias da Flórida.', 'https://images.unsplash.com/photo-1533106418989-88406c7cc8ca?w=700&q=80', 7900.00 ),
    ('Provença-Alpes-Costa Azul', 'Brasil, São Paulo (Origem)', 'Uma viagem inesquecível pela França.', 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=700&q=80', 11500.00 ),
    ('Toscana', 'Brasil, São Paulo (Origem)', 'Experiência gastronômica e cultural na Toscana.', 'https://images.unsplash.com/photo-1543429776-2782fc8e3e56?w=700&q=80', 10800.00 ),
    ('Tóquio', 'Brasil, São Paulo (Origem)', 'Conheça o Japão moderno e tradicional em uma experiência única.', 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=700&q=80', 13200.00 ),
    ('Lisboa', 'Brasil, Rio de Janeiro (Origem)', 'Explore a capital de Portugal.', 'https://images.unsplash.com/photo-1555881400-74d7acaacd8b?w=700&q=80', 9400.00 ),
    ('Buenos Aires', 'Brasil, Rio de Janeiro (Origem)', 'Conheça a vibrante Buenos Aires.', 'https://images.unsplash.com/photo-1583285233058-4a9e6a5e34d8?w=700&q=80', 4200.00 ),
    ('Santiago', 'Brasil, Minas Gerais (Origem)', 'Aventura nas paisagens do Chile.', 'https://images.unsplash.com/photo-1554254648-2d58a1bc3fd5?w=700&q=80', 5600.00 ),
    ('Quintana Roo', 'Brasil, Paraná (Origem)', 'As praias paradisíacas do México.', 'https://images.unsplash.com/photo-1552074284-5e88ef1aef18?w=700&q=80', 6300.00 );

-- Inserir um administrador padrão (Senha: admin123)
-- Nota: Em um sistema real, a senha deve ser hasheada. 
-- O app atual usa comparação de string simples ou o backend faz o hash.
INSERT IGNORE INTO users (id, name, email, password, role) 
VALUES (1, 'Administrador', 'admin@destino.com', 'admin123', 'admin');



-- 6. Tabela de Voos (Flights)
CREATE TABLE IF NOT EXISTS flights (
    id INT AUTO_INCREMENT PRIMARY KEY,
    origin VARCHAR(100) NOT NULL,
    destination VARCHAR(100) NOT NULL,
    departure_date DATETIME NOT NULL,
    arrival_date DATETIME,
    return_date DATETIME NULL,
    price_per_seat DECIMAL(10, 2) NOT NULL,
    aircraft_model VARCHAR(100) DEFAULT 'Boeing 737',
    total_rows INT DEFAULT 30,
    seats_per_row INT DEFAULT 6, -- Ex: 6 assentos (A, B, C, D, E, F)
    status ENUM('ativo', 'cancelado', 'concluido') DEFAULT 'ativo',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. Tabela de Reservas de Voos (Flight Reservations)
CREATE TABLE IF NOT EXISTS flight_reservations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    user_id INT NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    passengers_json LONGTEXT NOT NULL, -- Dados dos passageiros (nome, CPF, assento)
    status ENUM('pendente', 'confirmado', 'cancelado') DEFAULT 'pendente',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (flight_id) REFERENCES flights(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 8. Tabela de Assentos Ocupados (Para controle em tempo real)
CREATE TABLE IF NOT EXISTS occupied_seats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    seat_label VARCHAR(10) NOT NULL, -- Ex: "12A", "1B"
    reservation_id INT NOT NULL,
    FOREIGN KEY (flight_id) REFERENCES flights(id) ON DELETE CASCADE,
    FOREIGN KEY (reservation_id) REFERENCES flight_reservations(id) ON DELETE CASCADE,
    UNIQUE KEY unique_seat (flight_id, seat_label)
);

-- Inserir alguns voos de exemplo
INSERT INTO flights (origin, destination, departure_date, arrival_date, return_date, price_per_seat, aircraft_model) VALUES
    ('São Paulo (GRU)', 'Rio de Janeiro (GIG)', '2026-07-15 10:00:00', '2026-07-15 11:00:00', '2026-07-22 14:00:00', 350.00, 'Airbus A320'),
    ('Rio de Janeiro (GIG)', 'Lisboa (LIS)', '2026-08-20 22:00:00', '2026-08-21 10:00:00', '2026-08-30 19:00:00', 4200.00, 'Boeing 787 Dreamliner'),
    ('São Paulo (GRU)', 'Buenos Aires (EZE)', '2026-09-10 14:30:00', '2026-09-10 17:30:00', '2026-09-17 12:00:00', 1200.00, 'Boeing 737-800');
