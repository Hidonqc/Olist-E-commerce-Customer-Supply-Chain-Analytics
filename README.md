# Olist-E-commerce-Customer-Supply-Chain-Analytics
TLDR: An end-to-end analysis of 90,000+ customers and transactions from Olist (Brazil). Python (Pandas, Scikit-learn) is used to clean complex data and build machine learning models that predict risk, T-SQL to mine customer lifetime value (RFM, CLV, Cohort), and Looker Studio to visualize business and supply chain performance.

Tech stack: Python (Pandas, NumPy, Scikit-learn) · T-SQL (Azure Data Studio) · Looker Studio

# 1. Overview

Scope: 90,000+ customers, order details, transaction volume, and logistics data.

Goals:
Segment customers, measure retention, and optimize marketing spend.

Evaluate supply chain performance and its impact on the customer lifecycle.

Build predictive models to identify customers at risk of churning and orders at risk of late delivery.

Methods:
Python (Pandas, NumPy) - Data preprocessing, cleaning, and standardization

Python (Scikit-learn)	- Training and evaluating machine learning models

T-SQL (Azure Data Studio) -	Business data mining and manipulation

Looker Studio	- Interactive dashboard

# 2. Technical Workflow
2.1 Data Preprocessing & EDA 

Handled missing values and removed outliers using a statistical method (IQR).

Feature engineering: DateTime parsing, geographic distance calculation, and encoding of categorical variables (One-Hot / Label Encoding) for ML models.

Feature scaling: Standardized skewed monetary values with StandardScaler / MinMaxScaler to improve algorithm convergence.

2.2 Customer & Supply Chain Analytics (T-SQL)

Built a custom RFM segmentation that addresses Olist's data skewness, then calculated CLV and a Cohort Retention matrix.

Measured Delivery Lead Time and Freight Cost Ratio.

2.3 Predictive Modeling & Evaluation (Python, Scikit-learn)

Models: Logistic Regression and Random Forest Classifier to predict customer churn and late delivery.

Evaluation metrics:

Optimized ROC-AUC and F1-Score to handle imbalanced data (97% of customers purchase only once).

Used Precision and Recall to balance correctly identifying at-risk customers against the cost of retention vouchers.

Extracted Feature Importance to identify the strongest drivers of each prediction.

# 3. Key Insights
The "One-Hit Wonder" trap and cohort cliff: 97% of customers buy only once (Frequency = 1), and retention falls below 1% right after the first month. Olist's funnel leaks at the retention stage.

Delivery performance is decisive: The models show that Delivery_Lead_Time and Freight_Value are the top predictors of whether a customer returns or leaves for good.

The "whale" segment: A small group of B2B / dropshipper buyers places 100–260 orders each and contributes a disproportionately large share of total CLV.

# 4. Recommendations

Operationalize the ML model
Score in-transit orders for late-delivery risk, and automatically trigger an apology SMS/email with a free-shipping code before the order is confirmed late.

Segment-based strategy
Offer time-limited "bridge vouchers" to the Potential segment to encourage a second purchase.
Move "whale" B2B customers into a Key Account Management (KAM) flow with volume-based discounts.

Supply chain optimization
Enforce strict SLAs, and lower the visibility ranking of sellers and carriers whose late-delivery rate exceeds a set threshold.

# 5. Key Learnings
Technical: Built a complete end-to-end pipeline, from preprocessing in Python, to business analysis in T-SQL, to visualization in Looker Studio.

Data science fundamentals: Applied Precision, Recall, and F1-Score in a real business context instead of relying on accuracy, which is misleading on imbalanced data.

Business acumen: Translated model outputs into concrete strategies to reduce churn and lower operating costs.

# 6. Next Steps
Apply hyperparameter tuning (GridSearch / RandomSearch) to improve model performance.

Replace rule-based SQL segmentation with K-Means clustering to automatically group customers by multi-dimensional behavior.

📎 Links
Dashboard: [(https://datastudio.google.com/reporting/f408c6d3-1730-4542-9465-dd18d9a06725)]

Dataset: Brazilian E-Commerce Public Dataset by Olist (Kaggle)

Author: Doan Quoc Huy · LinkedIn
