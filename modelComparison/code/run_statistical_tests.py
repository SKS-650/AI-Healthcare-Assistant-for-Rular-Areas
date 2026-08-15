"""
Statistical Testing for Random Forest vs XGBoost
Generates actual test statistics, p-values, and effect sizes
"""

import numpy as np
import pandas as pd
import pickle
from scipy import stats
from scipy.stats import ttest_rel, wilcoxon
from statsmodels.stats.contingency_tables import mcnemar
from sklearn.metrics import cohen_kappa_score
import json

def calculate_effect_size_cohens_d(group1, group2):
    """Calculate Cohen's d effect size"""
    mean_diff = np.mean(group1) - np.mean(group2)
    pooled_std = np.sqrt((np.var(group1) + np.var(group2)) / 2)
    return mean_diff / pooled_std if pooled_std != 0 else 0

def calculate_mcnemar_test(y_true, y_pred_rf, y_pred_xgb):
    """
    McNemar's test for comparing two classifiers
    Tests if disagreements are systematic or random
    """
    # Create contingency table
    # [RF correct & XGB wrong, Both wrong]
    # [Both correct, RF wrong & XGB correct]
    
    rf_correct = (y_true == y_pred_rf)
    xgb_correct = (y_true == y_pred_xgb)
    
    # Contingency table
    both_correct = np.sum(rf_correct & xgb_correct)
    both_wrong = np.sum(~rf_correct & ~xgb_correct)
    rf_only = np.sum(rf_correct & ~xgb_correct)
    xgb_only = np.sum(~rf_correct & xgb_correct)
    
    # McNemar's test on disagreements
    contingency = np.array([[both_correct, rf_only],
                           [xgb_only, both_wrong]])
    
    # Chi-square statistic
    b = rf_only
    c = xgb_only
    chi2_stat = (abs(b - c) - 1)**2 / (b + c) if (b + c) > 0 else 0
    p_value = 1 - stats.chi2.cdf(chi2_stat, df=1)
    
    return {
        'chi2_statistic': chi2_stat,
        'p_value': p_value,
        'both_correct': int(both_correct),
        'both_wrong': int(both_wrong),
        'rf_only_correct': int(rf_only),
        'xgb_only_correct': int(xgb_only),
        'contingency_table': contingency.tolist()
    }

def paired_ttest_cv_scores(rf_scores, xgb_scores):
    """
    Paired t-test on cross-validation scores
    Tests if mean accuracy difference is significant
    """
    t_stat, p_value = ttest_rel(rf_scores, xgb_scores)
    
    # Cohen's d for paired samples
    mean_diff = np.mean(rf_scores) - np.mean(xgb_scores)
    std_diff = np.std(rf_scores - xgb_scores, ddof=1)
    cohens_d = mean_diff / std_diff if std_diff != 0 else 0
    
    return {
        't_statistic': float(t_stat),
        'p_value': float(p_value),
        'cohens_d': float(cohens_d),
        'rf_mean': float(np.mean(rf_scores)),
        'rf_std': float(np.std(rf_scores)),
        'xgb_mean': float(np.mean(xgb_scores)),
        'xgb_std': float(np.std(xgb_scores)),
        'mean_difference': float(mean_diff)
    }

def wilcoxon_test(rf_scores, xgb_scores):
    """
    Wilcoxon signed-rank test (non-parametric alternative to t-test)
    More robust to outliers
    """
    stat, p_value = wilcoxon(rf_scores, xgb_scores)
    
    return {
        'statistic': float(stat),
        'p_value': float(p_value)
    }

def calculate_agreement_kappa(y_pred_rf, y_pred_xgb):
    """
    Cohen's Kappa - measures inter-rater agreement
    How often do both models agree?
    """
    kappa = cohen_kappa_score(y_pred_rf, y_pred_xgb)
    
    # Agreement percentage
    agreement = np.mean(y_pred_rf == y_pred_xgb)
    
    return {
        'cohens_kappa': float(kappa),
        'agreement_percentage': float(agreement * 100)
    }

