"""
DEPRECATED — do NOT run this script.

This legacy training script builds a 15-feature model (4 symptoms + 11
engineered patient features) that is INCOMPATIBLE with the production model
which expects 230 features.

Run train_large_dataset.py instead:
    python ai_models/symptom_checker/training/train_large_dataset.py

That script trains on the 96K-sample Diseases_and_Symptoms_dataset.csv and
produces the correct 230-feature Random Forest used by the API.
"""
import sys

print("=" * 70)
print("ERROR: This script is deprecated and disabled.")
print()
print("It produces a 15-feature model that conflicts with the 230-feature")
print("production model trained by train_large_dataset.py.")
print()
print("To retrain the model run:")
print("  python ai_models/symptom_checker/training/train_large_dataset.py")
print("=" * 70)
sys.exit(1)


# ──────────────────────────────────────────────────────────────────────────────
# ORIGINAL CODE KEPT BELOW FOR REFERENCE ONLY — NEVER EXECUTED
# ──────────────────────────────────────────────────────────────────────────────
if False:

# Add parent directory to path
sys.path.append(str(Path(__file__).parent.parent.parent))

from symptom_checker.models.random_forest import RandomForestSymptomChecker
from symptom_checker.preprocessing.data_cleaning import DataCleaner
from symptom_checker.preprocessing.symptom_normalization import SymptomNormalizer
from symptom_checker.preprocessing.categorical_encoding import CategoricalEncoder
from symptom_checker.feature_engineering.feature_creation import FeatureEngineer
from symptom_checker.feature_engineering.symptom_vectorizer import SymptomVectorizer
from symptom_checker.config.config import config
from symptom_checker.config.paths import Paths


def load_and_prepare_data():
    """Load datasets and prepare for training."""
    print("="*60)
    print("Loading datasets...")
    print("="*60)
    
    # Try to load from multiple possible locations
    dataset_paths = [
        Path("D:/MinorProject/datasets/all_in_one"),
        Paths.ROOT / "datasets",
        Paths.EXTERNAL_DATA
    ]
    
    df = None
    for dataset_path in dataset_paths:
        disease_symptom_file = dataset_path / "Disease_symptom_and_patient_profile_dataset.csv"
        if disease_symptom_file.exists():
            print(f"Found dataset at: {disease_symptom_file}")
            df = pd.read_csv(disease_symptom_file)
            break
    
    if df is None:
        # Create synthetic dataset for demonstration
        print("Creating synthetic dataset for demonstration...")
        df = create_synthetic_dataset()
    
    print(f"Dataset shape: {df.shape}")
    print(f"Columns: {df.columns.tolist()}")
    
    return df


def create_synthetic_dataset(n_samples=1000):
    """Create synthetic dataset for demonstration."""
    print("Generating synthetic training data...")
    
    # Common symptoms
    all_symptoms = [
        'fever', 'cough', 'headache', 'fatigue', 'nausea',
        'vomiting', 'diarrhea', 'abdominal pain', 'chest pain',
        'shortness of breath', 'dizziness', 'joint pain',
        'back pain', 'sore throat', 'runny nose', 'loss of taste',
        'loss of smell', 'skin rash', 'muscle pain', 'chills'
    ]
    
    # Diseases with typical symptom patterns
    disease_patterns = {
        'Common Cold': ['cough', 'runny nose', 'sore throat', 'fatigue'],
        'Flu': ['fever', 'cough', 'headache', 'muscle pain', 'chills', 'fatigue'],
        'COVID-19': ['fever', 'cough', 'loss of taste', 'loss of smell', 'fatigue'],
        'Gastroenteritis': ['nausea', 'vomiting', 'diarrhea', 'abdominal pain'],
        'Migraine': ['headache', 'nausea', 'dizziness'],
        'Pneumonia': ['fever', 'cough', 'chest pain', 'shortness of breath', 'fatigue'],
        'Arthritis': ['joint pain', 'muscle pain', 'fatigue'],
        'Food Poisoning': ['nausea', 'vomiting', 'diarrhea', 'abdominal pain', 'fever']
    }
    
    data = []
    for _ in range(n_samples):
        disease = np.random.choice(list(disease_patterns.keys()))
        typical_symptoms = disease_patterns[disease]
        
        # Add 2-4 typical symptoms plus 0-2 random symptoms
        n_typical = np.random.randint(2, len(typical_symptoms) + 1)
        n_random = np.random.randint(0, 3)
        
        symptoms = np.random.choice(typical_symptoms, n_typical, replace=False).tolist()
        random_symptoms = np.random.choice(
            [s for s in all_symptoms if s not in symptoms],
            min(n_random, len(all_symptoms) - len(symptoms)),
            replace=False
        ).tolist()
        symptoms.extend(random_symptoms)
        
        record = {
            'disease': disease,
            'symptoms': ','.join(symptoms),
            'age': np.random.randint(5, 80),
            'gender': np.random.choice(['male', 'female']),
            'severity': np.random.randint(1, 5),
            'duration': np.random.randint(1, 30)
        }
        data.append(record)
    
    return pd.DataFrame(data)


