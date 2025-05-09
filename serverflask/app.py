from flask import Flask, request, jsonify
import pandas as pd
import numpy as np
import os
import joblib
from werkzeug.utils import secure_filename
from datetime import datetime
from collections import Counter
from flask import Flask, request, jsonify
import numpy as np
import cv2
import mediapipe as mp
import pickle
import joblib
from tensorflow.keras.models import load_model as keras_load_model
from PIL import Image
from io import BytesIO
import traceback
from pydub import AudioSegment
import librosa
import tempfile
from flask_cors import CORS
from audio_tools import get_feature_from_array 

app = Flask(__name__)
CORS(app)

# Configuration
UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max



# Load image model and supporting tools
image_model = keras_load_model("image_emotion_model.keras")
with open("image_label_encoder.pkl", "rb") as f:
    image_label_encoder = pickle.load(f)
with open("image_scaler.pkl", "rb") as f:
    image_scaler = pickle.load(f)
#load audio model
audio_encoder = joblib.load('audio_encoder.pkl')
audio_scaler = joblib.load('audio_scaler.pkl')
audio_model=load_model("audio_model_cnn.keras")
image_model_accuracy= 0.74
audio_model_accuracy= 0.80


# Reuse MediaPipe FaceMesh instance
mp_face_mesh = mp.solutions.face_mesh
face_mesh = mp_face_mesh.FaceMesh(static_image_mode=True, max_num_faces=1)

# Chargement du modèle KNN
try:
    knn_model = joblib.load('knn_emotion_model.pkl')
    print("✅ Modèle KNN chargé avec succès")
except Exception as e:
    print(f"❌ Erreur de chargement du modèle: {str(e)}")
    exit(1)

# Fonctions de traitement des séries temporelles (à adapter selon vos besoins)
def zero_crossings(series):
    return np.sum(np.diff(np.sign(series))) / 2

def mean_energy(series):
    return np.mean(series**2)

def mean_curve_length(series):
    return np.sum(np.abs(np.diff(series)))

def mean_teager_energy(series):
    return np.mean(series[1:-1]**2 - series[2:] * series[:-2])

def adjust_to_300_rows(df):
    """Ajuste le DataFrame à exactement 300 lignes"""
    current_rows = len(df)
    
    if current_rows < 300:
        # Ajout de lignes avec des 0
        missing_rows = 300 - current_rows
        empty_data = {col: [0] * missing_rows for col in df.columns}
        empty_df = pd.DataFrame(empty_data)
        df = pd.concat([df, empty_df], ignore_index=True)
    elif current_rows > 300:
        # Suppression des lignes excédentaires
        df = df.head(300)
    
    return df

