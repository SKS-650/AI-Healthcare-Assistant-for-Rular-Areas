"""Generate publication-quality figures for the research paper."""

import json
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path

# Set style for publication-quality figures
plt.style.use('seaborn-v0_8-paper')
sns.set_palette("husl")

# Configure matplotlib for better quality
plt.rcParams['figure.dpi'] = 300
plt.rcParams['savefig.dpi'] = 300
plt.rcParams['font.size'] = 10
plt.rcParams['font.family'] = 'serif'
plt.rcParams['axes.labelsize'] = 11
plt.rcParams['axes.titlesize'] = 12
plt.rcParams['xtick.labelsize'] = 9
plt.rcParams['ytick.labelsize'] = 9
plt.rcParams['legend.fontsize'] = 9


def load_results(filepath='performance_metrics.json'):
    """Load performance metrics."""
    with open(filepath, 'r') as f:
        return json.load(f)


def create_output_directory():
    """Create directory for figures."""
    figures_dir = Path('results') / 'figures'
    figures_dir.mkdir(parents=True, exist_ok=True)
    return figures_dir


def generate_performance_comparison(results, output_dir):
    """
    Figure 1: Performance Comparison Bar Chart
    Side-by-side bars for Accuracy, Precision, Recall, F1-Score
    """
    print("Generating Figure 1: Performance Comparison Bar Chart...")
    
    rf_metrics = results['random_forest']['test_metrics']
    xgb_metrics = results['xgboost']['test_metrics']
    
    metrics = ['Accuracy', 'Precision', 'Recall', 'F1-Score']
    rf_values = [
        rf_metrics['accuracy'],
        rf_metrics['precision'],
        rf_metrics['recall'],
        rf_metrics['f1_score']
    ]
    xgb_values = [
        xgb_metrics['accuracy'],
        xgb_metrics['precision'],
        xgb_metrics['recall'],
        xgb_metrics['f1_score']
    ]
    
    x = np.arange(len(metrics))
    width = 0.35
    
    fig, ax = plt.subplots(figsize=(8, 5))
    
    bars1 = ax.bar(x - width/2, rf_values, width, label='Random Forest', 
                   color='#2E86AB', alpha=0.8, edgecolor='black', linewidth=0.5)
    bars2 = ax.bar(x + width/2, xgb_values, width, label='XGBoost',
                   color='#A23B72', alpha=0.8, edgecolor='black', linewidth=0.5)
    
    ax.set_xlabel('Performance Metrics', fontweight='bold')
    ax.set_ylabel('Score', fontweight='bold')
    ax.set_title('Performance Comparison: Random Forest vs XGBoost', 
                 fontweight='bold', pad=15)
    ax.set_xticks(x)
    ax.set_xticklabels(metrics)
    ax.legend(loc='lower right', frameon=True, shadow=True)
    ax.set_ylim(0.80, 0.95)
    ax.grid(axis='y', alpha=0.3, linestyle='--')
    
    # Add value labels on bars
    for bars in [bars1, bars2]:
        for bar in bars:
            height = bar.get_height()
            ax.text(bar.get_x() + bar.get_width()/2., height,
                   f'{height:.4f}',
                   ha='center', va='bottom', fontsize=8)
    
    plt.tight_layout()
    output_path = output_dir / 'fig1_performance_comparison.png'
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()
    
    print(f"  Saved: {output_path}")


