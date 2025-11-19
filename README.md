# 🌾 Forecasting Rice Yield in Pangasinan: A SARIMA Approach

## 📌 Project Overview
Rice farming is the economic backbone of **Pangasinan**, a top rice-producing province in the Philippines. However, yield fluctuations due to seasonal cycles and environmental changes pose risks to food security and farmer livelihoods.

This research project aims to develop a **Short-Term Rice Yield Forecasting Model** using the **Seasonal Autoregressive Integrated Moving Average (SARIMA)** methodology. By analyzing historical quarterly production data, this project seeks to provide accurate, data-driven projections to assist government agencies and cooperatives in **smart agricultural planning**.

## 🎯 Objectives
1.  **Identify** the statistical properties and seasonal patterns of historical rice yield in Pangasinan (2008–Present).
2.  **Develop** a valid SARIMA model $(p, d, q)(P, D, Q)_s$ optimized for the region's specific crop cycles.
3.  **Forecast** rice yields for the upcoming quarters of 2025 and 2026 to aid in resource allocation and logistics.

## 📂 Dataset
* **Source:** Provincial Agriculture Office / PSA (based on `2E4EVCP0.xlsx`)
* **Range:** 2008 – 2025 (Quarterly Data)
* **Variables:** * `Year` / `Quarter`: Temporal index.
    * `Yield`: Total Palay production in Metric Tons.
* **Preprocessing:** The raw dataset requires restructuring from a wide-format report into a tidy time-series format (Year, Quarter, Value).

## 🛠️ Tech Stack
* **Language:** R (version 4.0+)
* **IDE:** RStudio
* **Key Libraries:**
    * `tidyverse` (Data manipulation)
    * `readxl` (Reading Excel files)
    * `forecast` (Time series modeling)
    * `tseries` (Stationarity tests)
    * `zoo` (Handling missing time data)

## ⚙️ Methodology (Box-Jenkins Approach)
This project follows the standard Box-Jenkins process:
1.  **Data Cleaning:** Structuring raw Excel data into a clean CSV time series.
2.  **Identification:** Using ACF/PACF plots and the Augmented Dickey-Fuller (ADF) test to check for stationarity and seasonality ($S=4$).
3.  **Estimation:** Fitting the SARIMA model and selecting parameters based on AIC/BIC scores.
4.  **Diagnostic Checking:** Analyzing residuals to ensure White Noise (Ljung-Box test).
5.  **Forecasting:** Generating predictions for future quarters.

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone [https://github.com/your-username/pangasinan-rice-forecasting.git](https://github.com/your-username/pangasinan-rice-forecasting.git)
