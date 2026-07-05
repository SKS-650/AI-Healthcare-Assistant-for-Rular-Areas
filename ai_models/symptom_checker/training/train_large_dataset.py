"""Enhanced training script for large symptom dataset with 96K+ samples."""

import pandas as pd
import numpy as np
from pathlib import Path
import joblib
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
import sys
from datetime import datetime

# Add parent directory to path
sys.path.append(str(Path(__file__).parent.parent.parent))

from symptom_checker.models.random_forest import RandomForestSymptomChecker
from symptom_checker.config.config import config
from symptom_checker.config.paths import Paths


def load_large_dataset():
    """Load the large Diseases_and_Symptoms_dataset.csv"""
    print("="*70)
    print("Loading Large Dataset (96K+ samples, 230+ symptoms)")
    print("="*70)
    
    dataset_path = Path("D:/MinorProject/datasets/all_in_one/Diseases_and_Symptoms_dataset.csv")
    
    if not dataset_path.exists():
        print(f"Dataset not found at {dataset_path}")
        return None
    
    print(f"Loading from: {dataset_path}")
    df = pd.read_csv(dataset_path)
    
    print(f"\n✓ Dataset loaded successfully!")
    print(f"  Shape: {df.shape}")
    print(f"  Samples: {df.shape[0]:,}")
    print(f"  Features: {df.shape[1]:,}")
    
    return df


def preprocess_large_dataset(df):
    """Preprocess the large dataset."""
    print("\n" + "="*70)
    print("Preprocessing Data")
    print("="*70)
    
    # Separate target and features
    if 'diseases' in df.columns:
        y = df['diseases'].copy()
        X = df.drop(columns=['diseases'])
    else:
        print("Error: 'diseases' column not found!")
        return None, None
    
    # Check for missing values
    missing = X.isnull().sum().sum()
    if missing > 0:
        print(f"Filling {missing} missing values with 0")
        X = X.fillna(0)
    
    # Clean disease names
    y = y.str.strip().str.lower()
    
    # Remove any duplicate rows
    initial_count = len(X)
    combined = pd.concat([X, y], axis=1)
    combined = combined.drop_duplicates()
    X = combined.drop(columns=['diseases'])
    y = combined['diseases']
    removed = initial_count - len(X)
    
    if removed > 0:
        print(f"✓ Removed {removed} duplicate rows")
    
    print(f"\n✓ Preprocessing complete!")
    print(f"  Final shape: {X.shape}")
    print(f"  Number of diseases: {y.nunique()}")
    print(f"  Number of symptom features: {X.shape[1]}")
    
    # Show disease distribution
    disease_counts = y.value_counts()
    print(f"\n  Top 10 diseases:")
    for disease, count in disease_counts.head(10).items():
        print(f"    • {disease}: {count} samples")
    
    return X, y


def split_data(X, y):
    """Split data into train, validation, and test sets."""
    print("\n" + "="*70)
    print("Splitting Data")
    print("="*70)
    
    # First split: 70% train, 30% temp
    X_train, X_temp, y_train, y_temp = train_test_split(
        X, y,
        test_size=0.3,
        random_state=config.RANDOM_STATE,
        stratify=y
    )
    
    # Second split: 15% validation, 15% test
    X_val, X_test, y_val, y_test = train_test_split(
        X_temp, y_temp,
        test_size=0.5,
        random_state=config.RANDOM_STATE,
        stratify=y_temp
    )
    
    print(f"✓ Data split complete!")
    print(f"  Training set:   {X_train.shape[0]:,} samples ({X_train.shape[0]/len(X)*100:.1f}%)")
    print(f"  Validation set: {X_val.shape[0]:,} samples ({X_val.shape[0]/len(X)*100:.1f}%)")
    print(f"  Test set:       {X_test.shape[0]:,} samples ({X_test.shape[0]/len(X)*100:.1f}%)")
    
    return X_train, X_val, X_test, y_train, y_val, y_test


def train_model(X_train, y_train, X_val, y_val):
    """Train the Random Forest model."""
    print("\n" + "="*70)
    print("Training Random Forest Model")
    print("="*70)
    
    print(f"\nModel Configuration:")
    print(f"  Algorithm: Random Forest")
    print(f"  Number of trees: {config.N_ESTIMATORS}")
    print(f"  Max depth: {config.MAX_DEPTH}")
    print(f"  Min samples split: {config.MIN_SAMPLES_SPLIT}")
    print(f"  Class weight: balanced")
    
    # Initialize and train
    model = RandomForestSymptomChecker(
        n_estimators=config.N_ESTIMATORS,
        max_depth=config.MAX_DEPTH,
        min_samples_split=config.MIN_SAMPLES_SPLIT,
        min_samples_leaf=config.MIN_SAMPLES_LEAF,
        random_state=config.RANDOM_STATE,
        n_jobs=-1
    )
    
    print(f"\n⏳ Training started at {datetime.now().strftime('%H:%M:%S')}")
    print("   This may take 2-5 minutes...")
    
    # Convert to numpy arrays
    X_train_arr = X_train.values if isinstance(X_train, pd.DataFrame) else X_train
    y_train_arr = y_train.values if isinstance(y_train, pd.Series) else y_train
    X_val_arr = X_val.values if isinstance(X_val, pd.DataFrame) else X_val
    y_val_arr = y_val.values if isinstance(y_val, pd.Series) else y_val
    
    model.fit(X_train_arr, y_train_arr)
    
    print(f"✓ Training completed at {datetime.now().strftime('%H:%M:%S')}")
    
    # Evaluate on training set
    print("\n" + "-"*70)
    print("Training Set Performance")
    print("-"*70)
    train_metrics = model.evaluate(X_train_arr, y_train_arr)
    for metric, value in train_metrics.items():
        print(f"  {metric:.<20} {value:.4f} ({value*100:.2f}%)")
    
    # Evaluate on validation set
    print("\n" + "-"*70)
    print("Validation Set Performance")
    print("-"*70)
    val_metrics = model.evaluate(X_val_arr, y_val_arr)
    for metric, value in val_metrics.items():
        print(f"  {metric:.<20} {value:.4f} ({value*100:.2f}%)")
    
    return model


