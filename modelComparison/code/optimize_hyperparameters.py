"""Hyperparameter optimization for Random Forest and XGBoost models."""

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import json
import numpy as np
import pandas as pd
from sklearn.model_selection import GridSearchCV, train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.ensemble import RandomForestClassifier
import xgboost as xgb
import time
from pathlib import Path


def load_and_prepare_data(dataset_path: str):
    """Load and prepare the dataset."""
    print(f"Loading dataset from {dataset_path}...")
    df = pd.read_csv(dataset_path)
    
    print(f"Dataset shape: {df.shape}")
    print(f"Columns: {df.columns.tolist()[:5]}...")
    
    # Separate features and target
    X = df.iloc[:, 1:].values  # All symptom columns
    y = df.iloc[:, 0].values   # Disease column
    
    # Encode target labels
    label_encoder = LabelEncoder()
    y_encoded = label_encoder.fit_transform(y)
    
    print(f"Number of unique diseases: {len(label_encoder.classes_)}")
    print(f"Sample distribution - X shape: {X.shape}, y shape: {y_encoded.shape}")
    
    return X, y_encoded, label_encoder


def optimize_random_forest(X_train, y_train):
    """Optimize Random Forest hyperparameters."""
    print("\n" + "="*60)
    print("OPTIMIZING RANDOM FOREST HYPERPARAMETERS")
    print("="*60)
    
    param_grid = {
        'n_estimators': [100, 200, 300],
        'max_depth': [20, 30, 40],
        'min_samples_split': [2, 5, 10]
    }
    
    print(f"Parameter grid: {param_grid}")
    print(f"Total combinations: {len(param_grid['n_estimators']) * len(param_grid['max_depth']) * len(param_grid['min_samples_split'])}")
    
    # Create base model
    base_model = RandomForestClassifier(
        n_estimators=100,
        max_depth=20,
        random_state=42,
        n_jobs=-1,
        class_weight='balanced'
    )
    
    # Grid search with 5-fold cross-validation
    grid_search = GridSearchCV(
        base_model,
        param_grid,
        cv=5,
        scoring='accuracy',
        n_jobs=-1,
        verbose=2,
        return_train_score=True
    )
    
    start_time = time.time()
    grid_search.fit(X_train, y_train)
    elapsed_time = time.time() - start_time
    
    print(f"\nOptimization completed in {elapsed_time:.2f} seconds")
    print(f"Best parameters: {grid_search.best_params_}")
    print(f"Best CV score: {grid_search.best_score_:.4f}")
    
    # Extract detailed results
    results = {
        'best_params': grid_search.best_params_,
        'best_cv_score': float(grid_search.best_score_),
        'cv_results': {
            'mean_test_scores': grid_search.cv_results_['mean_test_score'].tolist(),
            'std_test_scores': grid_search.cv_results_['std_test_score'].tolist(),
            'params': [str(p) for p in grid_search.cv_results_['params']]
        },
        'optimization_time_seconds': elapsed_time
    }
    
    return results


