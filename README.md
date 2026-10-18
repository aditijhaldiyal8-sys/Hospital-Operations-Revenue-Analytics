
# Hospital Operations & Revenue Analytics

## Project Overview

This project analyzes hospital operational and financial data using SQL, Power BI, Python, and Machine Learning. The goal is to understand hospital performance, identify revenue and operational patterns, and explore predictive modeling for Length of Stay (LOS) and hospital revenue.

The project combines data analysis, interactive dashboards, and machine learning to turn raw hospital data into meaningful insights.

## Objectives

- Analyze hospital cases, patient demographics, specialties, and payer information.
- Examine hospital revenue and average revenue across different categories.
- Explore relationships between patient severity, case type, and Length of Stay.
- Build interactive Power BI dashboards for hospital performance analysis.
- Train and compare machine learning models for LOS and revenue prediction.
- Evaluate model performance using standard regression metrics.

## Tools & Technologies

- **SQL (PostgreSQL):** Data cleaning, querying, aggregation, and analysis.
- **Python:** Data preparation, analysis, and machine learning.
- **Pandas:** Data manipulation and preprocessing.
- **Scikit-learn:** Model training and evaluation.
- **Power BI:** Interactive dashboards and data visualization.
- **Jupyter Notebook:** Python development and experimentation.
- **GitHub:** Project version control and documentation.

## Project Workflow

### 1. Data Preparation and SQL Analysis

Hospital data was prepared and analyzed using PostgreSQL.

Key activities included:
- Checking missing values, duplicates, and invalid data.
- Cleaning text fields and preparing data for analysis.
- Analyzing revenue by payer, specialty, and case type.
- Examining patient demographics and case severity.
- Comparing operational metrics, including Length of Stay and discharge patterns.

### 2. Hospital Performance Dashboard

Power BI was used to present hospital operational and financial insights through visualizations and KPI cards.

The analysis covers:
- Hospital case volume and revenue.
- Average revenue and payer distribution.
- Specialty-level performance.
- Medical versus surgical cases.
- Patient demographics and severity.
- Length of Stay and discharge-related patterns.

### 3. Machine Learning

Machine learning models were developed in Python to explore two prediction tasks:

**Length of Stay (LOS) Prediction**

Estimate patient Length of Stay using available patient and hospital case information.

**Revenue Prediction**

Estimate revenue using available hospital case features.

Three regression algorithms were compared:

- Linear Regression
- Decision Tree Regressor
- Random Forest Regressor

The models were evaluated using:

| Metric | Purpose |
|---|---|
| MAE | Measures the average absolute prediction error. |
| RMSE | Measures prediction error while penalizing larger errors more heavily. |
| R² | Measures how well the model explains variation in the target variable. |

### 4. Machine Learning Dashboard

Power BI was used to visualize model evaluation results and compare actual values with model predictions.

The machine learning visuals include:
- Model performance comparison.
- R² score comparison.
- MAE and RMSE comparisons.
- Actual versus predicted revenue.
- Actual versus predicted Length of Stay.

### 5. Exporting Model Results

Python and Pandas were used to export the model results into CSV files for visualization and further analysis.

Expected output files:

- `revenue_predictions.csv` — Actual and predicted revenue values for the three models.
- `los_predictions.csv` — Actual and predicted Length of Stay values for the three models.
- `model_metrics.csv` — Model evaluation metrics for LOS and revenue.

## Key Analytical Areas

- Revenue distribution across payers and specialties.
- Differences between medical and surgical cases.
- Relationship between severity and Length of Stay.
- Operational patterns across patient and case categories.
- Comparison of regression models for LOS and revenue prediction.


## Power BI Dashboard

<img width="766" height="428" alt="Screenshot (566)" src="https://github.com/user-attachments/assets/4ef3e0ca-7ae9-4295-a8cf-35d5267996d7" />
<img width="760" height="429" alt="Screenshot (567)" src="https://github.com/user-attachments/assets/767f5d2b-85d0-495d-8939-1fc25aa88f68" />
<img width="761" height="428" alt="Screenshot (568)" src="https://github.com/user-attachments/assets/6bcb157b-e409-4b43-80fb-c74643ef9914" />
<img width="755" height="427" alt="Screenshot (569)" src="https://github.com/user-attachments/assets/04084f61-f72b-4b20-93d6-c90f15eeb587" />
<img width="750" height="423" alt="Screenshot (570)" src="https://github.com/user-attachments/assets/4f209c8b-0849-40b7-ab96-abadfef4d74a" />


## Repository Structure

```text
Hospital-Operations-Revenue-Analytics/
├── README.md
├── healthcare_analysis.sql
├── healthcare_ml.ipynb
├── hospitalcare.pbix
├── dummy_hospital_generated.csv
├── revenue_predictions.csv
├── los_predictions.csv
└── model_metrics.csv
```

## Files Overview

- `healthcare_analysis.sql` — SQL data cleaning and hospital analytics.
- `healthcare_ml.ipynb` — Python preprocessing, machine learning, and model evaluation.
- `hospitalcare.pbix` — Power BI dashboards for hospital operations and ML results.
- `dummy_hospital_generated.csv` — Generated hospital dataset used for analysis.
- `revenue_predictions.csv` — Actual and predicted revenue values.
- `los_predictions.csv` — Actual and predicted Length of Stay values.
- `model_metrics.csv` — MAE, RMSE, and R² results for the trained models.

## How to Explore the Project

1. Review the SQL scripts to understand the data preparation and analytical queries.
2. Open the Python notebook to explore preprocessing, model training, and evaluation.
3. Open the Power BI report to interact with the hospital analytics and machine learning dashboards.
4. Review the exported CSV files to inspect model predictions and evaluation metrics.

## Limitations

- The current dataset is a generated sample and may not represent real-world hospital populations or financial outcomes.
- Model performance depends on the available data, feature quality, and preprocessing choices.
- Predictions are exploratory and should not be treated as clinically validated forecasts or definitive financial estimates.
- Results on a small sample may not generalize to other hospitals or larger datasets.

## Future Improvements

- Validate the analysis on larger, more representative datasets.
- Improve model evaluation and investigate generalization using cross-validation.
- Investigate prediction errors and potential sources of data leakage.
- Improve dashboard usability and reporting.
- Explore additional operational forecasting and analytics use cases.

## Disclaimer

This project is intended for educational and portfolio purposes. The dataset is generated, and the analyses and predictions are not intended for clinical decision-making or real-world financial planning.

## Interactive HospitalIQ Website

Explore the interactive hospital operations and revenue analytics dashboard built using Python, Pandas, and Streamlit.

**Live Website:** https://hospital-operations-revenue-analytics-8lyuhdpkot4ry3bo2ws7sd.streamlit.app/

**Features**
- Interactive filters for month, specialty, and case type
- Key performance indicators (KPIs) for cases and revenue
- Revenue analysis by specialty
- Filtered hospital dataset preview
- Download filtered data as a CSV file
