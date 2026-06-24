const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bcrypt = require('bcryptjs');

const app = express();
const PORT = 3000;

app.use(cors({ origin: '*', methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], allowedHeaders: ['Content-Type', 'Authorization', 'Accept'] }));
app.use(express.json({ limit: '50mb' }));


function normalizeMySqlDateTime(value) {
    if (!value) return null;
    if (value instanceof Date) {
        return value.toISOString().slice(0, 19).replace('T', ' ');
    }
    if (typeof value !== 'string') return value;

    const trimmed = value.trim();
    if (!trimmed) return null;

    // MySQL DATETIME não aceita o formato ISO completo vindo do Flutter/JS, exemplo:
    // 2026-07-15T13:00:00.000Z. Por isso convertemos para: 2026-07-15 13:00:00
    if (trimmed.includes('T')) {
        const date = new Date(trimmed);
        if (!Number.isNaN(date.getTime())) {
            return date.toISOString().slice(0, 19).replace('T', ' ');
        }
        return trimmed.split('.')[0].replace('T', ' ').replace('Z', '');
    }

    return trimmed;
}

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '123456789',
    database: 'partiu_destino'
});

db.connect((err) => {
    if (err) { console.error('❌ ERRO AO CONECTAR AO MYSQL:', err.message); return; }
    console.log('✅ Conectado ao banco de dados MySQL com sucesso!');
    
    // SCHEMA SYNC
    // Mantém o banco compatível mesmo quando o database.sql antigo já tinha sido importado.
    // Erros de coluna duplicada são ignorados para não derrubar o backend.
    const queries = [
        "CREATE TABLE IF NOT EXISTS favorites (id INT AUTO_INCREMENT PRIMARY KEY, user_id INT, hotel_id INT, UNIQUE(user_id, hotel_id))",
        "ALTER TABLE hotels ADD COLUMN room_types_json TEXT AFTER has_ac",
        "ALTER TABLE trips ADD COLUMN room_type VARCHAR(100) AFTER hotel_name",
        "ALTER TABLE trips ADD COLUMN children_count INT DEFAULT 0 AFTER room_type",
        "ALTER TABLE trips ADD COLUMN rating INT DEFAULT 0, ADD COLUMN review TEXT",

        // Tabelas do catálogo/reserva de voos
        `CREATE TABLE IF NOT EXISTS flights (
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
        )`,
        `CREATE TABLE IF NOT EXISTS flight_reservations (
            id INT AUTO_INCREMENT PRIMARY KEY,
            flight_id INT NOT NULL,
            user_id INT NOT NULL,
            total_price DECIMAL(10, 2) NOT NULL,
            passengers_json LONGTEXT NOT NULL,
            origin VARCHAR(100) NULL,
            destination VARCHAR(100) NULL,
            departure_date DATETIME NULL,
            arrival_date DATETIME NULL,
            return_date DATETIME NULL,
            aircraft_model VARCHAR(100) NULL,
            status ENUM('pendente', 'confirmado', 'cancelado', 'concluido') DEFAULT 'pendente',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (flight_id) REFERENCES flights(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )`,
        `CREATE TABLE IF NOT EXISTS occupied_seats (
            id INT AUTO_INCREMENT PRIMARY KEY,
            flight_id INT NOT NULL,
            seat_label VARCHAR(10) NOT NULL,
            reservation_id INT NOT NULL,
            FOREIGN KEY (flight_id) REFERENCES flights(id) ON DELETE CASCADE,
            FOREIGN KEY (reservation_id) REFERENCES flight_reservations(id) ON DELETE CASCADE,
            UNIQUE KEY unique_seat (flight_id, seat_label)
        )`,
        `CREATE TABLE IF NOT EXISTS flight_reservation_history (
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
        )`,

        // Ajustes para bancos que já tinham a tabela flights criada sem as colunas novas
        "ALTER TABLE flights ADD COLUMN return_date DATETIME NULL AFTER arrival_date",
        "ALTER TABLE flights ADD COLUMN aircraft_model VARCHAR(100) DEFAULT 'Boeing 737' AFTER price_per_seat",
        "ALTER TABLE flights ADD COLUMN total_rows INT DEFAULT 30 AFTER aircraft_model",
        "ALTER TABLE flights ADD COLUMN seats_per_row INT DEFAULT 6 AFTER total_rows",
        "ALTER TABLE flights ADD COLUMN status ENUM('ativo', 'cancelado', 'concluido') DEFAULT 'ativo' AFTER seats_per_row",
        "ALTER TABLE flights ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP AFTER status",

        // Snapshot da passagem comprada. O admin edita estes campos, sem alterar o voo global.
        "ALTER TABLE flight_reservations ADD COLUMN origin VARCHAR(100) NULL AFTER passengers_json",
        "ALTER TABLE flight_reservations ADD COLUMN destination VARCHAR(100) NULL AFTER origin",
        "ALTER TABLE flight_reservations ADD COLUMN departure_date DATETIME NULL AFTER destination",
        "ALTER TABLE flight_reservations ADD COLUMN arrival_date DATETIME NULL AFTER departure_date",
        "ALTER TABLE flight_reservations ADD COLUMN return_date DATETIME NULL AFTER arrival_date",
        "ALTER TABLE flight_reservations ADD COLUMN aircraft_model VARCHAR(100) NULL AFTER return_date",
        "ALTER TABLE flight_reservations MODIFY COLUMN status ENUM('pendente', 'confirmado', 'cancelado', 'concluido') DEFAULT 'pendente'",
        `UPDATE flight_reservations fr
         JOIN flights f ON fr.flight_id = f.id
         SET fr.origin = COALESCE(fr.origin, f.origin),
             fr.destination = COALESCE(fr.destination, f.destination),
             fr.departure_date = COALESCE(fr.departure_date, f.departure_date),
             fr.arrival_date = COALESCE(fr.arrival_date, f.arrival_date),
             fr.return_date = COALESCE(fr.return_date, f.return_date),
             fr.aircraft_model = COALESCE(fr.aircraft_model, f.aircraft_model)
         WHERE fr.origin IS NULL OR fr.destination IS NULL OR fr.departure_date IS NULL OR fr.aircraft_model IS NULL`
    ];
    queries.forEach(q => db.query(q, (err) => {
        if (err && err.code !== 'ER_DUP_FIELDNAME' && err.code !== 'ER_DUP_KEYNAME') {
            console.error('⚠️ Erro ao sincronizar schema:', err.message);
        }
    }));
});