def optimize_xgboost(X_train, y_train):
    """Optimize XGBoost hyperparameters."""
    print("\n" + "="*60)
    print("OPTIMIZING XGBOOST HYPERPARAMETERS")
    print("="*60)
    
    param_grid = {
        'n_estimators': [100, 200, 300],
        'max_depth': [6, 10, 15],
        'learning_rate': [0.01, 0.1, 0.3]
    }
    
    print(f"Parameter grid: {param_grid}")
    print(f"Total combinations: {len(param_grid['n_estimators']) * len(param_grid['max_depth']) * len(param_grid['learning_rate'])}")
    
    # Create base model
    base_model = xgb.XGBClassifier(
        n_estimators=100,
        max_depth=6,
        learning_rate=0.1,
        random_state=42,
        n_jobs=-1,
        objective='multi:softprob',
        eval_metric='mlogloss',
        verbosity=0,
        use_label_encoder=False
    )
    
    # Grid search with 5-fold cross-validation
    grid_search = GridSearchCV(
        base_model,
        param_grid,
        cv=5,
        scoring='accuracy',
        n_jobs=-1,
        verbose=2,
        return_train_score=True
    )
    
    start_time = time.time()
    grid_search.fit(X_train, y_train)
    elapsed_time = time.time() - start_time
    
    print(f"\nOptimization completed in {elapsed_time:.2f} seconds")
    print(f"Best parameters: {grid_search.best_params_}")
    print(f"Best CV score: {grid_search.best_score_:.4f}")
    
    # Extract detailed results
    results = {
        'best_params': grid_search.best_params_,
        'best_cv_score': float(grid_search.best_score_),
        'cv_results': {
            'mean_test_scores': grid_search.cv_results_['mean_test_score'].tolist(),
            'std_test_scores': grid_search.cv_results_['std_test_score'].tolist(),
            'params': [str(p) for p in grid_search.cv_results_['params']]
        },
        'optimization_time_seconds': elapsed_time
    }
    
    return results


def main():
    """Main optimization pipeline."""
    print("="*60)
    print("HYPERPARAMETER OPTIMIZATION PIPELINE")
    print("="*60)
    
    # Dataset path
    dataset_path = "../../datasets/symptoms_datasets/Diseases_and_Symptoms_dataset.csv"
    
    # Load and prepare data
    X, y, label_encoder = load_and_prepare_data(dataset_path)
    
    # Split data for optimization (using subset for faster optimization)
    # Use stratified split to maintain class distribution
    X_train, X_test, y_train, y_test = train_test_split(
        X, y,
        test_size=0.2,
        random_state=42,
        stratify=y
    )
    
    print(f"\nTrain set: {X_train.shape[0]} samples")
    print(f"Test set: {X_test.shape[0]} samples")
    
    # For faster optimization, use a subset
    # Using 10% of training data for hyperparameter search (still 15K+ samples)
    subset_size = int(0.10 * X_train.shape[0])
    print(f"\nUsing {subset_size} samples for hyperparameter optimization (faster execution)")
    
    np.random.seed(42)
    indices = np.random.choice(X_train.shape[0], subset_size, replace=False)
    X_train_subset = X_train[indices]
    y_train_subset = y_train[indices]
    
    # Optimize Random Forest
    rf_results = optimize_random_forest(X_train_subset, y_train_subset)
    
    # Optimize XGBoost
    xgb_results = optimize_xgboost(X_train_subset, y_train_subset)
    
    # Compile all results
    optimization_results = {
        'dataset_info': {
            'total_samples': int(X.shape[0]),
            'n_features': int(X.shape[1]),
            'n_classes': int(len(np.unique(y))),
            'train_samples': int(X_train.shape[0]),
            'test_samples': int(X_test.shape[0]),
            'optimization_subset_samples': int(X_train_subset.shape[0])
        },
        'random_forest': rf_results,
        'xgboost': xgb_results,
        'optimization_strategy': {
            'method': 'GridSearchCV',
            'cv_folds': 5,
            'scoring_metric': 'accuracy',
            'subset_used': True,
            'subset_ratio': 0.10
        }
    }
    
    # Save results
    output_path = Path('best_hyperparameters.json')
    with open(output_path, 'w') as f:
        json.dump(optimization_results, f, indent=2)
    
    print("\n" + "="*60)
    print("OPTIMIZATION COMPLETE")
    print("="*60)
    print(f"\nResults saved to: {output_path.absolute()}")
    print("\nBest Parameters:")
    print(f"Random Forest: {rf_results['best_params']} (CV Score: {rf_results['best_cv_score']:.4f})")
    print(f"XGBoost: {xgb_results['best_params']} (CV Score: {xgb_results['best_cv_score']:.4f})")
    
    return optimization_results


if __name__ == "__main__":
    main()