def preprocess_data(df):
    """Preprocess and clean the data."""
    print("\n" + "="*60)
    print("Preprocessing data...")
    print("="*60)
    
    # Initialize components
    cleaner = DataCleaner()
    normalizer = SymptomNormalizer()
    
    # Clean dataset
    df = cleaner.clean_dataset(df)
    
    # Identify symptom columns
    # Common symptom column names in medical datasets
    possible_symptom_cols = ['Fever', 'Cough', 'Fatigue', 'Difficulty Breathing', 
                             'Headache', 'Sore Throat', 'Nausea', 'Vomiting',
                             'Diarrhea', 'Muscle Pain', 'Loss of Taste', 'Loss of Smell']
    
    symptom_cols = [col for col in df.columns if col in possible_symptom_cols]
    
    print(f"Found symptom columns: {symptom_cols}")
    
    # Extract symptoms
    if 'symptoms' in df.columns and df['symptoms'].dtype == 'object':
        # Symptoms are in comma-separated format
        df['symptom_list'] = df['symptoms'].apply(
            lambda x: [s.strip() for s in str(x).split(',') if s.strip()]
        )
    elif symptom_cols:
        # Symptoms are in separate columns (like our dataset)
        # Convert Yes/No or 1/0 to symptom names
        def extract_symptoms(row):
            symptoms = []
            for col in symptom_cols:
                val = row[col]
                # Check if symptom is present (handle Yes/No, True/False, 1/0)
                if val in ['Yes', 'yes', True, 1, 1.0] or (isinstance(val, str) and val.lower() == 'yes'):
                    symptoms.append(col)
            return symptoms
        
        df['symptom_list'] = df.apply(extract_symptoms, axis=1)
    else:
        # No symptoms found, create empty list
        print("Warning: No symptom columns found!")
        df['symptom_list'] = [[] for _ in range(len(df))]
    
    # Remove rows with no symptoms
    initial_count = len(df)
    df = df[df['symptom_list'].apply(len) > 0]
    removed = initial_count - len(df)
    if removed > 0:
        print(f"Removed {removed} rows with no symptoms")
    
    # Normalize symptoms
    df['symptom_list'] = df['symptom_list'].apply(normalizer.normalize_list)
    
    # Handle disease column (try different common names)
    disease_col = None
    for col_name in ['Disease', 'disease', 'Diagnosis', 'diagnosis', 'Condition', 'condition']:
        if col_name in df.columns:
            disease_col = col_name
            break
    
    if disease_col:
        df['disease'] = df[disease_col]
    else:
        print("Warning: No disease column found!")
        df['disease'] = 'Unknown'
    
    # Handle age column
    age_col = None
    for col_name in ['Age', 'age', 'Patient Age']:
        if col_name in df.columns:
            age_col = col_name
            break
    
    if age_col:
        df['age'] = df[age_col]
    else:
        df['age'] = 30
    
    # Handle gender column
    gender_col = None
    for col_name in ['Gender', 'gender', 'Sex', 'sex']:
        if col_name in df.columns:
            gender_col = col_name
            break
    
    if gender_col:
        df['gender'] = df[gender_col].str.lower()
    else:
        df['gender'] = 'male'
    
    # Add missing columns with defaults
    if 'severity' not in df.columns:
        df['severity'] = 2
    if 'duration' not in df.columns:
        df['duration'] = 7
    if 'weight' not in df.columns:
        df['weight'] = 70
    if 'height' not in df.columns:
        df['height'] = 170
    
    print(f"Preprocessed dataset shape: {df.shape}")
    print(f"Number of unique diseases: {df['disease'].nunique()}")
    print(f"Sample symptom lists: {df['symptom_list'].head(3).tolist()}")
    
    return df


