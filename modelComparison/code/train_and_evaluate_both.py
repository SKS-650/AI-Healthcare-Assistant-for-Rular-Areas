"""Train and evaluate both Random Forest and XGBoost models with comprehensive metrics."""

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import json
import numpy as np
import pandas as pd
import time
from pathlib import Path
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    roc_auc_score, confusion_matrix, classification_report
)
from sklearn.ensemble import RandomForestClassifier
import xgboost as xgb
import joblib


def load_dataset(dataset_path: str):
    """Load and prepare the dataset."""
    print(f"Loading dataset from {dataset_path}...")
    df = pd.read_csv(dataset_path)
    
    print(f"Dataset shape: {df.shape}")
    
    # Separate features and target
    X = df.iloc[:, 1:].values  # All symptom columns
    y = df.iloc[:, 0].values   # Disease column
    
    # Encode target labels
    label_encoder = LabelEncoder()
    y_encoded = label_encoder.fit_transform(y)
    
    print(f"Features shape: {X.shape}")
    print(f"Number of unique diseases: {len(label_encoder.classes_)}")
    
    return X, y_encoded, label_encoder, df.columns[1:].tolist()


def load_best_hyperparameters(filepath: str = "best_hyperparameters.json"):
    """Load best hyperparameters from optimization."""
    with open(filepath, 'r') as f:
        optimization_results = json.load(f)
    
    rf_params = optimization_results['random_forest']['best_params']
    xgb_params = optimization_results['xgboost']['best_params']
    
    return rf_params, xgb_params


def train_random_forest(X_train, y_train, hyperparams):
    """Train Random Forest model with best hyperparameters."""
    print("\n" + "="*70)
    print("TRAINING RANDOM FOREST MODEL")
    print("="*70)
    print(f"Hyperparameters: {hyperparams}")
    
    start_time = time.time()
    
    model = RandomForestClassifier(
        n_estimators=hyperparams['n_estimators'],
        max_depth=hyperparams['max_depth'],
        min_samples_split=hyperparams['min_samples_split'],
        random_state=42,
        n_jobs=-1,
        class_weight='balanced',
        verbose=0
    )
    
    model.fit(X_train, y_train)
    
    training_time = time.time() - start_time
    
    print(f"Training completed in {training_time:.2f} seconds")
    
    return model, training_time


def train_xgboost(X_train, y_train, hyperparams):
    """Train XGBoost model with best hyperparameters."""
    print("\n" + "="*70)
    print("TRAINING XGBOOST MODEL")
    print("="*70)
    print(f"Hyperparameters: {hyperparams}")
    
    start_time = time.time()
    
    model = xgb.XGBClassifier(
        n_estimators=hyperparams['n_estimators'],
        max_depth=hyperparams['max_depth'],
        learning_rate=hyperparams['learning_rate'],
        random_state=42,
        n_jobs=-1,
        objective='multi:softprob',
        eval_metric='mlogloss',
        verbosity=0,
        use_label_encoder=False
    )
    
    model.fit(X_train, y_train)
    
    training_time = time.time() - start_time
    
    print(f"Training completed in {training_time:.2f} seconds")
    
    return model, training_time


