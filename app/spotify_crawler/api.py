from fastapi import FastAPI, Query
from typing import Optional
from pydantic import BaseModel
import sqlite3
import pandas as pd

from main import (
    criar_conexao,
    obter_tabela_spotify,
    processar_tabela_spotify,
    salvar_dataframe_no_sqlite,
    gerar_usuarios_fake,
    criar_tabela_plays,
    criar_tabela_usuarios,
    gerar_reproducoes
)

DB_PATH = "./data/temp_spotify.db"
URL_SPOTIFY = "https://kworb.net/spotify/country/global_daily.html"

app = FastAPI(title="🎵 API Spotify Fake")

def get_conn():
    return criar_conexao(DB_PATH)

@app.on_event("startup")
def setup_banco():
    with criar_conexao(DB_PATH) as conn:
        criar_tabela_usuarios(conn)
        criar_tabela_plays(conn)

        # Verifica se já tem dados na tabela
        if pd.read_sql("SELECT COUNT(*) as total FROM usuarios", conn).at[0, "total"] == 0:
            df_usuarios = gerar_usuarios_fake(10)
            salvar_dataframe_no_sqlite(df_usuarios, "usuarios", conn)

        if pd.read_sql("SELECT name FROM sqlite_master WHERE type='table' AND name='spotify_data'", conn).empty:
            tabela_spotify = obter_tabela_spotify(URL_SPOTIFY)
            if tabela_spotify is not None:
                df_spotify = processar_tabela_spotify(tabela_spotify)
                df_spotify.to_sql("spotify_data", conn, index=False, if_exists="replace")

        gerar_reproducoes(conn)


@app.post("/crawler/spotify")
def executar_crawler():
    conn = get_conn()
    tabela_spotify = obter_tabela_spotify(URL_SPOTIFY)
    if tabela_spotify is not None:
        df_spotify = processar_tabela_spotify(tabela_spotify)
        salvar_dataframe_no_sqlite(df_spotify, "spotify_data", conn)
        return {"message": "Músicas do Spotify atualizadas com sucesso."}
    return {"error": "Falha ao obter dados do Spotify."}


@app.post("/usuarios/cadastrar")
def cadastrar_usuarios(qtd: int = Query(..., gt=0, description="Quantidade de usuários para gerar")):
    conn = get_conn()
    df = gerar_usuarios_fake(qtd)
    salvar_dataframe_no_sqlite(df, "usuarios", conn)
    return {"message": f"{qtd} usuários cadastrados com sucesso."}


@app.post("/streamings/gerar")
def gerar_streamings(qtd: int = Query(..., gt=0, description="Quantidade de streamings a gerar")):
    conn = get_conn()
    criar_tabela_plays(conn)
    gerar_reproducoes(conn, qtd)
    return {"message": f"{qtd} streamings gerados com sucesso."}


@app.get("/streamings")
def listar_streamings():
    conn = get_conn()
    df = pd.read_sql("""
        SELECT p.id, u.nome, s.Artist || ' - ' || s.Title as musica, p.timestamp
        FROM plays p
        JOIN usuarios u ON u.id = p.id_usuario
        JOIN spotify_data s ON s.id = p.id_musica
    """, conn)
    return df.to_dict(orient="records")


@app.get("/musicas")
def listar_musicas():
    conn = get_conn()
    df = pd.read_sql("SELECT * FROM spotify_data", conn)
    return df.to_dict(orient="records")


@app.get("/usuarios")
def listar_usuarios():
    conn = get_conn()
    df = pd.read_sql("SELECT * FROM usuarios", conn)
    return df.to_dict(orient="records")