def process_file(filepath):
    try:
        df = pd.read_csv(filepath)

        # ⚠️ Ajuster à 300 lignes
        df = adjust_to_300_rows(df)

        # ✅ Définir les features originaux
        original_features = [
            "Age", "Gender",
            "Gravity X", "Gravity Y", "Gravity Z", "Gravity Magnitude",
            "Linear Acceleration X", "Linear Acceleration Y", "Linear Acceleration Z", "Linear Acceleration Magnitude",
            "Gyroscope X", "Gyroscope Y", "Gyroscope Z", "Gyroscope Magnitude"
        ]

        selected_features = {
            "Gravity X": ["max", "min", "kurt", "ZC", "ME", "MCL", "MTE", "Q1", "Q3", "sum"],
            "Gravity Y": ["min", "max", "ZC", "MCL", "median", "sum"],
            "Gravity Z": ["min", "max", "mean", "ZC", "ME", "median", "Q1"],
            "Linear Acceleration X": ["min", "max", "var", "skew", "ZC", "ME", "MCL", "median", "Q1", "Q3"],
            "Linear Acceleration Y": ["max", "mean", "skew", "ZC", "ME", "median", "Q1", "Q3", "sum"],
            "Linear Acceleration Z": ["min", "max", "mean", "var", "ZC", "ME", "MCL", "MTE", "Q3"],
            "Linear Acceleration Magnitude": ["var", "MCL", "median", "Q1", "sum"],
            "Gyroscope X": ["min", "std", "kurt", "ZC", "ME", "MTE"],
            "Gyroscope Y": ["max", "skew", "ZC", "MCL", "MTE", "sum"],
            "Gyroscope Z": ["mean", "MCL", "MTE", "Q1", "sum"],
            "Gyroscope Magnitude": ["min", "max", "skew", "ME", "MCL", "median", "Q3"]
        }

        # 🧠 Fonctions personnalisées
        def zero_crossings(series):
            return np.count_nonzero(np.diff(np.sign(series)))

        def mean_energy(series):
            return np.mean(series ** 2)

        def mean_curve_length(series):
            series = series.dropna().values
            return np.mean(np.abs(np.diff(series))) if len(series) > 1 else 0

        def mean_teager_energy(series):
            series = series.dropna().values
            return np.mean(series[:-1] ** 2 - series[:-1] * series[1:]) if len(series) > 1 else 0

        # 🎯 Traitement
        age = df["Age"].iloc[0]
        gender = df["Gender"].iloc[0]
        
        gender_dummies = pd.get_dummies(df['Gender'], drop_first=True)
        gender_val = 0 # Obtenir la première valeur, qui sera 0 ou 1

        # Ajouter 'Age' et d'autres caractéristiques si nécessaire
        feature_values = {"Age": df["Age"].iloc[0], "Gender_Male": gender_val}

        for feature, stat_list in selected_features.items():
            if feature not in df.columns:
                continue

            series = df[feature].dropna()
            computed_stats = {
                "mean": series.mean(),
                "min": series.min(),
                "max": series.max(),
                "std": series.std(),
                "var": series.var(),
                "skew": series.skew(),
                "kurt": series.kurt(),
                "sum": series.sum(),
                "Q1": series.quantile(0.25),
                "median": series.median(),
                "Q3": series.quantile(0.75),
                "ZC": zero_crossings(series),
                "ME": mean_energy(series),
                "MCL": mean_curve_length(series),
                "MTE": mean_teager_energy(series)
            }

            for stat in stat_list:
                if stat in computed_stats:
                    feature_values[f"{feature}_{stat}"] = computed_stats[stat]
                else:
                    print(f"⚠️ Stat {stat} introuvable pour {feature}")

        df_result = pd.DataFrame([feature_values])

        # L'ordre final des colonnes que tu veux
        final_column_order = [
            'Age', 'Gravity X_max', 'Gravity X_min', 'Gravity X_kurt', 'Gravity X_ZC', 'Gravity X_ME', 'Gravity X_MCL', 'Gravity X_MTE', 'Gravity X_Q1', 'Gravity X_Q3', 'Gravity X_sum', 
            'Gravity Y_min', 'Gravity Y_max', 'Gravity Y_ZC', 'Gravity Y_MCL', 'Gravity Y_median', 'Gravity Y_sum', 
            'Gravity Z_min', 'Gravity Z_max', 'Gravity Z_mean', 'Gravity Z_ZC', 'Gravity Z_ME', 'Gravity Z_median', 'Gravity Z_Q1', 
            'Linear Acceleration X_min', 'Linear Acceleration X_max', 'Linear Acceleration X_var', 'Linear Acceleration X_skew', 'Linear Acceleration X_ZC', 'Linear Acceleration X_ME', 
            'Linear Acceleration X_MCL', 'Linear Acceleration X_median', 'Linear Acceleration X_Q1', 'Linear Acceleration X_Q3', 'Linear Acceleration Y_max', 'Linear Acceleration Y_mean', 
            'Linear Acceleration Y_skew', 'Linear Acceleration Y_ZC', 'Linear Acceleration Y_ME', 'Linear Acceleration Y_median', 'Linear Acceleration Y_Q1', 'Linear Acceleration Y_Q3', 
            'Linear Acceleration Y_sum', 'Linear Acceleration Z_min', 'Linear Acceleration Z_max', 'Linear Acceleration Z_mean', 'Linear Acceleration Z_var', 'Linear Acceleration Z_ZC', 
            'Linear Acceleration Z_ME', 'Linear Acceleration Z_MCL', 'Linear Acceleration Z_MTE', 'Linear Acceleration Z_Q3', 'Linear Acceleration Magnitude_var', 'Linear Acceleration Magnitude_MCL', 
            'Linear Acceleration Magnitude_median', 'Linear Acceleration Magnitude_Q1', 'Linear Acceleration Magnitude_sum', 'Gyroscope X_min', 'Gyroscope X_std', 'Gyroscope X_kurt', 
            'Gyroscope X_ZC', 'Gyroscope X_ME', 'Gyroscope X_MTE', 'Gyroscope Y_max', 'Gyroscope Y_skew', 'Gyroscope Y_ZC', 'Gyroscope Y_MCL', 'Gyroscope Y_MTE', 'Gyroscope Y_sum', 
            'Gyroscope Z_mean', 'Gyroscope Z_MCL', 'Gyroscope Z_MTE', 'Gyroscope Z_Q1', 'Gyroscope Z_sum', 'Gyroscope Magnitude_min', 'Gyroscope Magnitude_max', 'Gyroscope Magnitude_skew', 
            'Gyroscope Magnitude_ME', 'Gyroscope Magnitude_MCL', 'Gyroscope Magnitude_median', 'Gyroscope Magnitude_Q3', 'Gender_Male'
        ]
        
        # Réorganiser les colonnes selon l'ordre spécifié
        df_result = df_result[final_column_order]

        return df_result

    except Exception as e:
        raise ValueError(f"Erreur traitement {filepath}: {str(e)}")