// AUTH
app.post('/login', (req, res) => {
    const { email, password } = req.body;
    if (email === 'admin' && password === '12345') {
        return res.json({ success: true, user: { id: 0, name: 'Administrador', email: 'admin', role: 'admin' } });
    }
    db.query('SELECT * FROM users WHERE email = ?', [email], async (err, results) => {
        if (err || results.length === 0) return res.status(401).json({ success: false, message: 'Usuário não encontrado' });
        const user = results[0];
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(401).json({ success: false, message: 'Senha incorreta' });
        res.json({ success: true, user: { id: user.id, name: user.name, email: user.email, role: user.role, profile_image: user.profile_image } });
    });
});

app.post('/register', async (req, res) => {
    const { name, email, password } = req.body;
    const hashed = await bcrypt.hash(password, 10);
    db.query('INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)', [name, email, hashed, 'user'], (err) => {
        if (err) return res.status(400).json({ success: false, message: 'Erro ao cadastrar' });
        res.json({ success: true });
    });
});

// USER PROFILE
app.put('/user/profile/:id', async (req, res) => {
    const { name, email, password, profile_image } = req.body;
    const userId = req.params.id;
    
    if (password && password.length > 0) {
        const hashed = await bcrypt.hash(password, 10);
        db.query('UPDATE users SET name = ?, email = ?, password = ?, profile_image = ? WHERE id = ?', 
            [name, email, hashed, profile_image, userId], (err) => {
            if (err) return res.status(400).json({ success: false, message: 'Erro ao atualizar' });
            res.json({ success: true });
        });
    } else {
        db.query('UPDATE users SET name = ?, email = ?, profile_image = ? WHERE id = ?', 
            [name, email, profile_image, userId], (err) => {
            if (err) return res.status(400).json({ success: false, message: 'Erro ao atualizar' });
            res.json({ success: true });
        });
    }
});

// HOTELS
app.get('/hotels', (req, res) => {
    db.query('SELECT * FROM hotels ORDER BY created_at DESC', (err, results) => {
        res.json(results || []);
    });
});

