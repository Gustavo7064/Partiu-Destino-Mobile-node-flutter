USE partiu_destino;

CREATE TABLE IF NOT EXISTS flights (
    id INT AUTO_INCREMENT PRIMARY KEY,
    origin VARCHAR(100) NOT NULL,
    destination VARCHAR(100) NOT NULL,
    departure_date DATETIME NOT NULL,
    arrival_date DATETIME NULL,
    return_date DATETIME NULL,
    price_per_seat DECIMAL(10, 2) NOT NULL,
    aircraft_model VARCHAR(100) DEFAULT 'Boeing 737',
    total_rows INT DEFAULT 30,
    seats_per_row INT DEFAULT 6,
    status ENUM('ativo', 'cancelado', 'concluido') DEFAULT 'ativo',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS flight_reservations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    user_id INT NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    passengers_json LONGTEXT NOT NULL,
    status ENUM('pendente', 'confirmado', 'cancelado') DEFAULT 'pendente',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (flight_id) REFERENCES flights(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS occupied_seats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    seat_label VARCHAR(10) NOT NULL,
    reservation_id INT NOT NULL,
    FOREIGN KEY (flight_id) REFERENCES flights(id) ON DELETE CASCADE,
    FOREIGN KEY (reservation_id) REFERENCES flight_reservations(id) ON DELETE CASCADE,
    UNIQUE KEY unique_seat (flight_id, seat_label)
);

-- Rode estes ALTERs apenas se sua tabela flights antiga não tiver essas colunas.
-- Se aparecer erro de coluna duplicada, pode ignorar.
ALTER TABLE flights ADD COLUMN return_date DATETIME NULL AFTER arrival_date;
ALTER TABLE flights ADD COLUMN aircraft_model VARCHAR(100) DEFAULT 'Boeing 737' AFTER price_per_seat;
ALTER TABLE flights ADD COLUMN total_rows INT DEFAULT 30 AFTER aircraft_model;
ALTER TABLE flights ADD COLUMN seats_per_row INT DEFAULT 6 AFTER total_rows;
ALTER TABLE flights ADD COLUMN status ENUM('ativo', 'cancelado', 'concluido') DEFAULT 'ativo' AFTER seats_per_row;
ALTER TABLE flights ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP AFTER status;
