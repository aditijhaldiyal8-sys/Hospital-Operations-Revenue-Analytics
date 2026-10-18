
import os
import pandas as pd
import streamlit as st

# 1. Website settings
st.set_page_config(
    page_title="HospitalIQ",
    page_icon="🩺",
    layout="wide"
)

# 2. Website heading
st.title("HospitalIQ")
st.write("Interactive Hospital Operations & Revenue Analytics Dashboard")

# 3. Find the project folder and CSV file

from pathlib import Path

project_root = Path(__file__).resolve().parent.parent
csv_path = project_root / "dummy_hospital_generated.csv"
st.write("CSV path being checked:", str(csv_path))
st.write("Does the CSV exist?", csv_path.exists())


# 4. Load the hospital dataset
try:
    df = pd.read_csv(csv_path)
except FileNotFoundError:
    st.error("CSV file not found. Please check its location.")
    st.stop()

# 5. Clean column names
df.columns = df.columns.str.strip()

# 6. Create sidebar filters
st.sidebar.header("Filters")

month_options = sorted(df["Month"].dropna().unique().tolist())
selected_months = st.sidebar.multiselect(
    "Select Month",
    month_options,
    default=month_options
)

specialty_options = sorted(df["Specialty"].dropna().unique().tolist())
selected_specialties = st.sidebar.multiselect(
    "Select Specialty",
    specialty_options,
    default=specialty_options
)

case_type_options = sorted(df["Case type"].dropna().unique().tolist())
selected_case_types = st.sidebar.multiselect(
    "Select Case Type",
    case_type_options,
    default=case_type_options
)

# 7. Filter the dataset
filtered_df = df[
    df["Month"].isin(selected_months)
    & df["Specialty"].isin(selected_specialties)
    & df["Case type"].isin(selected_case_types)
]

# 8. Calculate dashboard KPIs
total_cases = len(filtered_df)

total_revenue = (
    pd.to_numeric(filtered_df["Revenue"], errors="coerce")
    .sum()
)

average_revenue = (
    pd.to_numeric(filtered_df["Revenue"], errors="coerce")
    .mean()
)

average_los = (
    pd.to_numeric(filtered_df["LOS"], errors="coerce")
    .mean()
)

# 9. Display KPI cards
col1, col2, col3, col4 = st.columns(4)

col1.metric("Total Cases", f"{total_cases:,}")
col2.metric("Total Revenue", f"{total_revenue:,.2f}")
col3.metric(
    "Average Revenue",
    f"{average_revenue:,.2f}" if pd.notna(average_revenue) else "N/A"
)
col4.metric(
    "Average Length of Stay",
    f"{average_los:.2f}" if pd.notna(average_los) else "N/A"
)

# 10. Revenue chart by specialty
st.subheader("Revenue by Specialty")

chart_df = filtered_df.copy()
chart_df["Revenue"] = pd.to_numeric(
    chart_df["Revenue"], errors="coerce"
)

revenue_by_specialty = (
    chart_df.groupby("Specialty")["Revenue"]
    .sum()
    .sort_values(ascending=False)
)

st.bar_chart(revenue_by_specialty)

# 11. Display the filtered dataset
st.subheader("Hospital Dataset")
st.write(f"Showing {len(filtered_df):,} cases")

st.dataframe(filtered_df, use_container_width=True)

# 12. Download filtered data
csv_data = filtered_df.to_csv(index=False).encode("utf-8")

st.download_button(
    label="Download Filtered Data",
    data=csv_data,
    file_name="hospital_filtered_data.csv",
    mime="text/csv"
)