// TRIPS
app.post('/trips', (req, res) => {
    const { user_id, hotel_name, room_type, children_count, travel_date, checkout_date, total_price, guests_json, policies_json, channel } = req.body;
    const q = 'INSERT INTO trips (user_id, hotel_name, room_type, children_count, travel_date, checkout_date, total_price, guests_json, policies_json, channel, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, "pendente")';
    db.query(q, [user_id, hotel_name, room_type, children_count, travel_date, checkout_date, total_price, guests_json, policies_json, channel || 'App Mobile'], (err) => {
        if (err) return res.status(400).json({ success: false });
        res.json({ success: true });
    });
});

app.get('/user/trips/:id', (req, res) => {
    db.query('SELECT * FROM trips WHERE user_id = ? ORDER BY travel_date DESC', [req.params.id], (err, results) => {
        res.json(results || []);
    });
});

app.post('/trips/:id/review', (req, res) => {
    const { rating, review } = req.body;
    
    // Primeiro, atualizamos a trip
    db.query('UPDATE trips SET rating = ?, review = ?, status = "concluida" WHERE id = ?', [rating, review, req.params.id], (err) => {
        if (err) return res.status(500).json({ success: false });
        
        // Agora, buscamos o nome do hotel desta trip para atualizar a média do hotel
        db.query('SELECT hotel_name FROM trips WHERE id = ?', [req.params.id], (err, results) => {
            if (!err && results.length > 0) {
                const hotelName = results[0].hotel_name;
                
                // Calculamos a nova média para este hotel
                db.query('SELECT AVG(rating) as avgRating FROM trips WHERE hotel_name = ? AND rating > 0', [hotelName], (err, avgResults) => {
                    if (!err && avgResults.length > 0) {
                        const newAvg = avgResults[0].avgRating || 5.0;
                        
                        // Atualizamos a tabela hotels com a nova média
                        db.query('UPDATE hotels SET rating = ? WHERE name = ?', [newAvg, hotelName], (err) => {
                            if (err) console.error('Erro ao atualizar média do hotel:', err);
                        });
                    }
                });
            }
        });
        
        res.json({ success: true });
    });
});

// FAVORITES (ROTA QUE ESTAVA DANDO 404)
app.get('/favorites/:userId', (req, res) => {
    db.query('SELECT hotel_id FROM favorites WHERE user_id = ?', [req.params.userId], (err, results) => {
        res.json(results ? results.map(r => r.hotel_id) : []);
    });
});

app.post('/favorites', (req, res) => {
    const { user_id, hotel_id } = req.body;
    db.query('INSERT IGNORE INTO favorites (user_id, hotel_id) VALUES (?, ?)', [user_id, hotel_id], (err) => {
        res.json({ success: true });
    });
});

app.delete('/favorites/:userId/:hotelId', (req, res) => {
    db.query('DELETE FROM favorites WHERE user_id = ? AND hotel_id = ?', [req.params.userId, req.params.hotelId], (err) => {
        res.json({ success: true });
    });
});

// CUSTOM REQUESTS
app.post('/custom-requests', (req, res) => {
    const { user_id, user_name, user_email, user_phone, allow_whatsapp, has_children, people_count, reason, budget, objectives, activities, extra_info, interests, suggested_destination } = req.body;
    const q = 'INSERT INTO custom_requests (user_id, user_name, user_email, user_phone, allow_whatsapp, has_children, people_count, reason, budget, objectives, activities, extra_info, interests, suggested_destination, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, "pendente")';
    db.query(q, [user_id, user_name, user_email, user_phone, allow_whatsapp ? 1 : 0, has_children ? 1 : 0, people_count, reason, budget, objectives, activities, extra_info, interests, suggested_destination], (err) => {
        if (err) {
            console.error('Erro ao salvar custom request:', err);
            return res.status(400).json({ success: false, message: 'Erro ao salvar pedido' });
        }
        res.json({ success: true });
    });
});

// ADMIN
app.get('/admin/users', (req, res) => {
    db.query('SELECT id, name, email, role, profile_image FROM users WHERE email != "admin"', (err, results) => res.json(results || []));
});

