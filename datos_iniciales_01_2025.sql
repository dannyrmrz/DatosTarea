CREATE TABLE pokemon_cards (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  pokedex_number INT,
  supertype VARCHAR(100),
  subtypes VARCHAR(255),
  hp INT,
  types VARCHAR(255),
  attacks TEXT,
  weaknesses VARCHAR(255),
  retreat_cost INT,
  set_name VARCHAR(255),
  artist VARCHAR(255),
  rarity_id INT
);

CREATE TABLE pokemon_rarity (
  id SERIAL PRIMARY KEY,
  rarity_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE price_dates (
  id SERIAL PRIMARY KEY,
  price_date DATE UNIQUE NOT NULL
);

CREATE TABLE pokemon_prices (
  id SERIAL PRIMARY KEY,
  card_id INT NOT NULL,
  price_date_id INT NOT NULL,
  market_price_normal NUMERIC(10,2),
  low_price_normal NUMERIC(10,2),
  high_price_normal NUMERIC(10,2),
  market_price_reverse_holofoil NUMERIC(10,2),
  low_price_reverse_holofoil NUMERIC(10,2),
  high_price_reverse_holofoil NUMERIC(10,2),
  market_price_holofoil NUMERIC(10,2),
  low_price_holofoil NUMERIC(10,2),
  high_price_holofoil NUMERIC(10,2),
  FOREIGN KEY (card_id) REFERENCES pokemon_cards(id),
  FOREIGN KEY (price_date_id) REFERENCES price_dates(id)
);

ALTER TABLE pokemon_cards 
ADD FOREIGN KEY (rarity_id) REFERENCES pokemon_rarity(id);
