-- Atualização para permitir que o admin edite passagens compradas
-- sem alterar o voo global do catálogo.

ALTER TABLE flight_reservations ADD COLUMN origin VARCHAR(100) NULL AFTER passengers_json;
ALTER TABLE flight_reservations ADD COLUMN destination VARCHAR(100) NULL AFTER origin;
ALTER TABLE flight_reservations ADD COLUMN departure_date DATETIME NULL AFTER destination;
ALTER TABLE flight_reservations ADD COLUMN arrival_date DATETIME NULL AFTER departure_date;
ALTER TABLE flight_reservations ADD COLUMN return_date DATETIME NULL AFTER arrival_date;
ALTER TABLE flight_reservations ADD COLUMN aircraft_model VARCHAR(100) NULL AFTER return_date;
ALTER TABLE flight_reservations MODIFY COLUMN status ENUM('pendente', 'confirmado', 'cancelado', 'concluido') DEFAULT 'pendente';

UPDATE flight_reservations fr
JOIN flights f ON fr.flight_id = f.id
SET fr.origin = COALESCE(fr.origin, f.origin),
    fr.destination = COALESCE(fr.destination, f.destination),
    fr.departure_date = COALESCE(fr.departure_date, f.departure_date),
    fr.arrival_date = COALESCE(fr.arrival_date, f.arrival_date),
    fr.return_date = COALESCE(fr.return_date, f.return_date),
    fr.aircraft_model = COALESCE(fr.aircraft_model, f.aircraft_model)
WHERE fr.origin IS NULL
   OR fr.destination IS NULL
   OR fr.departure_date IS NULL
   OR fr.aircraft_model IS NULL;

CREATE TABLE IF NOT EXISTS flight_reservation_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT NOT NULL,
    admin_name VARCHAR(150) NOT NULL,
    admin_email VARCHAR(150) NOT NULL,
    reason VARCHAR(255) NOT NULL,
    notes TEXT NULL,
    old_data LONGTEXT NOT NULL,
    new_data LONGTEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reservation_id) REFERENCES flight_reservations(id) ON DELETE CASCADE
);
