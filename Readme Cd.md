<div align="center">
  <img src="https://github.com/satyam250605/FMCG-Retail-Promotional-Analysis/blob/69e50c8cbf0afeb6cebd4349c5840f33018ccd27/Gemini_Generated_Image_vukcgxvukcgxvukc.png" alt="AtliQ Mart Logo" width="220"/>
  
  # 📊 AtliQ Mart Promotional Analysis – FMCG Sales Insights
  
  *Analyzing festive promotional trends and retail performance to optimize sales strategy and promotional ROI.*
</div>

---

## 📌 Table of Contents
- [Client Background & Project Overview](#client-background--project-overview)
- [KPIs & Metrics Evaluation](#data-structure--methodology)
- [Executive Summary](#executive-summary)
- [Insights Deep-Dive](#insights-deep-dive)
  - [1. The "25% OFF" Profitability Drain](#1-the-25-off-profitability-drain)
  - [2. Value-Added Promos: BOGOF & Cashback](#2-value-added-promos-bogof--cashback)
  - [3. Store & City-Level Performance](#3-store--city-level-performance)
- [Strategic Recommendations](#strategic-recommendations)
---

##  Client Background & Project Overview

**AtliQ Mart** is a retail giant with over 50 supermarkets in the southern region of India. Following massive promotional events during **Diwali 2023** and **Sankranti 2024**, an in-depth analysis was conducted to evaluate campaign effectiveness. 

This project goes beyond simple sales volume to evaluate the true profitability of different promotional strategies. By segmenting data by promo type, category, and geographical performance, this analysis provides actionable insights to help the sales leadership team distinguish high-performing promotions from profit-draining ones.

---

##  KPIs & Metrics Evaluation
The analysis was conducted using SQL (`FMCG-Retail-Promotional_Campaign-Analysis.sql`) to extract, aggregate, and analyze data from the `retail_events_db`. 

**Key Metrics Analyzed:**
* **Incremental Revenue (IR):** The true revenue lift generated directly by the promotion.
* **Incremental Sold Quantity (ISQ):** The lift in physical units moved.
* **Promo Group Categorization:** Segmenting promotions into **Discount-Based** (e.g., 25% OFF, 33% OFF, etc.) vs. **Value-Added** (e.g., BOGOF, 500 Cashback).
---

##  Data Dictionary 
The `retail_events_db` consists of four main tables:

* `fact_events`: The central fact table recording every sales event and promotional application.
* `dim_products`: Contains metadata for all AtliQ branded products.
* `dim_stores`: Contains geographical information for the retail locations.
* `dim_campaigns`: Contains the details of the promotional campaigns.
  
##  Executive Summary

While the Diwali and Sankranti campaigns successfully drove sheer volume, our analysis reveals a stark contrast in promotional profitability. 

**Value-added promotions**—specifically **500 Cashback** and **BOGOF (Buy One Get One Free)**—were the primary engines of Incremental Revenue (IR). Customers perceived higher value in "getting more" or "getting money back." Conversely, direct **Discount-Based promotions**, most notably the **25% OFF** campaigns, significantly underperformed. Despite moving inventory, the 25% OFF structure actively eroded profit margins, resulting in the most substantial financial losses across multiple key categories.

---

##  Insights Deep-Dive

![Image alt](https://github.com/satyam250605/FMCG-Retail-Promotional-Analysis/blob/b77c5e840ef5112d0f411f5ae40494931c6376ca/promo_type_overview.png)

### 1. The "25% OFF" Profitability Drain
Through a detailed category-wise analysis, it became evident that the `25% OFF` discount structure is a liability. While it successfully reduced stock, the revenue generated did not offset the massive base price reduction. 
* **Key Finding:** The "Grocery & Staples" category saw the heaviest losses under this promo type, dropping by -$0.77M.

![Image alt](https://github.com/satyam250605/FMCG-Retail-Promotional-Analysis/blob/6f5b1828715880aaca7cfce9f6b7ded36ce8d9f8/25%25_promo_type_category_losses.png)

### 2. Value-Added Promos: BOGOF & 500 Cashback
When comparing promo groups, Value-Added promos vastly outperformed straight discounts. 
* **BOGOF:** Highly effective for clearing out high-volume FMCG staples, driving an Incremental Revenue lift of 17%.
* **500 Cashback:** Highly effective for higher-ticket items, yielding a strong return on investment without degrading the perceived brand value of the product.

### 3. Store & City-Level Performance
Promotional success was not uniform across all geographies. Analyzing the highly successful `500 Cashback` promo revealed that specific markets over-indexed in engagement. 
* **Top 3 Cities by IR (500 Cashback):** Bengaluru, Chennai, and Hyderabad accounted for 28% of the total incremental revenue for this promo type.
* **Performance across promo types:** Stores in Benguluru, Chennai, and Hyderabad led overall performance accounting to 59% contribution to total Incremental Revenue generated in every cities, largely driven by exceptional sales in the Combo category.

![Image alt](https://github.com/satyam250605/FMCG-Retail-Promotional-Analysis/blob/b77c5e840ef5112d0f411f5ae40494931c6376ca/Incremental%20Revenue%20(In%20Million)%20by%20city.png)

![Image alt](https://github.com/satyam250605/FMCG-Retail-Promotional-Analysis/blob/b77c5e840ef5112d0f411f5ae40494931c6376ca/Percentage%20Contribution%20by%20City.png)

---

##  Strategic Recommendations

1.  **Phase Out or Restructure "25% OFF":** Immediately halt the 25% OFF strategy in high-loss categories. If discounts must be used, test smaller percentages (e.g., 10-15%) or shift these products to a bundle strategy.
2.  **Scale Value-Added Offers:** Reallocate the marketing budget toward BOGOF and 500 Cashback promotions, as data proves they consistently drive higher, profitable Incremental Revenue.
3.  **Geo-Targeted Campaigns:** Double down on 500 Cashback marketing spend in our Top 3 performing cities (Bengaluru, Chennai, and Hyderabad). Investigate the friction points in bottom-performing stores to understand if the issue is low foot traffic, poor inventory mix, or lack of promo visibility.

---



---

## 👤 Author & Contact
**Satyam Tiwari** Data Analyst  
 Email: satyam227025@gmail.com  
 Contact: +91 9054524495
