uvicorn api:app --reload
streamlit run spotify_dashboard.py

docker build -t thisthiago/spotify-data-app:1.0 .

docker run -p 8000:8000 -p 8501:8501 --name spotify-data-app thisthiago/spotify-data-app:1.0 .