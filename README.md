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

The `/python` folder contains Jupyter notebooks for data processing and analytics, including:

- **DataCleaning.ipynb**
  Performs comprehensive cleaning and preprocessing of the raw Superstore dataset, including handling missing values, standardizing column names, parsing dates, and generating an analysis-ready clean dataset (`SuperstoreCleanData.csv`).

- **RFMDataframe.ipynb**
  Implements Recency, Frequency, Monetary (RFM) calculation and scoring for customer segmentation.
  Produces customer segments like "Champion," "Loyal," "At Risk," and "Regular," outputting an enriched dataset (`SuperstoreCleanDataWithSegment.csv`) used across analytics and dashboards.

- **EDA.ipynb**
  Contains exploratory data analysis scripts and visualizations: distribution plots, trend analysis, correlation matrices, and outlier detection to understand data characteristics and surface insights.

- **CustomerProductAnalysis.ipynb**
  Provides deeper analysis of customer segments and product performance, including top/bottom product identification, product profitability, ABC classification, and segment-wise revenue insights.
  Includes visualizations with matplotlib and seaborn to highlight actionable business findings.

These notebooks together form the end-to-end data processing, analytics, and insight generation foundation that feeds your SQL scripts, Excel reports, and Power BI dashboards.


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
