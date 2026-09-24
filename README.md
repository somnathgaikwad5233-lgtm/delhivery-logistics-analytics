# Delhivery Logistics Analytics

A logistics analytics project focused on delivery performance, route analysis, and actual vs estimated transit time using PostgreSQL and Power BI.

## Project Overview

This project analyzes Delhivery logistics data to understand delivery performance across different route types, source centers, destination centers, and routes.

The main focus is on comparing actual transit time with OSRM estimated transit time and identifying routes with higher time deviations.

## Tools & Technologies

- PostgreSQL
- SQL
- Power BI

## SQL Analysis

The SQL analysis includes:

- Dataset exploration
- Source and destination center analysis
- Route type analysis
- Unique trip analysis
- Actual vs OSRM estimated time comparison
- Time deviation analysis
- Deviation percentage analysis
- Route performance analysis
- NULL and duplicate checks
- CTE and window function analysis
- Source and destination city/state extraction

## Power BI Dashboard

The Power BI dashboard provides insights into:

- Logistics network overview
- Route performance
- Actual vs estimated transit time
- Delivery time deviation
- Source and destination analysis
- City and state level analysis

## Project Workflow

1. Loaded the logistics dataset into PostgreSQL
2. Performed data exploration and data quality checks
3. Analyzed routes, route types, and trip performance
4. Compared actual transit time with OSRM estimated time
5. Calculated time deviation and deviation percentage
6. Extracted source and destination city/state information
7. Connected the cleaned data to Power BI
8. Created interactive dashboards for logistics analysis

## Dashboard Preview

### Logistics Network Overview

![Delhivery Logistic Network Overview](Delhivery%20Logistic%20Network%20Overview.png)

### Time & Delay Analysis

![Delhivery Time & Delay Analysis](Delhivery%20Time%20%26%20Delay%20Analysis.png)

## Repository Contents

- `delhivery_analysis_github.sql` – PostgreSQL analysis queries
- `Delhivery Logistic Network Overview.png` – Power BI dashboard screenshot
- `Delhivery Time & Delay Analysis.png` – Power BI dashboard screenshot

## Key Analysis Areas

The project focuses on understanding delivery performance by comparing actual transit time with OSRM estimated time, analyzing route-level deviations, and examining source and destination locations.
