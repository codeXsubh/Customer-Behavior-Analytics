# Customer Behavioral Analytics

SQL + Python analytics project to study customer payment behavior, including retention patterns, delinquency risk, and monthly churn trends.

---

## 🧠 What this project does

- Analyzes customer payments using SQL and Python  
- Tracks retention using cohort analysis  
- Identifies delinquency based on payment delays  
- Measures month-to-month churn  
- Visualizes trends using Python  

---

## 🚀 Quick Start

```bash
python3 -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt

python scripts/generate_sample_data.py
python src/run_analysis.py

📊 Outputs

Generated in outputs/:
	•	cohort.csv → retention analysis
	•	risk.csv → delinquency insights
	•	churn.csv → monthly churn
	•	churn.png → churn trend chart
	•	metrics.txt → correlation summary

    
📁 Project Structure

    ├── data/                 # input datasets
├── outputs/              # results (CSV + charts)
├── scripts/              # data generation
├── sql/                  # SQL queries
├── src/                  # analysis script
├── requirements.txt
└── README.md