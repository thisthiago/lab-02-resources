import streamlit as st
import requests
import pandas as pd
from datetime import datetime

# Configurações da página
st.set_page_config(
    page_title="🎵 Spotify Fake Dashboard",
    page_icon="🎧",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Estilos CSS personalizados
st.markdown("""
    <style>
    .main {
        background-color: #191414;
    }
    h1, h2, h3, h4, h5, h6 {
        color: #1DB954 !important;
    }
    .stButton>button {
        background-color: #1DB954;
        color: white;
        border-radius: 20px;
        padding: 10px 24px;
        border: none;
    }
    .stTextInput>div>div>input, .stNumberInput>div>div>input {
        border-radius: 20px;
        padding: 10px 12px;
    }
    .css-1aumxhk {
        background-color: #191414;
    }
    </style>
    """, unsafe_allow_html=True)

# URL base da API (ajuste conforme necessário)
API_BASE_URL = "http://localhost:8000"

# Título da aplicação
st.title("🎵 Spotify Fake Dashboard")
st.markdown("---")

# Sidebar com ações
with st.sidebar:
    st.header("⚙️ Configurações")
    
    st.subheader("Atualizar Dados")
    if st.button("🔄 Atualizar Músicas do Spotify"):
        with st.spinner("Atualizando músicas..."):
            response = requests.post(f"{API_BASE_URL}/crawler/spotify")
            if response.status_code == 200:
                st.success("Músicas atualizadas com sucesso!")
            else:
                st.error("Erro ao atualizar músicas.")
    
    st.subheader("Gerar Dados Fakes")
    qtd_usuarios = st.number_input("Número de usuários", min_value=1, value=10)
    if st.button("👥 Gerar Usuários"):
        with st.spinner(f"Gerando {qtd_usuarios} usuários..."):
            response = requests.post(f"{API_BASE_URL}/usuarios/cadastrar?qtd={qtd_usuarios}")
            if response.status_code == 200:
                st.success(f"{qtd_usuarios} usuários gerados com sucesso!")
            else:
                st.error("Erro ao gerar usuários.")
    
    qtd_streamings = st.number_input("Número de streamings", min_value=1, value=50)
    if st.button("▶️ Gerar Streamings"):
        with st.spinner(f"Gerando {qtd_streamings} streamings..."):
            response = requests.post(f"{API_BASE_URL}/streamings/gerar?qtd={qtd_streamings}")
            if response.status_code == 200:
                st.success(f"{qtd_streamings} streamings gerados com sucesso!")
            else:
                st.error("Erro ao gerar streamings.")

# Abas principais
tab1, tab2, tab3 = st.tabs(["🎧 Streamings", "🎵 Músicas", "👥 Usuários"])

with tab1:
    st.header("Histórico de Streamings")
    if st.button("🔄 Atualizar Streamings"):
        pass  # A tabela será atualizada automaticamente
    
    try:
        response = requests.get(f"{API_BASE_URL}/streamings")
        if response.status_code == 200:
            df_streamings = pd.DataFrame(response.json())
            df_streamings['timestamp'] = pd.to_datetime(df_streamings['timestamp'])
            
            # Filtros
            col1, col2 = st.columns(2)
            with col1:
                data_inicio = st.date_input("Data inicial", df_streamings['timestamp'].min())
            with col2:
                data_fim = st.date_input("Data final", df_streamings['timestamp'].max())
            
            df_filtrado = df_streamings[
                (df_streamings['timestamp'].dt.date >= data_inicio) & 
                (df_streamings['timestamp'].dt.date <= data_fim)
            ]
            
            st.dataframe(
                df_filtrado.sort_values('timestamp', ascending=False),
                column_config={
                    "id": "ID",
                    "nome": "Usuário",
                    "musica": "Música",
                    "timestamp": "Data/Hora"
                },
                hide_index=True,
                use_container_width=True
            )
            
            # Métricas
            st.subheader("📊 Estatísticas")
            col1, col2, col3 = st.columns(3)
            col1.metric("Total Streamings", len(df_filtrado))
            col2.metric("Usuários Únicos", df_filtrado['nome'].nunique())
            col3.metric("Músicas Únicas", df_filtrado['musica'].nunique())
            
            # Top músicas
            st.subheader("🔥 Top Músicas")
            top_musicas = df_filtrado['musica'].value_counts().head(10).reset_index()
            top_musicas.columns = ['Música', 'Reproduções']
            st.bar_chart(top_musicas.set_index('Música'))
            
        else:
            st.error("Erro ao carregar streamings.")
    except Exception as e:
        st.error(f"Erro ao conectar com a API: {e}")

with tab2:
    st.header("Catálogo de Músicas")
    if st.button("🔄 Atualizar Músicas"):
        pass  # A tabela será atualizada automaticamente
    
    try:
        response = requests.get(f"{API_BASE_URL}/musicas")
        if response.status_code == 200:
            df_musicas = pd.DataFrame(response.json())
            
            # Filtro por artista
            artistas = df_musicas['Artist'].unique()
            artista_selecionado = st.selectbox("Filtrar por artista", ["Todos"] + list(artistas))
            
            if artista_selecionado != "Todos":
                df_musicas = df_musicas[df_musicas['Artist'] == artista_selecionado]
            
            st.dataframe(
                df_musicas,
                column_config={
                    "id": "ID",
                    "Artist": "Artista",
                    "Title": "Título",
                    "Streams": "Streams",
                    "Total": "Total"
                },
                hide_index=True,
                use_container_width=True
            )
        else:
            st.error("Erro ao carregar músicas.")
    except Exception as e:
        st.error(f"Erro ao conectar com a API: {e}")

with tab3:
    st.header("Usuários Cadastrados")
    if st.button("🔄 Atualizar Usuários"):
        pass  # A tabela será atualizada automaticamente
    
    try:
        response = requests.get(f"{API_BASE_URL}/usuarios")
        if response.status_code == 200:
            df_usuarios = pd.DataFrame(response.json())
            
            st.dataframe(
                df_usuarios,
                column_config={
                    "id": "ID",
                    "nome": "Nome",
                    "email": "E-mail",
                    "idade": "Idade",
                    "pais": "País",
                    "plano": "Plano"
                },
                hide_index=True,
                use_container_width=True
            )
            
            
        else:
            st.error("Erro ao carregar usuários.")
    except Exception as e:
        st.error(f"Erro ao conectar com a API: {e}")

# Rodapé
st.markdown("---")
st.markdown("""
    <div style="text-align: center; color: #1DB954;">
        <p>🎶 Spotify Fake Dashboard - Desenvolvido com FastAPI e Streamlit</p>
    </div>
""", unsafe_allow_html=True)