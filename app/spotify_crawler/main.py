import pandas as pd
import sqlite3
from faker import Faker
from datetime import datetime
import random

# Caminho do banco de dados SQLite
DB_PATH = "./data/temp_spotify.db"

# URL da tabela do Spotify
URL_SPOTIFY = "https://kworb.net/spotify/country/global_daily.html"


def criar_conexao(db_path):
    """Cria conexão com o banco de dados SQLite."""
    return sqlite3.connect(db_path)


def obter_tabela_spotify(url):
    """Lê a tabela do site do Spotify (Kworb)."""
    tables = pd.read_html(url)
    return tables[0] if tables else None


def processar_tabela_spotify(df):
    """Processa a tabela do Spotify para extrair colunas relevantes."""
    df = df[["Pos", "Artist and Title"]].copy()
    df.rename(columns={"Pos": "id"}, inplace=True)
    df[["Artist", "Title"]] = df["Artist and Title"].str.split(" - ", n=1, expand=True)
    df.drop(columns=["Artist and Title"], inplace=True)
    df["timestamp"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    return df


def salvar_dataframe_no_sqlite(df, tabela, conn):
    """Salva um DataFrame como tabela no banco SQLite."""
    df.to_sql(tabela, conn, index=False, if_exists="replace")


def gerar_usuarios_fake(n=10):
    """Gera usuários falsos com nome, email e timestamp."""
    fake_pt = Faker("pt_BR")
    fake_en = Faker("en_US")
    fake_es = Faker("es_ES")
    fake_fr = Faker("fr_FR")  
    fake_de = Faker("de_DE")  
    
    locales = [
        ("pt_BR", fake_pt),  
        ("en_US", fake_en),   
        ("es_ES", fake_es),   
        ("fr_FR", fake_fr),   
        ("de_DE", fake_de)    
    ]
    
    usuarios = []
    
    for i in range(n):
        locale, fake = random.choice(locales)
        
        if locale in ["fr_FR", "de_DE"]:  
            if random.random() < 0.5:
                nome = fake.first_name_male() + " " + fake.last_name()
            else:
                nome = fake.first_name_female() + " " + fake.last_name()
        else:
            nome = fake.name()
            
        if locale != "ja_JP" and random.random() < 0.2:
            titulos = ["Dr.", "Prof.", "Sr.", "Sra.", "Mr.", "Mrs.", "Ms."]
            nome = random.choice(titulos) + " " + nome
        
        usuarios.append({
            "id": i + 1,
            "nome": nome,
            "email": fake.email(),
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        })
    
    return pd.DataFrame(usuarios)

def criar_tabela_plays(conn):
    """Cria a tabela de reproduções (plays)."""
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS plays (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_usuario INTEGER,
            id_musica INTEGER,
            timestamp DATETIME,
            FOREIGN KEY (id_usuario) REFERENCES usuarios(id),
            FOREIGN KEY (id_musica) REFERENCES spotify_data(id)
        );
    """)
    conn.commit()


def gerar_reproducoes(conn, quantidade_plays=50):
    """Gera reproduções aleatórias com timestamp atual."""
    df_usuarios = pd.read_sql("SELECT id FROM usuarios", conn)
    df_musicas = pd.read_sql("SELECT id FROM spotify_data", conn)

    if df_usuarios.empty or df_musicas.empty:
        print("Erro: Tabelas de usuários ou músicas estão vazias.")
        return

    dados = []
    for _ in range(quantidade_plays):
        id_usuario = random.choice(df_usuarios["id"].tolist())
        id_musica = random.choice(df_musicas["id"].tolist())
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        dados.append((id_usuario, id_musica, timestamp))

    cursor = conn.cursor()
    cursor.executemany("""
        INSERT INTO plays (id_usuario, id_musica, timestamp)
        VALUES (?, ?, ?)
    """, dados)
    conn.commit()


def main():
    with criar_conexao(DB_PATH) as conn:
        # Etapa 1: Spotify
        tabela_spotify = obter_tabela_spotify(URL_SPOTIFY)
        if tabela_spotify is not None:
            df_spotify = processar_tabela_spotify(tabela_spotify)
            salvar_dataframe_no_sqlite(df_spotify, "spotify_data", conn)
            print("🎵 Spotify:")
            print(pd.read_sql("SELECT * FROM spotify_data LIMIT 5", conn))
        else:
            print("Nenhuma tabela encontrada na página do Spotify.")

        # Etapa 2: Usuários
        df_usuarios = gerar_usuarios_fake(10)
        salvar_dataframe_no_sqlite(df_usuarios, "usuarios", conn)
        print("\n👤 Usuários:")
        print(pd.read_sql("SELECT * FROM usuarios LIMIT 5", conn))

        # Etapa 3: Reproduções
        criar_tabela_plays(conn)
        gerar_reproducoes(conn, quantidade_plays=50)
        print("\n▶️ Reproduções:")
        print(pd.read_sql("""
            SELECT p.id, u.nome, s.Artist || ' - ' || s.Title as musica, p.timestamp
            FROM plays p
            JOIN usuarios u ON u.id = p.id_usuario
            JOIN spotify_data s ON s.id = p.id_musica
            LIMIT 5;
        """, conn))


if __name__ == "__main__":
    main()
