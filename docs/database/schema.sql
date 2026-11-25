-- Almaty Tourist Guide: деректер қоры (PostgreSQL)
DROP TABLE IF EXISTS route_places, reviews, routes, places, categories, users CASCADE;

CREATE TABLE users (
    user_id   SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email     VARCHAR(100) NOT NULL UNIQUE,
    role      VARCHAR(20)  NOT NULL DEFAULT 'tourist'
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name        VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE places (
    place_id     SERIAL PRIMARY KEY,
    name         VARCHAR(120) NOT NULL,
    description  TEXT,
    address      VARCHAR(200) NOT NULL,
    ticket_price INTEGER NOT NULL DEFAULT 0,
    category_id  INTEGER NOT NULL REFERENCES categories(category_id)
);

CREATE TABLE reviews (
    review_id  SERIAL PRIMARY KEY,
    user_id    INTEGER NOT NULL REFERENCES users(user_id),
    place_id   INTEGER NOT NULL REFERENCES places(place_id),
    rating     INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment    TEXT,
    created_at DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE routes (
    route_id   SERIAL PRIMARY KEY,
    user_id    INTEGER NOT NULL REFERENCES users(user_id),
    title      VARCHAR(100) NOT NULL,
    created_at DATE NOT NULL DEFAULT CURRENT_DATE
);

-- M:N аралық кесте: маршрут <-> орын
CREATE TABLE route_places (
    route_id    INTEGER NOT NULL REFERENCES routes(route_id),
    place_id    INTEGER NOT NULL REFERENCES places(place_id),
    visit_order INTEGER NOT NULL,
    PRIMARY KEY (route_id, place_id)
);

INSERT INTO users (full_name, email, role) VALUES
 ('Айгерім Нұрланқызы', 'aigerim@mail.kz', 'tourist'),
 ('Данияр Серіков', 'daniyar@mail.kz', 'tourist'),
 ('John Smith', 'john@mail.com', 'tourist'),
 ('Әкімші', 'admin@guide.kz', 'admin');

INSERT INTO categories (name) VALUES
 ('Табиғат'), ('Мәдениет'), ('Сауда'), ('Тарих');

INSERT INTO places (name, description, address, ticket_price, category_id) VALUES
 ('Шымбұлақ', 'Таулы шаңғы курорты', 'Іле Алатауы', 8000, 1),
 ('Медеу', 'Биік таудағы мұз айдыны', 'Медеу шатқалы', 3000, 1),
 ('Көк төбе', 'Қала панорамасы бар төбе', 'Көк төбе', 2000, 1),
 ('Жасыл базар', 'Орталық базар', 'Жібек жолы к-сі', 0, 3),
 ('Мемлекеттік музей', 'Қазақстан тарихы мұражайы', 'Достық даңғылы', 1500, 4),
 ('Панфилов саябағы', 'Қала орталығындағы саябақ', 'Желтоқсан к-сі', 0, 2);

INSERT INTO reviews (user_id, place_id, rating, comment) VALUES
 (1, 1, 5, 'Керемет көрініс'),
 (2, 1, 4, 'Қымбат, бірақ ұнады'),
 (3, 2, 5, 'Міндетті түрде барыңыз'),
 (1, 4, 4, 'Тәтті жемістер көп'),
 (2, 5, 3, 'Қызықты экспозиция');

INSERT INTO routes (user_id, title) VALUES
 (1, 'Бір күндік тау маршруты'),
 (2, 'Тарихи серуен'),
 (3, 'Қала бойынша тур');

INSERT INTO route_places (route_id, place_id, visit_order) VALUES
 (1, 2, 1), (1, 1, 2),
 (2, 5, 1), (2, 6, 2), (2, 4, 3),
 (3, 3, 1), (3, 4, 2), (3, 6, 3);

-- Сұраныс 1: 3 кестені JOIN (маршрут, қолданушы, орын)
SELECT r.title AS route, u.full_name AS tourist, p.name AS place, rp.visit_order
FROM routes r
JOIN users u        ON u.user_id = r.user_id
JOIN route_places rp ON rp.route_id = r.route_id
JOIN places p       ON p.place_id = rp.place_id
ORDER BY r.route_id, rp.visit_order;

-- Сұраныс 2: GROUP BY (орындардың орташа рейтингі)
SELECT p.name, COUNT(rv.review_id) AS reviews_count, ROUND(AVG(rv.rating), 1) AS avg_rating
FROM places p
JOIN reviews rv ON rv.place_id = p.place_id
GROUP BY p.name
ORDER BY avg_rating DESC;
