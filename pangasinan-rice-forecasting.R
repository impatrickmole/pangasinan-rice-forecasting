# 1. Install necessary packages (if you haven't already)
if (!require("readxl")) install.packages("readxl")
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("zoo")) install.packages("zoo") # 'zoo' is needed for filling missing values

# 2. Load the libraries
library(readxl)
library(dplyr)
library(tidyr)
library(zoo)
library(ggplot2)
library(scales)

# --- STEP 1: LOAD THE DATA ---
# Make sure the file "2E4EVCP0.xlsx" is in your R working directory
# We read it with col_names = FALSE to handle the messy headers manually
raw_data <- read_excel("2E4EVCP0.xlsx", col_names = FALSE)

# --- STEP 2: EXTRACT AND CLEAN ROWS ---

# Row 1 in Excel contains the YEARS (indices are 1-based in R)
# We remove the first column (which is just labels like 'Type')
years_raw <- as.numeric(as.vector(raw_data[1, -1])) 

# Use na.locf to "Forward Fill" the years (replace NA with the previous year)
years_clean <- na.locf(years_raw, na.rm = FALSE)

# Row 2 in Excel contains the PERIODS (Quarter 1, Semester 1, etc.)
periods_raw <- as.character(as.vector(raw_data[2, -1]))

# Row 5 in Excel contains the TOTAL PALAY YIELD (based on your file structure)
# Check: Row 3 is Irrigated, Row 4 is Rainfed, Row 5 is Total Palay
yield_raw <- as.numeric(as.vector(raw_data[5, -1]))

# --- STEP 3: CREATE THE DATAFRAME ---

# Combine these vectors into a temporary dataframe
temp_df <- data.frame(
  Year = years_clean,
  Period = periods_raw,
  Yield = yield_raw,
  stringsAsFactors = FALSE
)

# --- STEP 4: FILTER AND FORMAT ---

final_df <- temp_df %>%
  # Filter: We only want rows where Period contains "Quarter"
  filter(grepl("Quarter", Period)) %>%
  
  # Extract the Quarter Number (e.g., "Quarter 1" -> 1)
  mutate(
    Quarter = as.numeric(gsub("Quarter ", "", Period)),
    
    # Create a specific Date column for plotting (Day is set to 1st of the Quarter)
    # Q1=Jan(1), Q2=Apr(4), Q3=Jul(7), Q4=Oct(10)
    Date = as.Date(paste(Year, (Quarter - 1) * 3 + 1, "01", sep = "-"))
  ) %>%
  
  # Select and reorder the columns we need
  select(Date, Year, Quarter, Yield) %>%
  
  # Sort by Date just to be safe
  arrange(Date)

# --- STEP 5: INSPECT AND SAVE ---

# View the first few rows
print(head(final_df))

# Check for any missing values
print(paste("Missing Values:", sum(is.na(final_df$Yield))))

# Save the cleaned data to a CSV file for your analysis
write.csv(final_df, "Pangasinan_Rice_Yield_Clean.csv", row.names = FALSE)

# Simple plot to verify the data looks correct
plot(final_df$Date, final_df$Yield, type = "l", col = "green", 
     main = "Quarterly Rice Yield in Pangasinan", 
     xlab = "Year", ylab = "Yield (MT)")

#Enhance Plot for visualization
# --- PLOT OPTION 1: Enhanced Trend Line ---
# This shows the history with clear markers for each quarter

ggplot(final_df, aes(x = Date, y = Yield)) +
  # Add the line
  geom_line(color = "#0073C2", size = 1) +
  # Add points so you can see exactly where each quarter falls
  geom_point(color = "#0073C2", size = 2) +
  # Add a smooth trend line (optional - helps see long-term growth)
  geom_smooth(method = "loess", color = "red", se = FALSE, linetype = "dashed", size = 0.5) +
  
  # Fix the X-axis to show every year
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  # Fix the Y-axis to use commas (e.g., 200,000 instead of scientific notation)
  scale_y_continuous(labels = comma) +
  
  # Add titles and labels
  labs(
    title = "Historical Quarterly Rice Yield in Pangasinan (2008–2025)",
    subtitle = "Blue line: Actual Yield | Red dashed line: Long-term Trend",
    x = "Year",
    y = "Yield (Metric Tons)",
    caption = "Source: Provincial Agriculture Office Data"
  ) +
  
  # Use a clean, professional theme
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1), # Rotate years for readability
    plot.title = element_text(face = "bold", size = 14)
  )


# --- PLOT OPTION 2: Seasonal Pattern Plot ---
# This is VERY important for your study. It proves why you need SARIMA.
# It shows the distribution of yield for each Quarter specifically.

ggplot(final_df, aes(x = factor(Quarter), y = Yield, fill = factor(Quarter))) +
  geom_boxplot() +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Seasonal Distribution of Rice Yield by Quarter",
    subtitle = "Demonstrating strong seasonality: Q4 consistently has the highest yield",
    x = "Quarter",
    y = "Yield (Metric Tons)",
    fill = "Quarter"
  ) +
  theme_bw()