def engineer_features(df):
    """Create engineered features."""
    print("\n" + "="*60)
    print("Engineering features...")
    print("="*60)
    
    engineer = FeatureEngineer()
    
    # Add basic patient features if not present
    if 'weight' not in df.columns:
        df['weight'] = np.random.normal(70, 15, len(df))
    if 'height' not in df.columns:
        df['height'] = np.random.normal(170, 10, len(df))
    
    # Calculate symptom count from symptom_list
    if 'symptom_list' in df.columns:
        df['symptom_count'] = df['symptom_list'].apply(len)
    else:
        df['symptom_count'] = 0
    
    # Create all engineered features (excluding symptom-based features)
    df = engineer.create_all_features(df)
    
    print(f"Features after engineering: {df.shape[1]} columns")
    
    return df


def create_feature_vectors(df):
    """Convert symptoms to feature vectors."""
    print("\n" + "="*60)
    print("Creating feature vectors...")
    print("="*60)
    
    # Initialize symptom vectorizer
    vectorizer = SymptomVectorizer(method='multi_hot')
    
    # Fit and transform symptoms
    symptom_lists = df['symptom_list'].tolist()
    symptom_vectors = vectorizer.fit_transform(symptom_lists)
    
    print(f"Symptom vocabulary size: {vectorizer.vocabulary_size}")
    print(f"Symptom vector shape: {symptom_vectors.shape}")
    
    # Create symptom dataframe
    symptom_feature_names = [f"symptom_{name}" for name in vectorizer.get_feature_names()]
    symptom_df = pd.DataFrame(symptom_vectors, columns=symptom_feature_names, index=df.index)
    
    # Patient features
    patient_feature_cols = [
        'age', 'gender', 'severity', 'duration',
        'symptom_count', 'severity_score'
    ]
    patient_feature_cols = [col for col in patient_feature_cols if col in df.columns]
    
    # Encode categorical features
    encoder = CategoricalEncoder()
    df_encoded = encoder.fit_transform(df[patient_feature_cols], ['gender'])
    
    # Combine features
    X = pd.concat([symptom_df, df_encoded], axis=1)
    y = df['disease']
    
    print(f"Final feature matrix shape: {X.shape}")
    print(f"Number of classes: {y.nunique()}")
    
    # Save artifacts
    vectorizer.save(str(Paths.get_encoder_path("symptom_vectorizer")))
    encoder.save(str(Paths.get_encoder_path("categorical_encoder")))
    joblib.dump(X.columns.tolist(), Paths.FEATURE_NAMES / "feature_names.pkl")
    
    return X.values, y.values, X.columns.tolist()