app.put('/admin/users/:id', async (req, res) => {
    const { name, email, role, password, profile_image } = req.body;
    if (password && password.length > 0) {
        const hashed = await bcrypt.hash(password, 10);
        db.query('UPDATE users SET name = ?, email = ?, role = ?, password = ?, profile_image = ? WHERE id = ?',
            [name, email, role, hashed, profile_image || null, req.params.id], (err) => {
            if (err) return res.status(400).json({ success: false, message: err.message });
            res.json({ success: true });
        });
    } else {
        db.query('UPDATE users SET name = ?, email = ?, role = ?, profile_image = ? WHERE id = ?',
            [name, email, role, profile_image || null, req.params.id], (err) => {
            if (err) return res.status(400).json({ success: false, message: err.message });
            res.json({ success: true });
        });
    }
});

app.delete('/admin/users/:id', (req, res) => {
    db.query('DELETE FROM users WHERE id = ?', [req.params.id], (err) => {
        if (err) return res.status(400).json({ success: false });
        res.json({ success: true });
    });
});

app.get('/admin/trips', (req, res) => {
    db.query('SELECT t.*, u.name as userName FROM trips t JOIN users u ON t.user_id = u.id', (err, results) => res.json(results || []));
});

app.put('/admin/trips/:id', (req, res) => {
    const { status, total_price, travel_date, checkout_date } = req.body;
    db.query(
        'UPDATE trips SET status = ?, total_price = ?, travel_date = COALESCE(?, travel_date), checkout_date = COALESCE(?, checkout_date) WHERE id = ?',
        [status, total_price, travel_date || null, checkout_date || null, req.params.id],
        (err) => {
            if (err) return res.status(400).json({ success: false });
            res.json({ success: true });
        }
    );
});

app.get('/admin/financial', (req, res) => {
    // Retorna múltiplos conjuntos de dados para o novo painel
    const queries = {
        mensal: `
            SELECT 
                MONTH(travel_date) as mes, 
                YEAR(travel_date) as ano, 
                COUNT(*) as totalReservas, 
                SUM(CASE WHEN status='concluida' THEN total_price ELSE 0 END) as faturamentoTotal, 
                SUM(CASE WHEN status='pendente' THEN total_price ELSE 0 END) as aReceber 
            FROM trips 
            GROUP BY YEAR(travel_date), MONTH(travel_date)
            ORDER BY ano ASC, mes ASC
        `,
        diario: `
            SELECT 
                DATE(created_at) as dia,
                COUNT(*) as totalReservas,
                SUM(total_price) as faturamentoDia
            FROM trips
            WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
            GROUP BY DATE(created_at)
            ORDER BY dia ASC
        `,
        porDestino: `
            SELECT hotel_name as destino, COUNT(*) as total, SUM(total_price) as faturamento
            FROM trips
            GROUP BY hotel_name
            ORDER BY total DESC
            LIMIT 10
        `,
        kpis: `
            SELECT 
                AVG(total_price) as ticketMedio,
                SUM(total_price) / SUM(JSON_LENGTH(guests_json->'$.companions') + 1) as receitaPorHospede,
                COUNT(*) as totalGeral
            FROM trips
            WHERE status != 'cancelada'
        `
    };

    const results = {};
    let completed = 0;
    const keys = Object.keys(queries);

    keys.forEach(key => {
        db.query(queries[key], (err, data) => {
            results[key] = data || [];
            completed++;
            if (completed === keys.length) {
                res.json(results);
            }
        });
    });
});


app.get('/admin/flight-financial', (req, res) => {
    const queries = {
        mensal: `
            SELECT
                MONTH(COALESCE(departure_date, created_at)) as mes,
                YEAR(COALESCE(departure_date, created_at)) as ano,
                COUNT(*) as totalPassagens,
                SUM(CASE WHEN status IN ('confirmado', 'concluido') THEN total_price ELSE 0 END) as faturamentoTotal,
                SUM(CASE WHEN status = 'pendente' THEN total_price ELSE 0 END) as aReceber
            FROM flight_reservations
            GROUP BY YEAR(COALESCE(departure_date, created_at)), MONTH(COALESCE(departure_date, created_at))
            ORDER BY ano ASC, mes ASC
        `,
        diario: `
            SELECT
                DATE(created_at) as dia,
                COUNT(*) as totalPassagens,
                SUM(total_price) as faturamentoDia
            FROM flight_reservations
            WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
            GROUP BY DATE(created_at)
            ORDER BY dia ASC
        `,
        porDestino: `
            SELECT
                COALESCE(destination, 'Destino não informado') as destino,
                COUNT(*) as total,
                SUM(total_price) as faturamento
            FROM flight_reservations
            GROUP BY COALESCE(destination, 'Destino não informado')
            ORDER BY total DESC
            LIMIT 10
        `,
        kpis: `
            SELECT
                AVG(total_price) as ticketMedio,
                COUNT(*) as totalGeral,
                SUM(CASE WHEN status IN ('confirmado', 'concluido') THEN total_price ELSE 0 END) as faturamentoConfirmado,
                SUM(CASE WHEN status = 'pendente' THEN total_price ELSE 0 END) as pendente
            FROM flight_reservations
            WHERE status != 'cancelado'
        `
    };

    const results = {};
    let completed = 0;
    const keys = Object.keys(queries);

    keys.forEach(key => {
        db.query(queries[key], (err, data) => {
            results[key] = data || [];
            completed++;
            if (completed === keys.length) {
                res.json(results);
            }
        });
    });
});

