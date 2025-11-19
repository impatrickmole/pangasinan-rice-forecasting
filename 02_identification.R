# Load necessary libraries
library(forecast)  # For ACF/PACF and auto.arima
library(tseries)   # For ADF Test
library(ggplot2)
library(readr)     # For reading the CSV

# --- STEP 1: LOAD AND CONVERT DATA ---

# 1. Read the clean CSV file we created in the previous step
data <- read_csv("Pangasinan_Rice_Yield_Clean.csv")

# 2. Convert to a Time Series Object (ts)
# Frequency = 4 means "Quarterly" data
# Start = c(2008, 1) means starting at 1st Quarter of 2008
ts_yield <- ts(data$Yield, start = c(2008, 1), frequency = 4)

# Visualize the raw time series again just to be sure
autoplot(ts_yield) +
  ggtitle("Raw Time Series: Rice Yield") +
  ylab("Yield (MT)") + theme_minimal()

# --- STEP 2: STATIONARITY CHECK (ADF TEST) ---
# The Augmented Dickey-Fuller (ADF) test checks if the data is "stationary".
# Null Hypothesis (H0): The data is NOT stationary (it has a unit root).
# Alternative (H1): The data IS stationary.
# If p-value < 0.05, we reject H0 -> Data is Stationary.

print("--- ADF TEST RESULTS (RAW DATA) ---")
adf_result <- adf.test(ts_yield)
print(adf_result)

# --- STEP 3: CHECKING FOR DIFFERENCING ---
# Since we saw strong seasonality in your Boxplot, we likely need "Seasonal Differencing".

# Check how many seasonal differences are needed (D)
ns_diffs <- nsdiffs(ts_yield)
print(paste("Number of Seasonal Differences needed (D):", ns_diffs))

# Check how many regular differences are needed (d)
nd_diffs <- ndiffs(ts_yield)
print(paste("Number of Regular Differences needed (d):", nd_diffs))

# --- STEP 4: APPLY DIFFERENCING (TRANSFORMATION) ---

# If the data is non-stationary (p-value > 0.05), we must difference it.
# Usually for rice, we do Seasonal Differencing (Lag 4) first.

ts_stationary <- ts_yield

# Apply Seasonal Differencing if needed
if (ns_diffs > 0) {
  ts_stationary <- diff(ts_stationary, lag = 4)
  print("Applied Seasonal Differencing (Lag 4)")
}

# Apply Regular Differencing if needed (usually done after seasonal)
if (nd_diffs > 0) {
  ts_stationary <- diff(ts_stationary, differences = nd_diffs)
  print("Applied Regular Differencing")
}

# Check ADF again on the differenced data
print("--- ADF TEST RESULTS (AFTER DIFFERENCING) ---")
adf_result_diff <- adf.test(ts_stationary)
print(adf_result_diff)

# --- STEP 5: ACF and PACF PLOTS (IDENTIFICATION) ---
# These plots help us guess the ARIMA (p,d,q) and Seasonal (P,D,Q) orders.

# Plot ACF and PACF for the STATIONARY (Differenced) series
# ggtsdisplay plots the Time Series, ACF, and PACF all in one image.
ggtsdisplay(ts_stationary, 
            main = "Stationary Rice Yield (After Differencing)",
            ylab = "Differenced Yield",
            theme = theme_bw())



#---------------------------------------------------------------#

# --- STEP 1: AUTOMATIC MODEL SELECTION ---
# auto.arima will test many combinations and pick the one with the lowest AIC
best_model <- auto.arima(ts_yield, 
                         seasonal = TRUE, 
                         stepwise = FALSE, 
                         approximation = FALSE, # strictly accurate calculation
                         trace = TRUE) # This will show you the models it tries

print("--- BEST MODEL FOUND BY AUTO.ARIMA ---")
print(best_model)

# --- STEP 2: MANUAL MODEL (Our Guess from the Plot) ---
# Let's force R to try the model we saw in the graphs: (0,1,1)(0,1,1)[4]
# Note: Adjust 'd' and 'D' based on what differencing you actually did.
# Usually for rice: d=0 or 1, D=1 (seasonal diff) is standard.

manual_model <- Arima(ts_yield, order=c(0,1,1), seasonal=c(0,1,1))

print("--- MANUAL MODEL (FROM PLOTS) ---")
print(manual_model)

# --- STEP 3: COMPARE ACCURACY ---
# Check which one has the lower AICc value. Lower is better.
print(paste("Auto ARIMA AICc:", best_model$aicc))
print(paste("Manual Model AICc:", manual_model$aicc))

# --- STEP 4: RESIDUAL CHECK ---
# We need to check if the errors (residuals) look like "White Noise" (random)
checkresiduals(best_model)




#--------------------------------------------------------#
#MODEL VALIDATION

# --- STEP 1: VALIDATE THE MANUAL MODEL ---
# We already defined 'manual_model' in the previous step.
# Now we check ITS residuals (instead of best_model).

checkresiduals(manual_model)

# Look at the Ljung-Box p-value in the output.
# We WANT p-value > 0.05 (which means "No significant pattern left").

# --- STEP 2: GENERATE FORECASTS ---
# If the check passes, we forecast the next 6 quarters (rest of 2025 + 2026)

forecast_values <- forecast(manual_model, h=6)

# Print the numbers
print(forecast_values)

# --- STEP 3: PLOT THE FORECAST ---
# This creates the final "money shot" graph for your research results.

autoplot(forecast_values) +
  autolayer(forecast_values$mean, series="Forecast", size=1.2) +
  ggtitle("Forecasted Rice Yield in Pangasinan (2025-2026)") +
  xlab("Year") + ylab("Yield (Metric Tons)") +
  theme_minimal() +
  theme(legend.position="bottom")