@app.route('/predict', methods=['POST'])
def predict():
    if 'files' not in request.files:
        return jsonify({"error": "Aucun fichier reçu"}), 400

    predictions = []
    results = []

    for file in request.files.getlist('files'):
        if not file.filename.endswith('.csv'):
            continue

        try:
            filename = secure_filename(f"temp_{datetime.now().timestamp()}_{file.filename}")
            filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            file.save(filepath)

            features_df = process_file(filepath)
            prediction = knn_model.predict(features_df)[0]
            predictions.append(int(prediction))

            results.append({
                "file": file.filename,
                "prediction": int(prediction),
                "status": "success",
                "rows_processed": 300
            })

        except Exception as e:
            results.append({
                "file": file.filename,
                "error": str(e),
                "status": "failed"
            })
        finally:
            if os.path.exists(filepath):
                os.remove(filepath)

    # Calcul de la prédiction finale par majorité
    final_prediction = 1  # Valeur par défaut
    if predictions:
        counter = Counter(predictions)
        most_common = counter.most_common()
        if len(most_common) == 1:
            final_prediction = most_common[0][0]
        elif len(most_common) > 1:
            # Si égalité entre les deux classes
            if most_common[0][1] != most_common[1][1]:
                final_prediction = most_common[0][0]
            # sinon on garde 1 par défaut

    return jsonify({
        "results": results,
        "final_prediction": final_prediction
    })


@app.route('/final_prediction', methods=['POST'])
def final_prediction():

    if 'image' not in request.files or 'audio' not in request.files:
        return jsonify({"error": "Both image and audio files are required"}), 400

    try:


        # ---- Image prediction ----#
        image_file = request.files['image']
        image = Image.open(image_file.stream).convert("RGB")
        image_np = np.array(image)

        results = face_mesh.process(image_np)
        if not results.multi_face_landmarks:
            return jsonify({"error": "No face detected in image"}), 400

        face_landmarks = results.multi_face_landmarks[0]
        landmarks = []
        for landmark in face_landmarks.landmark:
            landmarks.extend([landmark.x, landmark.y])

        landmarks = np.array(landmarks).reshape(1, -1)
        landmarks_scaled = image_scaler.transform(landmarks)
        image_preds = image_model.predict(landmarks_scaled)[0]
        image_pred_label_idx = np.argmax(image_preds)
        image_emotion = image_label_encoder.inverse_transform([image_pred_label_idx])[0]

        # ---- Audio
        audio_file = request.files['audio']
        audio_bytes = audio_file.read()

        #check if the audio not wav format

        if not audio_file.filename.lower().endswith('.wav'):
          audio_segment = AudioSegment.from_file(BytesIO(audio_bytes))
          wav_io = BytesIO()
          audio_segment.export(wav_io, format="wav")
          wav_io.seek(0)
          audio_np, sr = librosa.load(wav_io, duration=2.5, offset=0.6)
        else:
          audio_np, sr = librosa.load(audio_bytes, duration=2.5, offset=0.6)

        # Convert to mono if needed
        if audio_np.ndim > 1:
            audio_np = np.mean(audio_np, axis=1)

        features = get_feature_from_array(audio_np, sr)
        f = features.reshape(1, -1)
        features_scaled = audio_scaler.transform(f)
        pred_proba = audio_model.predict(features_scaled)
        audio_index = np.argmax(pred_proba)
        audio_emotion = audio_labels[audio_index]
        audio_labels = audio_encoder.categories_[0]


        # ----- Fusion -----
        if audio_emotion == 'neutral' and image_emotion == 'surprised':
            fused_emotion = 'surprised'
        elif audio_emotion == 'fear':
            fused_emotion = 'fear'
        else:
            shared_labels = ['angry', 'happy', 'sad']
            fusion_scores = {}

            for label in shared_labels:
                image_score = (
                    image_preds[image_label_encoder.transform([label])[0]]
                    if label in image_label_encoder.classes_ else 0
                )
                audio_score = (
                    pred_proba[0][list(audio_labels).index(label)]
                    if label in audio_labels else 0
                )
                fusion_scores[label] = (image_model_accuracy * image_score +
                                       audio_model_accuracy * audio_score)/(image_model_accuracy + audio_model_accuracy)

            fused_emotion = max(fusion_scores, key=fusion_scores.get)

        return jsonify({
            "image_emotion": image_emotion,
            "audio_emotion": audio_emotion,
            "fused_emotion": fused_emotion
        })

    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500   


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)