app.get('/admin/custom-requests', (req, res) => {
    db.query('SELECT * FROM custom_requests ORDER BY created_at DESC', (err, results) => res.json(results || []));
});

app.put('/admin/custom-requests/:id/status', (req, res) => {
    const { status } = req.body;
    db.query('UPDATE custom_requests SET status = ? WHERE id = ?', [status, req.params.id], (err) => {
        if (err) return res.status(400).json({ success: false });
        res.json({ success: true });
    });
});

app.post('/admin/hotels', (req, res) => {
    const { name, location, description, image_url, price_per_night, amenities, bedrooms, bathrooms, tvs, has_ac, room_types_json } = req.body;
    const q = 'INSERT INTO hotels (name, location, description, image_url, price_per_night, amenities, bedrooms, bathrooms, tvs, has_ac, room_types_json) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
    db.query(q, [name, location, description, image_url, price_per_night, amenities, bedrooms, bathrooms, tvs, has_ac ? 1 : 0, room_types_json], (err) => {
        if (err) return res.status(400).json({ success: false });
        res.json({ success: true });
    });
});

app.put('/admin/hotels/:id', (req, res) => {
    const { name, location, description, image_url, price_per_night, amenities, bedrooms, bathrooms, tvs, has_ac, room_types_json } = req.body;
    const q = 'UPDATE hotels SET name=?, location=?, description=?, image_url=?, price_per_night=?, amenities=?, bedrooms=?, bathrooms=?, tvs=?, has_ac=?, room_types_json=? WHERE id=?';
    db.query(q, [name, location, description, image_url, price_per_night, amenities, bedrooms, bathrooms, tvs, has_ac ? 1 : 0, room_types_json, req.params.id], (err) => {
        res.json({ success: !err });
    });
});

app.delete('/admin/hotels/:id', (req, res) => {
    db.query('DELETE FROM hotels WHERE id = ?', [req.params.id], (err) => {
        if (err) return res.status(400).json({ success: false });
        res.json({ success: true });
    });
});

// ROTAS DE VOOS
app.get('/flights', (req, res) => {
    db.query('SELECT * FROM flights WHERE status = "ativo" ORDER BY departure_date ASC', (err, results) => {
        res.json(results || []);
    });
});

app.get('/flights/:id', (req, res) => {
    db.query('SELECT * FROM flights WHERE id = ?', [req.params.id], (err, results) => {
        if (err || results.length === 0) return res.status(404).json({ success: false });
        res.json(results[0]);
    });
});

app.get('/flights/:id/occupied-seats', (req, res) => {
    db.query('SELECT seat_label FROM occupied_seats WHERE flight_id = ?', [req.params.id], (err, results) => {
        res.json(results || []);
    });
});

