CREATE TABLE pokemon_rarity (
  id SERIAL PRIMARY KEY,
  rarity_name VARCHAR(100) UNIQUE
);

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
  rarity_id INT NULL,
  FOREIGN KEY (rarity_id) REFERENCES pokemon_rarity(id)
);

CREATE TABLE price_dates (
  id SERIAL PRIMARY KEY,
  price_date DATE UNIQUE NOT NULL
);

CREATE TABLE pokemon_prices (
  id SERIAL PRIMARY KEY,
  rarity_id INT NULL,
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
  FOREIGN KEY (rarity_id) REFERENCES pokemon_rarity(id),
  FOREIGN KEY (price_date_id) REFERENCES price_dates(id)
);



SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'pokemon_prices';


ALTER TABLE pokemon_prices ALTER COLUMN rarity_id SET DATA TYPE BIGINT;
ALTER TABLE pokemon_prices ALTER COLUMN price_date_id SET DATA TYPE BIGINT;



ALTER TABLE pokemon_cards ALTER COLUMN pokedex_number SET DATA TYPE BIGINT;
ALTER TABLE pokemon_cards ALTER COLUMN hp SET DATA TYPE BIGINT;
ALTER TABLE pokemon_cards ALTER COLUMN retreat_cost SET DATA TYPE BIGINT;




ALTER TABLE pokemon_prices 
ALTER COLUMN market_price_normal SET DATA TYPE NUMERIC(15,2),
ALTER COLUMN low_price_normal SET DATA TYPE NUMERIC(15,2),
ALTER COLUMN high_price_normal SET DATA TYPE NUMERIC(15,2),
ALTER COLUMN market_price_reverse_holofoil SET DATA TYPE NUMERIC(15,2),
ALTER COLUMN low_price_reverse_holofoil SET DATA TYPE NUMERIC(15,2),
ALTER COLUMN high_price_reverse_holofoil SET DATA TYPE NUMERIC(15,2),
ALTER COLUMN market_price_holofoil SET DATA TYPE NUMERIC(15,2),
ALTER COLUMN low_price_holofoil SET DATA TYPE NUMERIC(15,2),
ALTER COLUMN high_price_holofoil SET DATA TYPE NUMERIC(15,2);




SELECT c.name, r.rarity_name, p.market_price_holofoil
FROM pokemon_cards c
JOIN pokemon_prices p ON c.rarity_id = p.rarity_id
JOIN price_dates pd ON p.price_date_id = pd.id
JOIN pokemon_rarity r ON c.rarity_id = r.id
WHERE pd.price_date = (SELECT MAX(price_date) FROM price_dates)
ORDER BY p.market_price_holofoil DESC
LIMIT 5;