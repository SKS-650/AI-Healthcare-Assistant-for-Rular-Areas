# 🚀 Quick Start Guide - Model Comparison Research

## 📁 What's in This Folder?

This folder contains the complete research comparing Random Forest vs XGBoost for symptom-based disease prediction.

---

## 📊 Key Results Summary

### Winner: Random Forest 🏆

| Metric | Random Forest | XGBoost |
|--------|---------------|---------|
| **Accuracy** | **88.31%** ✅ | 86.97% |
| **Precision** | **90.13%** ✅ | 87.08% |
| **Training Time** | **33.25s** ✅ | 291.17s |
| **Inference** | **0.062ms** ✅ | 0.095ms |
| **Model Size** | 626.40 MB | **155.19 MB** ✅ |

**Bottom Line:** Random Forest is faster, more accurate, and better for Nepal's healthcare context!

---

## 📂 Folder Structure

```
modelComparison/
├── README.md              ⭐ FULL DOCUMENTATION (Read this!)
├── QUICK_START.md         📄 This file
│
├── code/                  💻 All Python implementations
│   ├── xgboost_classifier.py
│   ├── optimize_hyperparameters.py
│   ├── train_and_evaluate_both.py
│   ├── generate_figures.py
│   ├── generate_top10_confusion_matrices.py
│   └── generate_ieee_paper.py
│
├── results/               📊 Experimental data
│   ├── best_hyperparameters.json
│   ├── performance_metrics.json
│   └── literature_sources.md
│
├── figures/               🖼️ Publication-quality images
│   ├── fig1_performance_comparison.png
│   ├── fig2_rf_confusion_matrix_top10.png
│   ├── fig3_xgb_confusion_matrix_top10.png
│   ├── fig4_time_vs_accuracy.png
│   └── fig5_additional_metrics.png
│
├── paper/                 📄 Research paper
│   ├── model_comparision.docx (IEEE format)
│   └── research_paper_content.md
│
└── data/                  📁 (Dataset in parent folders)
```

---

## 🎯 What We Did

### Phase 1: Implementation
1. ✅ Created XGBoost classifier from scratch
2. ✅ Optimized hyperparameters using GridSearchCV
3. ✅ Trained both models on 96,088 samples
4. ✅ Generated publication-quality visualizations

### Phase 2: Evaluation
1. ✅ Tested on 19,218 samples (100 diseases)
2. ✅ Measured 5+ performance metrics
3. ✅ Performed 5-fold cross-validation
4. ✅ Statistical significance testing (p < 0.001)

### Phase 3: Documentation
1. ✅ Wrote complete IEEE research paper
2. ✅ Created comprehensive README
3. ✅ Compiled 19 academic citations
4. ✅ Generated all figures with actual data

---

## 🏃 How to Use

### Option 1: View Results (Fastest)
1. Open `README.md` for full analysis
2. Check `figures/` folder for visualizations
3. Read `paper/model_comparision.docx` for IEEE paper

### Option 2: Reproduce Experiments
```bash
cd code/
python optimize_hyperparameters.py    # ~15 min
python train_and_evaluate_both.py     # ~10 min
python generate_figures.py            # ~2 min
```

### Option 3: Generate Paper
```bash
cd code/
python generate_ieee_paper.py         # ~10 sec
# Output: paper/model_comparision.docx
```

---

## 📈 Key Findings

### 1. Performance
- Random Forest achieved **88.31% accuracy**
- XGBoost achieved **86.97% accuracy**
- Difference is **statistically significant** (p < 0.001)

### 2. Speed
- RF trains **8.76× faster** (33s vs 291s)
- RF predicts **1.53× faster** per sample
- RF processes **16,129 samples/second**

### 3. Storage
- RF model: 626.40 MB
- XGB model: 155.19 MB (**4× smaller**)
- Trade-off: Accuracy & speed vs storage

### 4. Recommendation
**Use Random Forest for:**
- ✅ Clinical diagnostic support systems
- ✅ Rural health posts with limited resources
- ✅ Real-time predictions needed
- ✅ Offline deployment required

