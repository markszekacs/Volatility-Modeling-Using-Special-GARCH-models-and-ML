# Volatility Forecasting and VaR Backtesting  
### Econometric Models vs. Machine Learning Baselines

## Overview

This repository implements a **reproducible framework for volatility forecasting and Value-at-Risk (VaR) evaluation** using financial return data.

The core focus is a **comparison between classical econometric volatility models** (e.g. GARCH-family models) and **simple machine learning baselines**, evaluated under the *same* forecasting and backtesting protocol.

The code is modular, transparent, and designed to be easily extended to:
- additional assets,
- alternative volatility models,
- or other ML-based forecasting approaches.

---

## Motivation: Why Compare Econometric Models and Machine Learning?

Volatility forecasting is traditionally dominated by parametric models such as GARCH, EGARCH, and APARCH, which:
- are interpretable,
- are theoretically grounded,
- and remain standard in risk management and regulation.

However, recent literature suggests that **machine learning models may capture nonlinear dynamics** in volatility that classical models miss.

This project is **not** about replacing econometric models with complex black-box ML.  
Instead, it asks a more careful question:

> *Does even a simple, transparent ML baseline provide competitive or complementary predictive power relative to established econometric models when evaluated fairly?*

To answer this, both model classes are:
- trained using rolling/expanding windows,
- evaluated out-of-sample,
- and assessed using identical VaR backtesting procedures.

---

## Methodology

### Data
- Daily financial return series (e.g. insurance sector equities).
- Data is publicly available and can be obtained from **Yahoo Finance**.
- Returns are computed as log-returns from price series.

### Econometric Models
Implemented using the `rugarch` framework:
- sGARCH(1,1)
- eGARCH(1,1)
- apARCH(1,1)

Each model is estimated in a **rolling forecasting setup**, producing one-step-ahead volatility and VaR forecasts.

### Machine Learning Baseline
A deliberately **minimal ML model** is included:
- Ridge regression (L2-regularized linear model)
- Lagged absolute returns used as features
- Forecasts conditional volatility, which is mapped to VaR

This choice ensures that:
- the ML component is fast and reproducible,
- results are interpretable,
- and improvements cannot be attributed to excessive model complexity.

---

## Validation and Backtesting

All models are evaluated using **formal VaR backtesting procedures**, including:

- **Kupiec unconditional coverage test**
- **Christoffersen independence test**
- **Christoffersen conditional coverage test**

This ensures that performance comparisons are:
- statistically grounded,
- consistent with risk management practice,
- and directly interpretable.

Backtest results are saved as tables and figures for further analysis.

---

## Project Structure

''' text

├── R/
│ ├── 00_config.R # Global configuration (paths, rolling window, VaR level)
│ ├── 01_data_io.R # Data loading and caching utilities
│ ├── 02_preprocess.R # Cleaning and return computation
│ ├── 03_garch_specs.R # GARCH / EGARCH / APARCH model specifications
│ ├── 04_garch_rollfit.R # Rolling estimation and VaR extraction
│ ├── 05_ml_baseline.R # Machine learning baseline (ridge regression)
│ ├── 06_var_backtests.R # Kupiec and Christoffersen VaR backtests
│ └── 07_outputs.R # Plotting and table export utilities
│ └── 08_run_all.R # One-command full reproduction
└── README.md
'''

## How to Run the Project

All results in this repository are generated automatically by a single script.

From the project root, run:

    Rscript scripts/01_run_all.R

This script executes the full pipeline:
1. Loads and preprocesses the input data
2. Estimates econometric volatility models
3. Runs the machine learning baseline
4. Generates one-step-ahead VaR forecasts
5. Performs statistical VaR backtests
6. Saves all figures and tables to the outputs/ directory

No manual intervention is required once the data files are in place.

---

## Model Comparison Philosophy

This project is designed around fair and controlled model comparison.

Econometric and machine learning models are:
- trained using identical rolling or expanding windows,
- evaluated strictly out-of-sample,
- and assessed using the same statistical backtesting procedures.

This ensures that differences in performance can be attributed to model structure rather than differences in evaluation design.

The objective is not to replace traditional volatility models, but to assess whether even simple machine learning methods can provide complementary predictive power under realistic risk management constraints.

---

## Why a Minimal Machine Learning Baseline?

The machine learning component is intentionally kept simple.

Rather than relying on complex neural networks or large feature sets, the ML baseline:
- uses lagged absolute returns as predictors,
- applies ridge (L2-regularized) regression,
- produces conditional volatility forecasts that are mapped directly to VaR.

This design choice ensures that any observed performance differences are driven by modeling assumptions rather than excessive model complexity.

---

## Validation and Statistical Backtesting

All models are evaluated using formal Value-at-Risk backtesting procedures commonly applied in empirical finance and risk management:

- Kupiec unconditional coverage test
- Christoffersen independence test
- Christoffersen conditional coverage test

These tests jointly assess both the frequency and the temporal dependence of VaR violations, providing a statistically grounded evaluation of model adequacy.

---

## Extensibility

The codebase is intentionally modular.

New assets, models, or forecasting approaches can be added by:
- extending the model specification modules,
- returning forecasts in a standardized format,
- and reusing the existing backtesting and plotting utilities.

This allows the framework to scale naturally to broader empirical studies without changes to the validation pipeline.

---

## Intended Use

This repository is suitable for:
- academic research and replication,
- comparative studies of volatility forecasting methods,
- teaching applied risk modeling,
- or as a foundation for more advanced empirical or machine learning extensions.

---

## Disclaimer

This project is intended for research and educational purposes only and does not constitute financial advice.

## Project Structure