def evaluate_model(model, X_test, y_test, model_name):
    """Evaluate model and collect all metrics."""
    print(f"\nEvaluating {model_name}...")
    
    # Prediction time
    start_time = time.time()
    y_pred = model.predict(X_test)
    prediction_time = time.time() - start_time
    inference_time_per_sample = (prediction_time / len(X_test)) * 1000  # milliseconds
    
    # Probabilities for ROC-AUC
    y_pred_proba = model.predict_proba(X_test)
    
    # Calculate metrics
    accuracy = accuracy_score(y_test, y_pred)
    precision = precision_score(y_test, y_pred, average='weighted', zero_division=0)
    recall = recall_score(y_test, y_pred, average='weighted', zero_division=0)
    f1 = f1_score(y_test, y_pred, average='weighted', zero_division=0)
    
    # ROC-AUC (macro-averaged for multiclass)
    try:
        roc_auc = roc_auc_score(y_test, y_pred_proba, multi_class='ovr', average='macro')
    except Exception as e:
        print(f"Warning: Could not calculate ROC-AUC: {e}")
        roc_auc = None
    
    # Confusion matrix
    cm = confusion_matrix(y_test, y_pred)
    
    print(f"\n{model_name} Performance Metrics:")
    print(f"  Accuracy:  {accuracy:.4f}")
    print(f"  Precision: {precision:.4f}")
    print(f"  Recall:    {recall:.4f}")
    print(f"  F1-Score:  {f1:.4f}")
    if roc_auc:
        print(f"  ROC-AUC:   {roc_auc:.4f}")
    print(f"  Inference time per sample: {inference_time_per_sample:.4f} ms")
    
    return {
        'accuracy': float(accuracy),
        'precision': float(precision),
        'recall': float(recall),
        'f1_score': float(f1),
        'roc_auc': float(roc_auc) if roc_auc else None,
        'confusion_matrix': cm.tolist(),
        'inference_time_ms_per_sample': float(inference_time_per_sample),
        'total_prediction_time_seconds': float(prediction_time)
    }


def cross_validate_model(model, X, y, model_name, cv=5):
    """Perform cross-validation."""
    print(f"\nPerforming 5-fold cross-validation for {model_name}...")
    
    start_time = time.time()
    cv_scores = cross_val_score(model, X, y, cv=cv, n_jobs=-1, scoring='accuracy')
    cv_time = time.time() - start_time
    
    print(f"CV Scores: {cv_scores}")
    print(f"Mean CV Score: {cv_scores.mean():.4f} (+/- {cv_scores.std():.4f})")
    print(f"Cross-validation completed in {cv_time:.2f} seconds")
    
    return {
        'cv_scores': cv_scores.tolist(),
        'mean_cv_score': float(cv_scores.mean()),
        'std_cv_score': float(cv_scores.std()),
        'cv_time_seconds': float(cv_time)
    }


def get_model_size(model, model_name):
    """Calculate model size in MB."""
    temp_file = f"temp_{model_name}.pkl"
    joblib.dump(model, temp_file)
    size_mb = os.path.getsize(temp_file) / (1024 * 1024)
    os.remove(temp_file)
    return float(size_mb)


def save_models(rf_model, xgb_model):
    """Save trained models."""
    models_dir = Path('trained_models')
    models_dir.mkdir(exist_ok=True)
    
    rf_path = models_dir / 'random_forest_optimized.pkl'
    xgb_path = models_dir / 'xgboost_optimized.pkl'
    
    joblib.dump(rf_model, rf_path)
    joblib.dump(xgb_model, xgb_path)
    
    print(f"\nModels saved:")
    print(f"  Random Forest: {rf_path}")
    print(f"  XGBoost: {xgb_path}")
    
    return str(rf_path), str(xgb_path)