**Use XGBoost for:**
- ✅ Mobile apps (storage constrained)
- ✅ Edge devices (IoT sensors)
- ✅ When model size is critical
- ✅ Cloud services optimizing storage costs

---

## 📊 Results at a Glance

### Test Set Performance
```
Random Forest:
  Accuracy:  88.31% ⭐
  Precision: 90.13% ⭐
  Recall:    88.31% ⭐
  F1-Score:  88.70% ⭐
  ROC-AUC:   99.83%

XGBoost:
  Accuracy:  86.97%
  Precision: 87.08%
  Recall:    86.97%
  F1-Score:  87.00%
  ROC-AUC:   99.92% ⭐
```

### Cross-Validation (5-Fold)
```
Random Forest: 88.81% ± 0.46% ⭐
XGBoost:       87.43% ± 0.58%
```

### Computational Efficiency
```
Training Time:
  RF:  33.25 seconds   ⚡ 8.76× faster
  XGB: 291.17 seconds

Inference Time (per sample):
  RF:  0.062 ms   ⚡ 1.53× faster
  XGB: 0.095 ms

Model Size:
  RF:  626.40 MB
  XGB: 155.19 MB   💾 4.04× smaller
```

---

## 🎓 Academic Impact

### Dataset Scale
- **96,088 samples** (largest in literature)
- **100 disease classes** (most comprehensive)
- **230 symptom features** (extensive coverage)

### Comparison with Prior Work
| Study | Samples | Diseases | Best Accuracy |
|-------|---------|----------|---------------|
| Sharma et al. (2016) | 1,500 | 10 | 89.5% |
| Gupta et al. (2020) | 5,200 | 41 | 85.0% |
| Wang et al. (2021) | 12,000 | 25 | 90.1% |
| **Our Study (2026)** | **96,088** | **100** | **88.31%** |

### Novel Contributions
1. ✅ Largest symptom-disease dataset comparison
2. ✅ Comprehensive computational analysis
3. ✅ Nepal healthcare context consideration
4. ✅ Production-ready deployment guidance

---

## 📄 Paper Information

**Title:** "Comparative Analysis of Random Forest and XGBoost for Symptom-Based Disease Prediction: A Study with Large-Scale Medical Dataset"

**Authors:**
- Shyam Kishor Sah
- Pandit Dhananjay
- Nitika K. Yadav
- Amit K. Shrivastava

**Institution:** Nepal College of Information Technology, Lalitpur, Nepal

**Format:** IEEE Conference Paper (6-7 pages)

**Status:** ✅ Complete and ready for submission

---

## 🔗 Quick Links

- **Full Documentation:** `README.md` (50+ KB, very detailed)
- **Research Paper:** `paper/model_comparision.docx`
- **All Figures:** `figures/` folder
- **Experimental Data:** `results/` folder
- **Source Code:** `code/` folder

---

## 📞 Contact

**Questions?** Contact the research team:
- shyam.231339@ncit.edu.np
- pandit.231328@ncit.edu.np
- nitika.231325@ncit.edu.np
- amit.shrivastava@ncit.edu.np

**Institution:** Nepal College of Information Technology, Lalitpur, Nepal

---

## ✨ Next Steps

### For Reviewers
1. Read `README.md` for complete analysis
2. Review `paper/model_comparision.docx`
3. Examine figures in `figures/` folder
4. Check results in `results/` folder

### For Researchers
1. Review methodology in `README.md`
2. Run reproduction scripts in `code/`
3. Verify results match reported metrics
4. Cite our work in your research

### For Developers
1. Use `xgboost_classifier.py` as template
2. Adapt training pipeline for your data
3. Customize visualizations as needed
4. Deploy models in production

---

**📌 Remember:** Random Forest wins for accuracy & speed!  
**💾 Exception:** Use XGBoost if storage is critically limited.

**⭐ Last Updated:** August 15, 2026  
**📋 Version:** 1.0  
**✅ Status:** Production Ready

---

**👉 Start with `README.md` for the full story!**
