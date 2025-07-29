# Superstore Sales Analytics Portfolio Project

## Overview
End-to-end sales analytics for the Superstore dataset, using SQL, Python, Excel, and Power BI.

## Project Structure
- **SQL**: Setup, profiling, KPI & segmentation analysis, BI data views.
- **Python**: Data cleaning (csv → clean csv), EDA, forecasting examples in Jupyter notebooks.
- **Excel**: Pivot tables, summary dashboards, customer segment charts.
- **Power BI**: Interactive dashboards for business users/executives.
- **Documentation**: Data dictionary, business questions addressed.

## Python

The `/python` folder contains Jupyter notebooks for data processing:

- **DataCleaning.ipynb**:
  Performs comprehensive cleaning and preprocessing of the raw Superstore dataset. This includes handling missing values, standardizing column names, converting date fields, and generating a clean, analysis-ready dataset (`SuperstoreCleanData.csv`) used throughout the project.

- **Customer Segmentation (RFM)**:
  Implements Recency, Frequency, Monetary (RFM) analysis to score customers and assign segments such as "Champion," "Loyal," "At Risk," and "Regular." This segmentation drives targeted customer analytics and is integrated into Power BI dashboards.


## SQL Scripts

The `/sql` folder contains:
- `01_database_setup.sql`: Creates schema, loads data
- `02_data_exploration.sql`: Data profiling and quality checks
- `03_business_analysis.sql` & `04_advanced_analytics.sql`: Metrics, RFM, ABC, cohort and time series analysis
- `05_powerbi_data_prep.sql`: Creates views for Power BI dashboarding

## Power BI Dashboards

- `ExecutiveDashboard.pbix`: High-level KPIs and summary visuals
- `SalesPerformanceDeepDive.pbix`: Detailed sales trends by product, region, segment

Both connect to your cleaned sales data and/or SQL-prepared views for flexible, business-ready analysis.

## How to Use
1. Place raw Kaggle CSV into `data/SuperstoreData.csv`.
2. Run `python/DataCleaning.ipynb` to produce cleaned data.
3. Execute `.sql` scripts sequentially for database setup and analysis.
4. Use `SuperstoreCleanData.csv` or the prepared data views as sources in Excel and Power BI.

## Tools Used so far
SQL (MySQL), Python (pandas), Power BI.

---