def main():
    """Main training and evaluation pipeline."""
    print("="*70)
    print("MODEL TRAINING AND EVALUATION PIPELINE")
    print("="*70)
    
    # Load dataset
    dataset_path = "../../datasets/symptoms_datasets/Diseases_and_Symptoms_dataset.csv"
    X, y, label_encoder, feature_names = load_dataset(dataset_path)
    
    # Split data (80-20 split with stratification)
    X_train, X_test, y_train, y_test = train_test_split(
        X, y,
        test_size=0.2,
        random_state=42,
        stratify=y
    )
    
    print(f"\nData split:")
    print(f"  Training samples: {X_train.shape[0]}")
    print(f"  Testing samples:  {X_test.shape[0]}")
    
    # Load best hyperparameters
    rf_params, xgb_params = load_best_hyperparameters()
    
    # Train Random Forest
    rf_model, rf_training_time = train_random_forest(X_train, y_train, rf_params)
    rf_size_mb = get_model_size(rf_model, 'random_forest')
    print(f"Random Forest model size: {rf_size_mb:.2f} MB")
    
    # Train XGBoost
    xgb_model, xgb_training_time = train_xgboost(X_train, y_train, xgb_params)
    xgb_size_mb = get_model_size(xgb_model, 'xgboost')
    print(f"XGBoost model size: {xgb_size_mb:.2f} MB")
    
    # Evaluate on test set
    print("\n" + "="*70)
    print("TEST SET EVALUATION")
    print("="*70)
    
    rf_metrics = evaluate_model(rf_model, X_test, y_test, "Random Forest")
    xgb_metrics = evaluate_model(xgb_model, X_test, y_test, "XGBoost")
    
    # Cross-validation on full dataset (using smaller subset for speed)
    print("\n" + "="*70)
    print("CROSS-VALIDATION")
    print("="*70)
    print("Note: Using 20% subset for faster cross-validation")
    
    # Use subset for faster CV
    subset_size = int(0.2 * X.shape[0])
    indices = np.random.choice(X.shape[0], subset_size, replace=False)
    X_cv = X[indices]
    y_cv = y[indices]
    
    rf_cv_results = cross_validate_model(rf_model, X_cv, y_cv, "Random Forest", cv=5)
    xgb_cv_results = cross_validate_model(xgb_model, X_cv, y_cv, "XGBoost", cv=5)
    
    # Compile all results
    results = {
        'dataset_info': {
            'total_samples': int(X.shape[0]),
            'n_features': int(X.shape[1]),
            'n_classes': int(len(label_encoder.classes_)),
            'train_samples': int(X_train.shape[0]),
            'test_samples': int(X_test.shape[0]),
            'class_names': label_encoder.classes_.tolist(),
            'feature_names': feature_names
        },
        'random_forest': {
            'hyperparameters': rf_params,
            'training_time_seconds': float(rf_training_time),
            'model_size_mb': float(rf_size_mb),
            'test_metrics': rf_metrics,
            'cross_validation': rf_cv_results
        },
        'xgboost': {
            'hyperparameters': xgb_params,
            'training_time_seconds': float(xgb_training_time),
            'model_size_mb': float(xgb_size_mb),
            'test_metrics': xgb_metrics,
            'cross_validation': xgb_cv_results
        }
    }
    
    # Save results
    output_path = Path('performance_metrics.json')
    with open(output_path, 'w') as f:
        json.dump(results, f, indent=2)
    
    print("\n" + "="*70)
    print("RESULTS SUMMARY")
    print("="*70)
    
    print("\nRandom Forest:")
    print(f"  Test Accuracy:  {rf_metrics['accuracy']:.4f}")
    print(f"  CV Accuracy:    {rf_cv_results['mean_cv_score']:.4f} (+/- {rf_cv_results['std_cv_score']:.4f})")
    print(f"  Training Time:  {rf_training_time:.2f}s")
    print(f"  Model Size:     {rf_size_mb:.2f} MB")
    
    print("\nXGBoost:")
    print(f"  Test Accuracy:  {xgb_metrics['accuracy']:.4f}")
    print(f"  CV Accuracy:    {xgb_cv_results['mean_cv_score']:.4f} (+/- {xgb_cv_results['std_cv_score']:.4f})")
    print(f"  Training Time:  {xgb_training_time:.2f}s")
    print(f"  Model Size:     {xgb_size_mb:.2f} MB")
    
    print(f"\nResults saved to: {output_path.absolute()}")
    
    # Save trained models
    save_models(rf_model, xgb_model)
    
    print("\n" + "="*70)
    print("TRAINING AND EVALUATION COMPLETE")
    print("="*70)
    
    return results


if __name__ == "__main__":
    main()
