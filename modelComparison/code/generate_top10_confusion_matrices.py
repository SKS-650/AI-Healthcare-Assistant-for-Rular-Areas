"""Generate confusion matrices for top 10 diseases with numbers displayed."""

import json
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path

# Set style
plt.rcParams['figure.dpi'] = 300
plt.rcParams['savefig.dpi'] = 300
plt.rcParams['font.size'] = 9
plt.rcParams['font.family'] = 'serif'

def load_results(filepath='performance_metrics.json'):
    """Load performance metrics."""
    with open(filepath, 'r') as f:
        return json.load(f)

def create_output_directory():
    """Create directory for figures."""
    figures_dir = Path('results') / 'figures'
    figures_dir.mkdir(parents=True, exist_ok=True)
    return figures_dir

def generate_top10_confusion_matrix(results, model_name, output_dir, fig_num):
    """
    Generate confusion matrix heatmap for top 10 diseases with numbers.
    """
    print(f"Generating Figure {fig_num}: {model_name} Confusion Matrix (Top 10)...")
    
    if model_name == "Random Forest":
        cm = np.array(results['random_forest']['test_metrics']['confusion_matrix'])
        output_filename = f'fig{fig_num}_rf_confusion_matrix_top10.png'
        color = 'Blues'
    else:
        cm = np.array(results['xgboost']['test_metrics']['confusion_matrix'])
        output_filename = f'fig{fig_num}_xgb_confusion_matrix_top10.png'
        color = 'Purples'
    
    # Get disease names
    disease_names = results['dataset_info']['class_names']
    
    # Calculate class totals and get top 10
    class_totals = cm.sum(axis=1)
    top_indices = np.argsort(class_totals)[-10:][::-1]
    
    # Extract submatrix for top 10 classes
    cm_subset = cm[np.ix_(top_indices, top_indices)]
    
    # Get disease names for top 10
    top_disease_names = [disease_names[i] for i in top_indices]
    
    # Shorten disease names for better display
    short_names = []
    for name in top_disease_names:
        if len(name) > 15:
            short_names.append(name[:12] + '...')
        else:
            short_names.append(name)
    
    # Create figure
    fig, ax = plt.subplots(figsize=(12, 10))
    
    # Plot heatmap
    im = ax.imshow(cm_subset, interpolation='nearest', cmap=color, aspect='auto')
    
    # Add colorbar
    cbar = plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    cbar.set_label('Number of Samples', rotation=270, labelpad=20, fontsize=11, fontweight='bold')
    
    # Set ticks and labels
    ax.set_xticks(np.arange(10))
    ax.set_yticks(np.arange(10))
    ax.set_xticklabels(short_names, rotation=45, ha='right', fontsize=9)
    ax.set_yticklabels(short_names, fontsize=9)
    
    # Labels
    ax.set_xlabel('Predicted Disease', fontweight='bold', fontsize=11)
    ax.set_ylabel('True Disease', fontweight='bold', fontsize=11)
    ax.set_title(f'{model_name} Confusion Matrix\\n(Top 10 Most Common Diseases)',
                 fontweight='bold', fontsize=13, pad=15)
    
    # Add text annotations with actual numbers
    for i in range(10):
        for j in range(10):
            value = cm_subset[i, j]
            # Choose text color based on background
            text_color = 'white' if value > cm_subset.max() / 2 else 'black'
            
            # Add the number
            text = ax.text(j, i, int(value),
                          ha="center", va="center",
                          color=text_color, fontsize=9, fontweight='bold')
    
    # Add grid for better readability
    ax.set_xticks(np.arange(10) - 0.5, minor=True)
    ax.set_yticks(np.arange(10) - 0.5, minor=True)
    ax.grid(which='minor', color='gray', linestyle='-', linewidth=0.5, alpha=0.3)
    
    plt.tight_layout()
    output_path = output_dir / output_filename
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()
    
    print(f"  Saved: {output_path}")
    print(f"  Top 10 diseases included:")
    for i, (idx, name) in enumerate(zip(top_indices, top_disease_names), 1):
        print(f"    {i}. {name} ({class_totals[idx]} samples)")

def main():
    """Generate top 10 confusion matrices."""
    print("="*70)
    print("GENERATING TOP 10 CONFUSION MATRICES WITH NUMBERS")
    print("="*70)
    
    # Load results
    results = load_results()
    
    # Create output directory
    output_dir = create_output_directory()
    print(f"\nOutput directory: {output_dir.absolute()}\n")
    
    # Generate confusion matrices
    generate_top10_confusion_matrix(results, "Random Forest", output_dir, 2)
    print()
    generate_top10_confusion_matrix(results, "XGBoost", output_dir, 3)
    
    print("\n" + "="*70)
    print("TOP 10 CONFUSION MATRICES GENERATED SUCCESSFULLY")
    print("="*70)
    print(f"\nGenerated files:")
    print("  1. fig2_rf_confusion_matrix_top10.png")
    print("  2. fig3_xgb_confusion_matrix_top10.png")

if __name__ == "__main__":
    main()