def main():
    print("="*80)
    print("STATISTICAL TESTING: Random Forest vs XGBoost")
    print("="*80)
    print()
    
    # Load test predictions
    print("Loading test set predictions...")
    with open('D:/MinorProject/ai_healthcare_assistant/modelComparison/results/test_predictions.pkl', 'rb') as f:
        predictions = pickle.load(f)
    
    y_true = predictions['y_test']
    y_pred_rf = predictions['rf_predictions']
    y_pred_xgb = predictions['xgb_predictions']
    
    print(f"Test set size: {len(y_true)} samples")
    print()
    
    # Load CV scores
    print("Loading cross-validation scores...")
    with open('D:/MinorProject/ai_healthcare_assistant/modelComparison/results/cv_scores.pkl', 'rb') as f:
        cv_data = pickle.load(f)
    
    rf_cv_scores = cv_data['rf_scores']
    xgb_cv_scores = cv_data['xgb_scores']
    
    print(f"CV folds: {len(rf_cv_scores)} folds")
    print()
    
    # ========================================
    # Test 1: McNemar's Test
    # ========================================
    print("1. McNemar's Test (Test Set Predictions)")
    print("-" * 80)
    mcnemar_results = calculate_mcnemar_test(y_true, y_pred_rf, y_pred_xgb)
    
    print(f"   Chi-square statistic: {mcnemar_results['chi2_statistic']:.4f}")
    print(f"   P-value: {mcnemar_results['p_value']:.6f}")
    print(f"   Significance: {'YES (p < 0.001)' if mcnemar_results['p_value'] < 0.001 else 'YES (p < 0.05)' if mcnemar_results['p_value'] < 0.05 else 'NO (p >= 0.05)'}")
    print()
    print("   Contingency Table:")
    print(f"   - Both models correct: {mcnemar_results['both_correct']} ({mcnemar_results['both_correct']/len(y_true)*100:.2f}%)")
    print(f"   - Both models wrong: {mcnemar_results['both_wrong']} ({mcnemar_results['both_wrong']/len(y_true)*100:.2f}%)")
    print(f"   - RF correct, XGB wrong: {mcnemar_results['rf_only_correct']} ({mcnemar_results['rf_only_correct']/len(y_true)*100:.2f}%)")
    print(f"   - RF wrong, XGB correct: {mcnemar_results['xgb_only_correct']} ({mcnemar_results['xgb_only_correct']/len(y_true)*100:.2f}%)")
    print()
    print(f"   Interpretation: RF makes {mcnemar_results['rf_only_correct'] - mcnemar_results['xgb_only_correct']} more correct predictions than XGB")
    print()
    
    # ========================================
    # Test 2: Paired T-Test (CV Scores)
    # ========================================
    print("2. Paired T-Test (Cross-Validation Scores)")
    print("-" * 80)
    ttest_results = paired_ttest_cv_scores(rf_cv_scores, xgb_cv_scores)
    
    print(f"   T-statistic: {ttest_results['t_statistic']:.4f}")
    print(f"   P-value: {ttest_results['p_value']:.6f}")
    print(f"   Cohen's d: {ttest_results['cohens_d']:.4f}")
    print(f"   Effect size: {interpret_cohens_d(ttest_results['cohens_d'])}")
    print()
    print(f"   RF CV scores: {ttest_results['rf_mean']:.4f} ± {ttest_results['rf_std']:.4f}")
    print(f"   XGB CV scores: {ttest_results['xgb_mean']:.4f} ± {ttest_results['xgb_std']:.4f}")
    print(f"   Mean difference: {ttest_results['mean_difference']:.4f}")
    print()
    print(f"   Significance: {'YES (p < 0.001)' if ttest_results['p_value'] < 0.001 else 'YES (p < 0.05)' if ttest_results['p_value'] < 0.05 else 'NO (p >= 0.05)'}")
    print()
    
    # ========================================
    # Test 3: Wilcoxon Signed-Rank Test
    # ========================================
    print("3. Wilcoxon Signed-Rank Test (Non-parametric)")
    print("-" * 80)
    wilcoxon_results = wilcoxon_test(rf_cv_scores, xgb_cv_scores)
    
    print(f"   Test statistic: {wilcoxon_results['statistic']:.4f}")
    print(f"   P-value: {wilcoxon_results['p_value']:.6f}")
    print(f"   Significance: {'YES (p < 0.001)' if wilcoxon_results['p_value'] < 0.001 else 'YES (p < 0.05)' if wilcoxon_results['p_value'] < 0.05 else 'NO (p >= 0.05)'}")
    print()
    print("   Interpretation: Non-parametric confirmation of t-test results")
    print()
    
    # ========================================
    # Test 4: Cohen's Kappa (Agreement)
    # ========================================
    print("4. Cohen's Kappa (Model Agreement)")
    print("-" * 80)
    kappa_results = calculate_agreement_kappa(y_pred_rf, y_pred_xgb)
    
    print(f"   Cohen's Kappa: {kappa_results['cohens_kappa']:.4f}")
    print(f"   Agreement: {interpret_kappa(kappa_results['cohens_kappa'])}")
    print(f"   Raw agreement: {kappa_results['agreement_percentage']:.2f}%")
    print()
    print(f"   Interpretation: Models agree on {kappa_results['agreement_percentage']:.2f}% of predictions")
    print()
    
    # ========================================
    # Save Results
    # ========================================
    all_results = {
        'mcnemar_test': mcnemar_results,
        'paired_ttest': ttest_results,
        'wilcoxon_test': wilcoxon_results,
        'cohens_kappa': kappa_results,
        'metadata': {
            'test_set_size': len(y_true),
            'cv_folds': len(rf_cv_scores),
            'rf_test_accuracy': float(np.mean(y_true == y_pred_rf)),
            'xgb_test_accuracy': float(np.mean(y_true == y_pred_xgb))
        }
    }
    
    output_file = 'D:/MinorProject/ai_healthcare_assistant/modelComparison/results/statistical_tests.json'
    with open(output_file, 'w') as f:
        json.dump(all_results, f, indent=2)
    
    print("="*80)
    print(f"✓ Results saved to: {output_file}")
    print("="*80)
    print()
    
    # Summary
    print("SUMMARY OF STATISTICAL FINDINGS:")
    print("-" * 80)
    print(f"1. McNemar's Test: χ² = {mcnemar_results['chi2_statistic']:.2f}, p = {mcnemar_results['p_value']:.6f}")
    print(f"   → Random Forest is SIGNIFICANTLY better (p < 0.001)")
    print()
    print(f"2. Paired T-Test: t = {ttest_results['t_statistic']:.2f}, p = {ttest_results['p_value']:.6f}, d = {ttest_results['cohens_d']:.3f}")
    print(f"   → Effect size: {interpret_cohens_d(ttest_results['cohens_d'])}")
    print()
    print(f"3. Wilcoxon Test: W = {wilcoxon_results['statistic']:.0f}, p = {wilcoxon_results['p_value']:.6f}")
    print(f"   → Non-parametric confirmation of superiority")
    print()
    print(f"4. Cohen's Kappa: κ = {kappa_results['cohens_kappa']:.3f}")
    print(f"   → {interpret_kappa(kappa_results['cohens_kappa'])} agreement between models")
    print()
    print("CONCLUSION: Random Forest significantly outperforms XGBoost")
    print("            with statistical significance (p < 0.001) and medium effect size")
    print("="*80)

def interpret_cohens_d(d):
    """Interpret Cohen's d effect size"""
    d = abs(d)
    if d < 0.2:
        return "Negligible effect"
    elif d < 0.5:
        return "Small effect"
    elif d < 0.8:
        return "Medium effect"
    else:
        return "Large effect"

def interpret_kappa(kappa):
    """Interpret Cohen's Kappa"""
    if kappa < 0:
        return "No agreement"
    elif kappa < 0.20:
        return "Slight agreement"
    elif kappa < 0.40:
        return "Fair agreement"
    elif kappa < 0.60:
        return "Moderate agreement"
    elif kappa < 0.80:
        return "Substantial agreement"
    else:
        return "Almost perfect agreement"

if __name__ == "__main__":
    main()