def generate_confusion_matrix(results, model_name, output_dir, fig_num):
    """
    Generate confusion matrix heatmap for a model.
    Due to 100 classes, we'll show a downsampled version for readability.
    """
    print(f"Generating Figure {fig_num}: {model_name} Confusion Matrix...")
    
    if model_name == "Random Forest":
        cm = np.array(results['random_forest']['test_metrics']['confusion_matrix'])
        output_filename = f'fig{fig_num}_rf_confusion_matrix.png'
        color = 'Blues'
    else:
        cm = np.array(results['xgboost']['test_metrics']['confusion_matrix'])
        output_filename = f'fig{fig_num}_xgb_confusion_matrix.png'
        color = 'Purples'
    
    # For 100 classes, show a reduced view (top 20 most common classes)
    # Calculate class frequencies
    class_totals = cm.sum(axis=1)
    top_indices = np.argsort(class_totals)[-20:][::-1]
    
    # Extract submatrix for top 20 classes
    cm_subset = cm[np.ix_(top_indices, top_indices)]
    
    # Normalize for better visualization
    cm_normalized = cm_subset.astype('float') / cm_subset.sum(axis=1)[:, np.newaxis]
    cm_normalized = np.nan_to_num(cm_normalized)  # Replace NaN with 0
    
    fig, ax = plt.subplots(figsize=(10, 8))
    
    im = ax.imshow(cm_normalized, interpolation='nearest', cmap=color, aspect='auto')
    
    ax.set_title(f'{model_name} Confusion Matrix\n(Top 20 Most Common Diseases)',
                 fontweight='bold', pad=15)
    
    # Add colorbar
    cbar = plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    cbar.set_label('Normalized Frequency', rotation=270, labelpad=15)
    
    # Remove tick labels for clarity (too many classes)
    ax.set_xlabel('Predicted Disease Class', fontweight='bold')
    ax.set_ylabel('True Disease Class', fontweight='bold')
    ax.set_xticks([])
    ax.set_yticks([])
    
    # Add text annotation
    ax.text(0.5, -0.1, 'Matrix shows classification accuracy for top 20 diseases',
            ha='center', va='top', transform=ax.transAxes, fontsize=9, style='italic')
    
    plt.tight_layout()
    output_path = output_dir / output_filename
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()
    
    print(f"  Saved: {output_path}")


def generate_time_vs_accuracy(results, output_dir):
    """
    Figure 4: Training Time vs Accuracy Trade-off
    """
    print("Generating Figure 4: Training Time vs Accuracy...")
    
    rf_metrics = results['random_forest']
    xgb_metrics = results['xgboost']
    
    models = ['Random Forest', 'XGBoost']
    training_times = [
        rf_metrics['training_time_seconds'],
        xgb_metrics['training_time_seconds']
    ]
    accuracies = [
        rf_metrics['test_metrics']['accuracy'],
        xgb_metrics['test_metrics']['accuracy']
    ]
    model_sizes = [
        rf_metrics['model_size_mb'],
        xgb_metrics['model_size_mb']
    ]
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    
    # Subplot 1: Training Time vs Accuracy
    colors = ['#2E86AB', '#A23B72']
    bars = ax1.bar(models, training_times, color=colors, alpha=0.8, 
                   edgecolor='black', linewidth=0.5)
    
    ax1.set_ylabel('Training Time (seconds)', fontweight='bold', color='black')
    ax1.set_title('Training Time Comparison', fontweight='bold', pad=15)
    ax1.tick_params(axis='y', labelcolor='black')
    ax1.grid(axis='y', alpha=0.3, linestyle='--')
    
    # Add accuracy as text annotations
    for i, (bar, acc) in enumerate(zip(bars, accuracies)):
        height = bar.get_height()
        ax1.text(bar.get_x() + bar.get_width()/2., height,
                f'{height:.2f}s\n(Acc: {acc:.4f})',
                ha='center', va='bottom', fontsize=9, fontweight='bold')
    
    # Subplot 2: Model Size Comparison
    bars2 = ax2.bar(models, model_sizes, color=colors, alpha=0.8,
                    edgecolor='black', linewidth=0.5)
    
    ax2.set_ylabel('Model Size (MB)', fontweight='bold')
    ax2.set_title('Model Size Comparison', fontweight='bold', pad=15)
    ax2.grid(axis='y', alpha=0.3, linestyle='--')
    
    # Add value labels
    for bar in bars2:
        height = bar.get_height()
        ax2.text(bar.get_x() + bar.get_width()/2., height,
                f'{height:.2f} MB',
                ha='center', va='bottom', fontsize=9, fontweight='bold')
    
    plt.tight_layout()
    output_path = output_dir / 'fig4_time_vs_accuracy.png'
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()
    
    print(f"  Saved: {output_path}")


