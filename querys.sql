SELECT c.name, r.rarity_name, MAX(p.market_price_holofoil) AS market_price_holofoil
FROM pokemon_cards c
JOIN pokemon_prices p ON c.rarity_id = p.rarity_id
JOIN price_dates pd ON p.price_date_id = pd.id
JOIN pokemon_rarity r ON c.rarity_id = r.id
WHERE pd.price_date = (SELECT MAX(price_date) FROM price_dates)
AND p.market_price_holofoil IS NOT NULL
GROUP BY c.name, r.rarity_name
ORDER BY market_price_holofoil DESC
LIMIT 5;

SELECT COUNT(*) AS cartas_mayores_a_100
FROM pokemon_prices p
JOIN price_dates pd ON p.price_date_id = pd.id
WHERE pd.price_date = (SELECT MAX(price_date) FROM price_dates)
AND p.market_price_holofoil > 100;

SELECT AVG(p.market_price_holofoil) AS precio_promedio_holofoil
FROM pokemon_prices p
JOIN price_dates pd ON p.price_date_id = pd.id
WHERE pd.price_date = (SELECT MAX(price_date) FROM price_dates);

SELECT c.name, r.rarity_name, p1.market_price_holofoil AS precio_anterior, p2.market_price_holofoil AS precio_actual
FROM pokemon_prices p1
JOIN pokemon_prices p2 ON p1.rarity_id = p2.rarity_id
JOIN price_dates pd1 ON p1.price_date_id = pd1.id
JOIN price_dates pd2 ON p2.price_date_id = pd2.id
JOIN pokemon_cards c ON p1.rarity_id = c.rarity_id
JOIN pokemon_rarity r ON c.rarity_id = r.id
WHERE pd1.price_date = (SELECT MAX(price_date) FROM price_dates WHERE price_date < (SELECT MAX(price_date) FROM price_dates))
AND pd2.price_date = (SELECT MAX(price_date) FROM price_dates)
AND p2.market_price_holofoil < p1.market_price_holofoil;

SELECT c.types, AVG(p.market_price_holofoil) AS avg_price
FROM pokemon_cards c
JOIN pokemon_prices p ON c.rarity_id = p.rarity_id
JOIN price_dates pd ON p.price_date_id = pd.id
WHERE pd.price_date = (SELECT MAX(price_date) FROM price_dates)
AND p.market_price_holofoil IS NOT NULL
AND c.types IS NOT NULL
GROUP BY c.types
ORDER BY avg_price DESC
LIMIT 1;

SELECT 
  MAX(p.market_price_holofoil) - MIN(p.market_price_holofoil) AS diferencia_precio
FROM pokemon_prices p
JOIN price_dates pd ON p.price_date_id = pd.id
WHERE pd.price_date = (SELECT MAX(price_date) FROM price_dates);

SELECT COUNT(*) AS cartas_completas
FROM pokemon_prices p
JOIN price_dates pd ON p.price_date_id = pd.id
WHERE pd.price_date = (SELECT MAX(price_date) FROM price_dates)
AND p.market_price_normal IS NOT NULL
AND p.market_price_reverse_holofoil IS NOT NULL
AND p.market_price_holofoil IS NOT NULL;

SELECT MAX(price_date) AS ultima_actualizacion
FROM price_dates;

SELECT c.types, AVG(p.market_price_holofoil) AS avg_price
FROM pokemon_cards c
JOIN pokemon_prices p ON c.rarity_id = p.rarity_id
JOIN price_dates pd ON p.price_date_id = pd.id
WHERE pd.price_date = (SELECT MAX(price_date) FROM price_dates)
AND p.market_price_holofoil IS NOT NULL
AND c.types IS NOT NULL
GROUP BY c.types
ORDER BY avg_price DESC
LIMIT 1;

SELECT c.name, 
       (p.high_price_holofoil - p.low_price_holofoil) AS price_difference
FROM pokemon_cards c
JOIN pokemon_prices p ON c.rarity_id = p.rarity_id
JOIN price_dates pd ON p.price_date_id = pd.id
WHERE pd.price_date = (SELECT MAX(price_date) FROM price_dates)
AND p.high_price_holofoil IS NOT NULL
AND p.low_price_holofoil IS NOT NULL
ORDER BY price_difference DESC
LIMIT 3;

WITH RankedCards AS (
    SELECT c.types, c.name, p.market_price_holofoil,
           ROW_NUMBER() OVER (PARTITION BY c.types ORDER BY p.market_price_holofoil DESC) AS rank
    FROM pokemon_cards c
    JOIN pokemon_prices p ON c.rarity_id = p.rarity_id
    JOIN price_dates pd ON p.price_date_id = pd.id
    WHERE pd.price_date = (SELECT MAX(price_date) FROM price_dates)
    AND p.market_price_holofoil IS NOT NULL
)
SELECT types, name, market_price_holofoil
FROM RankedCards
WHERE rank = 1;