app.post('/flight-reservations', (req, res) => {
    const { flight_id, user_id, total_price, passengers_json, seats } = req.body;
    const passengersPayload = typeof passengers_json === 'string' ? passengers_json : JSON.stringify(passengers_json || []);

    if (!Array.isArray(seats) || seats.length === 0) {
        return res.status(400).json({ success: false, message: 'Nenhum assento selecionado' });
    }

    db.query('SELECT * FROM flights WHERE id = ?', [flight_id], (err, flightResults) => {
        if (err || flightResults.length === 0) {
            return res.status(404).json({ success: false, message: 'Voo não encontrado' });
        }
        const flight = flightResults[0];
        db.query(
            `INSERT INTO flight_reservations
             (flight_id, user_id, total_price, passengers_json, origin, destination, departure_date, arrival_date, return_date, aircraft_model, status)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, "pendente")`,
            [flight_id, user_id, total_price, passengersPayload, flight.origin, flight.destination, flight.departure_date, flight.arrival_date, flight.return_date, flight.aircraft_model],
            (err, result) => {
                if (err) return res.status(400).json({ success: false, message: err.message });
                const reservationId = result.insertId;
                const seatInserts = seats.map(seat => [flight_id, seat, reservationId]);
                const placeholders = seatInserts.map(() => '(?, ?, ?)').join(',');
                const flatValues = seatInserts.flat();
                db.query(
                    `INSERT INTO occupied_seats (flight_id, seat_label, reservation_id) VALUES ${placeholders}`,
                    flatValues,
                    (err) => {
                        if (err) return res.status(400).json({ success: false, message: 'Assento já ocupado ou inválido.' });
                        res.json({ success: true, reservation_id: reservationId });
                    }
                );
            }
        );
    });
});

app.get('/user/flight-reservations/:userId', (req, res) => {
    db.query(
        `SELECT fr.*,
                COALESCE(fr.origin, f.origin) AS origin,
                COALESCE(fr.destination, f.destination) AS destination,
                COALESCE(fr.departure_date, f.departure_date) AS departure_date,
                COALESCE(fr.arrival_date, f.arrival_date) AS arrival_date,
                COALESCE(fr.return_date, f.return_date) AS return_date,
                COALESCE(fr.aircraft_model, f.aircraft_model) AS aircraft_model,
                (SELECT GROUP_CONCAT(os.seat_label ORDER BY os.seat_label SEPARATOR ', ')
                 FROM occupied_seats os
                 WHERE os.reservation_id = fr.id) AS seats
         FROM flight_reservations fr
         JOIN flights f ON fr.flight_id = f.id
         WHERE fr.user_id = ?
         ORDER BY fr.created_at DESC`,
        [req.params.userId],
        (err, results) => {
            if (err) return res.status(400).json([]);
            res.json(results || []);
        }
    );
});


// ADMIN - PASSAGENS COMPRADAS PELOS USUÁRIOS
app.get('/admin/flight-reservations', (req, res) => {
    db.query(
        `SELECT fr.*,
                u.name AS user_name,
                u.email AS user_email,
                COALESCE(fr.origin, f.origin) AS origin,
                COALESCE(fr.destination, f.destination) AS destination,
                COALESCE(fr.departure_date, f.departure_date) AS departure_date,
                COALESCE(fr.arrival_date, f.arrival_date) AS arrival_date,
                COALESCE(fr.return_date, f.return_date) AS return_date,
                COALESCE(fr.aircraft_model, f.aircraft_model) AS aircraft_model,
                (SELECT GROUP_CONCAT(os.seat_label ORDER BY os.seat_label SEPARATOR ', ')
                 FROM occupied_seats os
                 WHERE os.reservation_id = fr.id) AS seats
         FROM flight_reservations fr
         JOIN users u ON fr.user_id = u.id
         JOIN flights f ON fr.flight_id = f.id
         ORDER BY fr.created_at DESC`,
        (err, results) => {
            if (err) return res.status(400).json([]);
            res.json(results || []);
        }
    );
});

app.get('/admin/flight-reservations/:id', (req, res) => {
    db.query(
        `SELECT fr.*,
                u.name AS user_name,
                u.email AS user_email,
                COALESCE(fr.origin, f.origin) AS origin,
                COALESCE(fr.destination, f.destination) AS destination,
                COALESCE(fr.departure_date, f.departure_date) AS departure_date,
                COALESCE(fr.arrival_date, f.arrival_date) AS arrival_date,
                COALESCE(fr.return_date, f.return_date) AS return_date,
                COALESCE(fr.aircraft_model, f.aircraft_model) AS aircraft_model,
                (SELECT GROUP_CONCAT(os.seat_label ORDER BY os.seat_label SEPARATOR ', ')
                 FROM occupied_seats os
                 WHERE os.reservation_id = fr.id) AS seats
         FROM flight_reservations fr
         JOIN users u ON fr.user_id = u.id
         JOIN flights f ON fr.flight_id = f.id
         WHERE fr.id = ?`,
        [req.params.id],
        (err, results) => {
            if (err || results.length === 0) return res.status(404).json({ success: false, message: 'Reserva não encontrada' });
            res.json(results[0]);
        }
    );
});