def evaluate_model(model, X_test, y_test):
    """Comprehensive evaluation on test set."""
    print("\n" + "="*70)
    print("Final Test Set Evaluation")
    print("="*70)
    
    # Convert to numpy
    X_test_arr = X_test.values if isinstance(X_test, pd.DataFrame) else X_test
    y_test_arr = y_test.values if isinstance(y_test, pd.Series) else y_test
    
    # Get predictions
    y_pred = model.predict(X_test_arr)
    
    # Calculate metrics
    metrics = model.evaluate(X_test_arr, y_test_arr)
    
    print("\nOverall Metrics:")
    print("-"*70)
    for metric, value in metrics.items():
        print(f"  {metric:.<20} {value:.4f} ({value*100:.2f}%)")
    
    # Top-K accuracy
    print("\n" + "-"*70)
    print("Top-K Accuracy (Does correct disease appear in top K predictions?)")
    print("-"*70)
    
    for k in [1, 3, 5]:
        top_k_preds = model.predict_top_k(X_test_arr, k=k)
        correct = 0
        for i, true_disease in enumerate(y_test_arr):
            predicted_diseases = [d for d, _ in top_k_preds[i]]
            if true_disease in predicted_diseases:
                correct += 1
        
        top_k_acc = correct / len(y_test_arr)
        print(f"  Top-{k} Accuracy: {top_k_acc:.4f} ({top_k_acc*100:.2f}%)")
    
    # Disease-wise performance
    print("\n" + "-"*70)
    print("Per-Disease Performance (Top 10 diseases)")
    print("-"*70)
    
    disease_counts = pd.Series(y_test_arr).value_counts()
    top_10_diseases = disease_counts.head(10).index
    
    for disease in top_10_diseases:
        mask = y_test_arr == disease
        if mask.sum() > 0:
            disease_acc = accuracy_score(y_test_arr[mask], y_pred[mask])
            print(f"  {disease[:40]:.<42} {disease_acc:.4f} ({disease_acc*100:.1f}%)")
    
    return metrics


def save_model_and_artifacts(model, feature_names, X_train, y_train):
    """Save model and all artifacts."""
    print("\n" + "="*70)
    print("Saving Model and Artifacts")
    print("="*70)
    
    # Save model
    model_path = Paths.get_model_path(config.MODEL_NAME)
    model.save(str(model_path))
    print(f"✓ Model saved to: {model_path}")
    
    # Save feature names
    feature_names_path = Paths.FEATURE_NAMES / "feature_names.pkl"
    joblib.dump(feature_names, feature_names_path)
    print(f"✓ Feature names saved to: {feature_names_path}")
    
    # Save symptom vocabulary (for symptom vectorizer compatibility)
    symptom_vocab_path = Paths.get_encoder_path("symptom_vocabulary")
    joblib.dump(list(feature_names), symptom_vocab_path)
    print(f"✓ Symptom vocabulary saved to: {symptom_vocab_path}")
    
    # Save training metadata
    metadata = {
        'training_date': datetime.now().isoformat(),
        'n_samples': len(X_train),
        'n_features': len(feature_names),
        'n_diseases': len(model.classes_),
        'model_version': config.MODEL_VERSION,
        'diseases': list(model.classes_)
    }
    
    metadata_path = Paths.ARTIFACTS / "training_metadata.pkl"
    joblib.dump(metadata, metadata_path)
    print(f"✓ Training metadata saved to: {metadata_path}")
    
    print(f"\n✅ All artifacts saved successfully!")


def main():
    """Main training pipeline."""
    print("\n" + "="*70)
    print("ENHANCED SYMPTOM CHECKER TRAINING")
    print("Large Dataset with 96K+ Samples and 230+ Symptoms")
    print("="*70)
    print(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Ensure directories exist
    Paths.ensure_directories()
    
    # Step 1: Load data
    df = load_large_dataset()
    if df is None:
        return
    
    # Step 2: Preprocess
    X, y = preprocess_large_dataset(df)
    if X is None:
        return
    
    # Step 3: Split data
    X_train, X_val, X_test, y_train, y_val, y_test = split_data(X, y)
    
    # Step 4: Train model
    model = train_model(X_train, y_train, X_val, y_val)
    
    # Step 5: Evaluate on test set
    final_metrics = evaluate_model(model, X_test, y_test)
    
    # Step 6: Save everything
    save_model_and_artifacts(model, X.columns.tolist(), X_train, y_train)
    
    # Final summary
    print("\n" + "="*70)
    print("🎉 TRAINING COMPLETE!")
    print("="*70)
    print(f"Completed at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"\n📊 Final Results:")
    print(f"  ✓ Trained on: {len(X_train):,} samples")
    print(f"  ✓ Features: {X.shape[1]:,} symptoms")
    print(f"  ✓ Diseases: {len(model.classes_):,} categories")
    print(f"  ✓ Test Accuracy: {final_metrics['accuracy']*100:.2f}%")
    print(f"  ✓ Model saved and ready to use!")
    
    print("\n🚀 Next Steps:")
    print("  1. Test the model: python test_simple.py")
    print("  2. Start the API: python -m uvicorn backend.app.main:app --reload")
    print("  3. Test predictions via API: http://localhost:8000/docs")
    print("="*70)


if __name__ == "__main__":
    main()
