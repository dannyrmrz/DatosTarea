import psycopg2
import pandas as pd
import os
import re
import numpy as np

DB_CONFIG = {
    "dbname": "Ejercicio 4",
    "user": "javiercarredano",
    "password": "nievedelimon",
    "host": "127.0.0.1",
    "port": "5432"
}


#Cambiar por el path donde instalaron los archivos CSV
CSV_FILES = [
    "/Users/javiercarredano/Downloads/vintage_pkmn_cards_feb2025.csv",
    "/Users/javiercarredano/Downloads/vintage_pkmn_cards_mar2025.csv",
    "/Users/javiercarredano/Downloads/modern_pkmn_cards_mar2025.csv"
]

def connect_db():
    return psycopg2.connect(**DB_CONFIG)

def extract_date_from_filename(filename):
    match = re.search(r"(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)(\d{4})", filename, re.IGNORECASE)
    if match:
        month_str, year = match.groups()
        months = {"jan": "01", "feb": "02", "mar": "03", "apr": "04", "may": "05",
                  "jun": "06", "jul": "07", "aug": "08", "sep": "09", "oct": "10", "nov": "11", "dec": "12"}
        return f"{year}-{months[month_str.lower()]}-01"
    return None

def insert_rarities(cursor, rarity_list):
    # Convertir NaN a None y luego a strings válidos
    clean_rarities = [None if pd.isna(r) else str(r) for r in rarity_list]
    # Filtrar valores None para no insertarlos
    cursor.executemany(
        "INSERT INTO pokemon_rarity (rarity_name) VALUES (%s) ON CONFLICT (rarity_name) DO NOTHING;",
        [(r,) for r in clean_rarities if r is not None]
    )

def get_rarity_id(cursor, rarity_name):
    if pd.isna(rarity_name) or rarity_name is None:
        return None
        
    cursor.execute("SELECT id FROM pokemon_rarity WHERE rarity_name = %s;", (str(rarity_name),))
    result = cursor.fetchone()
    return result[0] if result else None

def insert_cards(cursor, df):
    for _, row in df.iterrows():
        rarity_id = get_rarity_id(cursor, row["Rarity"])
        cursor.execute("""
            INSERT INTO pokemon_cards (
                name, pokedex_number, supertype, subtypes, hp, 
                types, attacks, weaknesses, retreat_cost, set_name, artist, rarity_id
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id;
        """, (
            None if pd.isna(row["Name"]) else row["Name"],
            None if pd.isna(row["Pokedex Number"]) else int(row["Pokedex Number"]),
            None if pd.isna(row["Supertype"]) else row["Supertype"],
            None if pd.isna(row["Subtypes"]) else row["Subtypes"],
            None if pd.isna(row["HP"]) else int(row["HP"]),
            None if pd.isna(row["Types"]) else row["Types"],
            None if pd.isna(row["Attacks"]) else row["Attacks"],
            None if pd.isna(row["Weaknesses"]) else row["Weaknesses"],
            None if pd.isna(row["Retreat Cost"]) else int(row["Retreat Cost"]),
            None if pd.isna(row["Set Name"]) else row["Set Name"],
            None if pd.isna(row["Artist"]) else row["Artist"],
            rarity_id
        ))

def insert_price_date(cursor, date):
    cursor.execute("INSERT INTO price_dates (price_date) VALUES (%s) ON CONFLICT (price_date) DO NOTHING;", (date,))
    cursor.execute("SELECT id FROM price_dates WHERE price_date = %s;", (date,))
    return cursor.fetchone()[0]

def insert_prices(cursor, df, price_date_id):
    for _, row in df.iterrows():
        rarity_id = get_rarity_id(cursor, row["Rarity"])
        cursor.execute("""
            INSERT INTO pokemon_prices (
                rarity_id, price_date_id, 
                market_price_normal, low_price_normal, high_price_normal,
                market_price_reverse_holofoil, low_price_reverse_holofoil, high_price_reverse_holofoil,
                market_price_holofoil, low_price_holofoil, high_price_holofoil
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
        """, (
            rarity_id, 
            price_date_id, 
            None if pd.isna(row["TCG Market Price USD (Normal)"]) else row["TCG Market Price USD (Normal)"],
            None if pd.isna(row["TCG Low Price USD (Normal)"]) else row["TCG Low Price USD (Normal)"],
            None if pd.isna(row["TCG High Price USD (Normal)"]) else row["TCG High Price USD (Normal)"],
            None if pd.isna(row["TCG Market Price USD (Reverse Holofoil)"]) else row["TCG Market Price USD (Reverse Holofoil)"],
            None if pd.isna(row["TCG Low Price USD (Reverse Holofoil)"]) else row["TCG Low Price USD (Reverse Holofoil)"],
            None if pd.isna(row["TCG High Price USD (Reverse Holofoil)"]) else row["TCG High Price USD (Reverse Holofoil)"],
            None if pd.isna(row["TCG Market Price USD (Holofoil)"]) else row["TCG Market Price USD (Holofoil)"],
            None if pd.isna(row["TCG Low Price USD (Holofoil)"]) else row["TCG Low Price USD (Holofoil)"],
            None if pd.isna(row["TCG High Price USD (Holofoil)"]) else row["TCG High Price USD (Holofoil)"]
        ))

def process_csv(file_path):
    date_str = extract_date_from_filename(file_path)
    if not date_str:
        print(f"No se pudo extraer la fecha de {file_path}, omitiendo...")
        return

    print(f"Procesando {file_path} con fecha {date_str}")

    # Leer CSV y convertir NaN a None
    df = pd.read_csv(file_path).replace({np.nan: None})
    
    conn = connect_db()
    cursor = conn.cursor()

    try:
        # Insertar rarezas (solo valores no nulos)
        rarities = [r for r in df["Rarity"].unique() if r is not None]
        insert_rarities(cursor, rarities)

        # Insertar cartas
        insert_cards(cursor, df)

        # Insertar fecha de precios
        price_date_id = insert_price_date(cursor, date_str)

        # Insertar precios
        insert_prices(cursor, df, price_date_id)

        conn.commit()
        print(f"Datos de {file_path} insertados correctamente.")

    except Exception as e:
        conn.rollback()
        print(f"Error al procesar {file_path}: {e}")
        raise e  # Opcional: quita esto si no quieres ver el traceback completo

    finally:
        cursor.close()
        conn.close()

# Ejecutar el procesamiento
for file in CSV_FILES:
    if os.path.exists(file):
        process_csv(file)
    else:
        print(f"Archivo no encontrado: {file}")