app.get('/admin/flight-reservations/:id/history', (req, res) => {
    db.query('SELECT * FROM flight_reservation_history WHERE reservation_id = ? ORDER BY created_at DESC', [req.params.id], (err, results) => {
        if (err) return res.status(400).json([]);
        res.json(results || []);
    });
});

app.put('/admin/flight-reservations/:id', (req, res) => {
    const reservationId = req.params.id;
    const {
        origin, destination, departure_date, arrival_date, return_date, aircraft_model,
        total_price, passengers_json, seats, status,
        admin_name, admin_email, reason, notes
    } = req.body;

    if (!admin_name || !admin_email || !reason) {
        return res.status(400).json({ success: false, message: 'Informe nome, identificação/e-mail e motivo da alteração.' });
    }
    if (!origin || !destination || !departure_date || !aircraft_model || !total_price || !status) {
        return res.status(400).json({ success: false, message: 'Preencha os dados obrigatórios da passagem.' });
    }
    if (!Array.isArray(seats) || seats.length === 0) {
        return res.status(400).json({ success: false, message: 'Informe ao menos um assento.' });
    }

    const passengersPayload = typeof passengers_json === 'string' ? passengers_json : JSON.stringify(passengers_json || []);
    const normalizedDepartureDate = normalizeMySqlDateTime(departure_date);
    const normalizedArrivalDate = normalizeMySqlDateTime(arrival_date);
    const normalizedReturnDate = normalizeMySqlDateTime(return_date);

    db.beginTransaction((txErr) => {
        if (txErr) return res.status(500).json({ success: false, message: txErr.message });

        db.query(
            `SELECT fr.*,
                    COALESCE(fr.origin, f.origin) AS origin,
                    COALESCE(fr.destination, f.destination) AS destination,
                    COALESCE(fr.departure_date, f.departure_date) AS departure_date,
                    COALESCE(fr.arrival_date, f.arrival_date) AS arrival_date,
                    COALESCE(fr.return_date, f.return_date) AS return_date,
                    COALESCE(fr.aircraft_model, f.aircraft_model) AS aircraft_model,
                    (SELECT GROUP_CONCAT(os.seat_label ORDER BY os.seat_label SEPARATOR ', ')
                     FROM occupied_seats os
                     WHERE os.reservation_id = fr.id) AS seats
             FROM flight_reservations fr
             JOIN flights f ON fr.flight_id = f.id
             WHERE fr.id = ? FOR UPDATE`,
            [reservationId],
            (err, oldRows) => {
                if (err || oldRows.length === 0) {
                    return db.rollback(() => res.status(404).json({ success: false, message: 'Reserva não encontrada' }));
                }
                const oldData = oldRows[0];
                const currentFlightId = oldData.flight_id;

                db.query(
                    `SELECT seat_label FROM occupied_seats
                     WHERE flight_id = ? AND reservation_id <> ? AND seat_label IN (?)`,
                    [currentFlightId, reservationId, seats],
                    (err, conflictRows) => {
                        if (err) return db.rollback(() => res.status(400).json({ success: false, message: err.message }));
                        if (conflictRows.length > 0) {
                            const used = conflictRows.map(r => r.seat_label).join(', ');
                            return db.rollback(() => res.status(409).json({ success: false, message: `Assento já ocupado: ${used}` }));
                        }

                        db.query(
                            `UPDATE flight_reservations
                             SET origin=?, destination=?, departure_date=?, arrival_date=?, return_date=?, aircraft_model=?, total_price=?, passengers_json=?, status=?
                             WHERE id=?`,
                            [origin, destination, normalizedDepartureDate, normalizedArrivalDate, normalizedReturnDate, aircraft_model, total_price, passengersPayload, status, reservationId],
                            (err) => {
                                if (err) return db.rollback(() => res.status(400).json({ success: false, message: err.message }));

                                db.query('DELETE FROM occupied_seats WHERE reservation_id = ?', [reservationId], (err) => {
                                    if (err) return db.rollback(() => res.status(400).json({ success: false, message: err.message }));

                                    const seatRows = seats.map(seat => [currentFlightId, seat, reservationId]);
                                    const placeholders = seatRows.map(() => '(?, ?, ?)').join(',');
                                    db.query(
                                        `INSERT INTO occupied_seats (flight_id, seat_label, reservation_id) VALUES ${placeholders}`,
                                        seatRows.flat(),
                                        (err) => {
                                            if (err) return db.rollback(() => res.status(400).json({ success: false, message: 'Erro ao atualizar assentos. Verifique se já estão ocupados.' }));

                                            const newData = { origin, destination, departure_date: normalizedDepartureDate, arrival_date: normalizedArrivalDate, return_date: normalizedReturnDate, aircraft_model, total_price, passengers_json: passengersPayload, status, seats };
                                            db.query(
                                                `INSERT INTO flight_reservation_history
                                                 (reservation_id, admin_name, admin_email, reason, notes, old_data, new_data)
                                                 VALUES (?, ?, ?, ?, ?, ?, ?)`,
                                                [reservationId, admin_name, admin_email, reason, notes || '', JSON.stringify(oldData), JSON.stringify(newData)],
                                                (err) => {
                                                    if (err) return db.rollback(() => res.status(400).json({ success: false, message: err.message }));
                                                    db.commit((err) => {
                                                        if (err) return db.rollback(() => res.status(500).json({ success: false, message: err.message }));
                                                        res.json({ success: true });
                                                    });
                                                }
                                            );
                                        }
                                    );
                                });
                            }
                        );
                    }
                );
            }
        );
    });
});