def generate_additional_metrics_figure(results, output_dir):
    """
    Additional Figure: ROC-AUC and Inference Time Comparison
    """
    print("Generating Additional Figure: ROC-AUC and Inference Time...")
    
    rf_metrics = results['random_forest']['test_metrics']
    xgb_metrics = results['xgboost']['test_metrics']
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    
    # Subplot 1: ROC-AUC Comparison
    models = ['Random Forest', 'XGBoost']
    roc_aucs = [rf_metrics['roc_auc'], xgb_metrics['roc_auc']]
    colors = ['#2E86AB', '#A23B72']
    
    bars1 = ax1.bar(models, roc_aucs, color=colors, alpha=0.8,
                    edgecolor='black', linewidth=0.5)
    ax1.set_ylabel('ROC-AUC Score', fontweight='bold')
    ax1.set_title('ROC-AUC Comparison (Macro-averaged)', fontweight='bold', pad=15)
    ax1.set_ylim(0.995, 1.0)
    ax1.grid(axis='y', alpha=0.3, linestyle='--')
    
    for bar in bars1:
        height = bar.get_height()
        ax1.text(bar.get_x() + bar.get_width()/2., height,
                f'{height:.6f}',
                ha='center', va='bottom', fontsize=9, fontweight='bold')
    
    # Subplot 2: Inference Time Comparison
    inference_times = [
        rf_metrics['inference_time_ms_per_sample'],
        xgb_metrics['inference_time_ms_per_sample']
    ]
    
    bars2 = ax2.bar(models, inference_times, color=colors, alpha=0.8,
                    edgecolor='black', linewidth=0.5)
    ax2.set_ylabel('Inference Time (ms per sample)', fontweight='bold')
    ax2.set_title('Inference Time Comparison', fontweight='bold', pad=15)
    ax2.grid(axis='y', alpha=0.3, linestyle='--')
    
    for bar in bars2:
        height = bar.get_height()
        ax2.text(bar.get_x() + bar.get_width()/2., height,
                f'{height:.4f} ms',
                ha='center', va='bottom', fontsize=9, fontweight='bold')
    
    plt.tight_layout()
    output_path = output_dir / 'fig5_additional_metrics.png'
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()
    
    print(f"  Saved: {output_path}")


def main():
    """Main function to generate all figures."""
    print("="*70)
    print("GENERATING PUBLICATION-QUALITY FIGURES")
    print("="*70)
    
    # Load results
    results = load_results()
    
    # Create output directory
    output_dir = create_output_directory()
    print(f"\nOutput directory: {output_dir.absolute()}\n")
    
    # Generate all figures
    generate_performance_comparison(results, output_dir)
    generate_confusion_matrix(results, "Random Forest", output_dir, 2)
    generate_confusion_matrix(results, "XGBoost", output_dir, 3)
    generate_time_vs_accuracy(results, output_dir)
    generate_additional_metrics_figure(results, output_dir)
    
    print("\n" + "="*70)
    print("ALL FIGURES GENERATED SUCCESSFULLY")
    print("="*70)
    print(f"\nFigures saved in: {output_dir.absolute()}")
    print("\nGenerated files:")
    print("  1. fig1_performance_comparison.png")
    print("  2. fig2_rf_confusion_matrix.png")
    print("  3. fig3_xgb_confusion_matrix.png")
    print("  4. fig4_time_vs_accuracy.png")
    print("  5. fig5_additional_metrics.png")


if __name__ == "__main__":
    main()