def train_model(X_train, y_train, X_val, y_val):
    """Train the Random Forest model."""
    print("\n" + "="*60)
    print("Training model...")
    print("="*60)
    
    # Initialize model
    model = RandomForestSymptomChecker()
    
    # Train
    model.fit(X_train, y_train)
    
    # Evaluate on training set
    train_metrics = model.evaluate(X_train, y_train)
    print("\nTraining Metrics:")
    for metric, value in train_metrics.items():
        print(f"  {metric}: {value:.4f}")
    
    # Evaluate on validation set
    val_metrics = model.evaluate(X_val, y_val)
    print("\nValidation Metrics:")
    for metric, value in val_metrics.items():
        print(f"  {metric}: {value:.4f}")
    
    return model


def save_model(model):
    """Save trained model."""
    print("\n" + "="*60)
    print("Saving model...")
    print("="*60)
    
    model_path = Paths.get_model_path(config.MODEL_NAME)
    model.save(str(model_path))
    
    print(f"Model saved to: {model_path}")


def main():
    """Main training pipeline."""
    print("\n" + "="*60)
    print("SYMPTOM CHECKER MODEL TRAINING PIPELINE")
    print("="*60)
    
    # Ensure directories exist
    Paths.ensure_directories()
    
    # Step 1: Load data
    df = load_and_prepare_data()
    
    # Step 2: Preprocess
    df = preprocess_data(df)
    
    # Step 3: Engineer features
    df = engineer_features(df)
    
    # Step 4: Create feature vectors
    X, y, feature_names = create_feature_vectors(df)
    
    # Step 5: Train-test split
    print("\n" + "="*60)
    print("Splitting data...")
    print("="*60)
    
    # Check class distribution
    disease_counts = pd.Series(y).value_counts()
    print(f"Number of diseases: {len(disease_counts)}")
    print(f"Diseases with < 2 samples: {(disease_counts < 2).sum()}")
    print(f"Diseases with >= 2 samples: {(disease_counts >= 2).sum()}")
    
    # Group rare diseases (those with < 3 samples) into "Other"
    rare_diseases = disease_counts[disease_counts < 3].index.tolist()
    if len(rare_diseases) > 0:
        print(f"\nGrouping {len(rare_diseases)} rare diseases into 'Other' category")
        y_grouped = []
        for disease in y:
            if disease in rare_diseases:
                y_grouped.append('Other')
            else:
                y_grouped.append(disease)
        y = np.array(y_grouped)
        
        # Update disease counts
        disease_counts = pd.Series(y).value_counts()
        print(f"After grouping - Number of diseases: {len(disease_counts)}")
    
    # Try stratified split if possible, otherwise regular split
    try:
        X_train, X_temp, y_train, y_temp = train_test_split(
            X, y, test_size=0.3, random_state=config.RANDOM_STATE, stratify=y
        )
        X_val, X_test, y_val, y_test = train_test_split(
            X_temp, y_temp, test_size=0.5, random_state=config.RANDOM_STATE, stratify=y_temp
        )
        print("Using stratified split")
    except ValueError as e:
        print(f"Cannot use stratified split: {e}")
        print("Using random split instead")
        X_train, X_temp, y_train, y_temp = train_test_split(
            X, y, test_size=0.3, random_state=config.RANDOM_STATE
        )
        X_val, X_test, y_val, y_test = train_test_split(
            X_temp, y_temp, test_size=0.5, random_state=config.RANDOM_STATE
        )
    
    print(f"Training set: {X_train.shape}")
    print(f"Validation set: {X_val.shape}")
    print(f"Test set: {X_test.shape}")
    
    # Step 6: Train model
    model = train_model(X_train, y_train, X_val, y_val)
    
    # Step 7: Final evaluation on test set
    print("\n" + "="*60)
    print("Test Set Evaluation")
    print("="*60)
    
    test_metrics = model.evaluate(X_test, y_test)
    for metric, value in test_metrics.items():
        print(f"  {metric}: {value:.4f}")
    
    # Step 8: Save model
    save_model(model)
    
    print("\n" + "="*60)
    print("Training complete!")
    print("="*60)


if __name__ == "__main__":
    main()
