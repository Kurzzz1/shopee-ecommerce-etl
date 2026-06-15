This project demonstrates how I used Power Query to transform raw, web-scraped product data from Shopee into a structured and analysis-ready dataset.

I developed a systematic cleaning and transformation procedure to standardize text fields, organize location data, and generate pricing-related indicators because web-scraped data is typically noisy and inconsistent. This made it possible to use the dataset to find trends in market behavior, pricing, and promotions.

## Project Structure ## 
The project is organized around a simple ETL workflow implemented in Power Query (M Language). The Excel file contains both raw and processed datasets, along with the transformation logic used to build the final output.

1. Scrape Sheet
 - Contains the raw, unprocessed web-scraped dataset exactly as extracted from Shopee listings, including noisy text fields and inconsistent formatting.
2. ETL Sheet
- The cleaned and transformed dataset generated through Power Query, containing structured and analysis-ready features.
3. transformation_script.pq
- The full M-code pipeline documenting each step of the data cleaning, transformation, and feature engineering process.

## Data Engineering (ETL) Workflow ## 

Data Cleaning & Standardization

Raw scraped data was cleaned and normalized to ensure consistency and analytical usability.
 * Converted unstructured text fields (e.g., "1.2k sold") into numeric values (e.g., 1,200)
 * Handled missing, blank, and inconsistent values in pricing and delivery-related fields
 * Standardized column formats for downstream analysis

Organizing the Details
 * Transformed unstructured text fields into structured analytical variables.

Parsed raw location strings into:
 * City
 * Region
 * Country
  
Converted delivery time ranges (e.g., "7–30 Days") into numeric features:
 * Minimum Delivery Period
 * Maximum Delivery Period

Calculating New Metrics
* Original Price Calculation: Used the final price and the discount percentage to reverse-calculate the approximate original price of the headphones.
* Grouping: Grouped the highly varied discount rates and shop offers into clear, simple categories (like grouping offers into Flash Sale or Cashback).

## Business Value ## 
This project demonstrates the ability to transform messy, real-world web-scraped data into a structured and analysis-ready dataset. Through data cleaning, text parsing, and feature engineering, the resulting dataset becomes suitable for downstream applications such as dashboards, exploratory analysis, and statistical models for studying pricing strategies and competitive market behavior.

