# Nashville Housing Data Cleaning Project

## Project Overview
This project involves a comprehensive data cleaning process of a Nashville Housing dataset using **MySQL**. The goal was to transform raw, messy data into a clean, structured format suitable for analysis and visualization.

## Technical Skills Used
- **SQL Functions:** Self-Joins, CTEs, Window Functions (`ROW_NUMBER`), String Manipulation (`SUBSTRING_INDEX`, `LOCATE`).
- **Data Architecture:** Schema optimization and "Gold Table" creation.
- **Environment:** MySQL Workbench.

## Cleaning Steps
1. **Standardize Date Format:** Converted text strings to proper SQL Date format.
2. **Populate Property Address:** Used Self-Joins to fill NULL values based on ParcelIDs.
3. **Break Out Addresses:** Split Address, City, and State into individual columns.
4. **Remove Duplicates:** Used CTEs and Window Functions to identify and delete redundant rows.
5. **Drop Unused Columns:** Streamlined the table for reporting.