app.get('/admin/flights', (req, res) => {
    db.query('SELECT * FROM flights ORDER BY departure_date DESC', (err, results) => {
        res.json(results || []);
    });
});

app.post('/admin/flights', (req, res) => {
    const { origin, destination, departure_date, arrival_date, return_date, price_per_seat, aircraft_model, total_rows, seats_per_row, status } = req.body;

    if (!origin || !destination || !departure_date || !price_per_seat) {
        return res.status(400).json({ success: false, message: 'Preencha origem, destino, data e preço.' });
    }

    const normalizedDepartureDate = normalizeMySqlDateTime(departure_date);
    const normalizedArrivalDate = normalizeMySqlDateTime(arrival_date);
    const normalizedReturnDate = normalizeMySqlDateTime(return_date);

    const q = 'INSERT INTO flights (origin, destination, departure_date, arrival_date, return_date, price_per_seat, aircraft_model, total_rows, seats_per_row, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
    db.query(q, [origin, destination, normalizedDepartureDate, normalizedArrivalDate, normalizedReturnDate, price_per_seat, aircraft_model || 'Boeing 737', total_rows || 30, seats_per_row || 6, status || 'ativo'], (err) => {
        if (err) {
            console.error('❌ Erro ao cadastrar voo:', err.message);
            return res.status(400).json({ success: false, message: err.message });
        }
        res.json({ success: true });
    });
});

app.put('/admin/flights/:id', (req, res) => {
    const { origin, destination, departure_date, arrival_date, return_date, price_per_seat, aircraft_model, total_rows, seats_per_row, status } = req.body;
    const normalizedDepartureDate = normalizeMySqlDateTime(departure_date);
    const normalizedArrivalDate = normalizeMySqlDateTime(arrival_date);
    const normalizedReturnDate = normalizeMySqlDateTime(return_date);

    const q = 'UPDATE flights SET origin=?, destination=?, departure_date=?, arrival_date=?, return_date=?, price_per_seat=?, aircraft_model=?, total_rows=?, seats_per_row=?, status=? WHERE id=?';
    db.query(q, [origin, destination, normalizedDepartureDate, normalizedArrivalDate, normalizedReturnDate, price_per_seat, aircraft_model || 'Boeing 737', total_rows || 30, seats_per_row || 6, status || 'ativo', req.params.id], (err) => {
        res.json({ success: !err });
    });
});

app.delete('/admin/flights/:id', (req, res) => {
    db.query('DELETE FROM flights WHERE id = ?', [req.params.id], (err) => {
        if (err) return res.status(400).json({ success: false });
        res.json({ success: true });
    });
});

app.get('/admin/flights/:id/reservations', (req, res) => {
    db.query(
        'SELECT fr.*, u.name as user_name FROM flight_reservations fr JOIN users u ON fr.user_id = u.id WHERE fr.flight_id = ?',
        [req.params.id],
        (err, results) => {
            res.json(results || []);
        }
    );
});

app.listen(PORT, '0.0.0.0', () => console.log(`🚀 SERVIDOR RODANDO NA PORTA ${PORT}`));