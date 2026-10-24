import os
import pandas as pd
import streamlit as st
from pathlib import Path

# 1. Website settings
st.set_page_config(
    page_title="HospitalIQ",
    page_icon="🩺",
    layout="wide"
)

st.markdown(
    """
    <style>
    .stApp {
        background: #e6f4ff !important;
    }
    h1 {
        color: #ff0000 !important;
        font-size: 50px !important;
    }
    div[data-testid="stMetric"] {
    background-color: white;
    border: 1px solid #c5e1f5;
    padding: 16px 12px;
    border-radius: 12px;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.08);
    min-width: 0;
}

div[data-testid="stMetricValue"] {
    font-size: clamp(16px, 1.6vw, 28px) !important;
    white-space: normal !important;
    overflow-wrap: anywhere;
}


/* Sidebar background */
section[data-testid="stSidebar"] {
    background-color: #d9efff !important;
}

/* Sidebar headings */
section[data-testid="stSidebar"] h1,
section[data-testid="stSidebar"] h2,
section[data-testid="stSidebar"] h3 {
    color: #12345a !important;
}

/* Filter labels */
section[data-testid="stSidebar"] label {
    color: #23445f !important;
    font-weight: 600;
}
</style>
    """,
    unsafe_allow_html=True
)

# 2. Website heading
st.title("HospitalIQ")
st.write("Interactive Hospital Operations & Revenue Analytics Dashboard")

# 3. Find the project folder and CSV file
app_dir = Path(__file__).resolve().parent
csv_name = "dummy_hospital_generated.csv"

candidates = [
    app_dir / csv_name,
    app_dir.parent / csv_name,
]

csv_path = next((p for p in candidates if p.exists()), candidates[0])
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
# Gender filter
gender_options = sorted(df["Gender"].dropna().unique().tolist())

selected_genders = st.sidebar.multiselect(
    "Select Gender",
    gender_options,
    default=gender_options
)

# Severity filter
severity_options = sorted(df["Severity"].dropna().unique().tolist())

selected_severities = st.sidebar.multiselect(
    "Select Severity",
    severity_options,
    default=severity_options
)
# 7. Filter the dataset
filtered_df = df[
    df["Month"].isin(selected_months)
    & df["Specialty"].isin(selected_specialties)
    & df["Case type"].isin(selected_case_types)
    & df["Gender"].isin(selected_genders)
    & df["Severity"].isin(selected_severities)
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


# 10. Interactive chart
st.subheader("Explore Hospital Data")

chart_choice = st.selectbox(
    "Choose what you want to analyze",
    [
        "Revenue by Specialty",
        "Cases by Specialty",
        "Revenue by Case Type",
        "Cases by Gender",
        "Cases by Severity"
    ]
)

chart_df = filtered_df.copy()
chart_df["Revenue"] = pd.to_numeric(
    chart_df["Revenue"], errors="coerce"
)

if chart_choice == "Revenue by Specialty":
    chart_data = chart_df.groupby("Specialty")["Revenue"].sum()
    chart_data = chart_data.sort_values(ascending=False)
    st.bar_chart(chart_data)

elif chart_choice == "Cases by Specialty":
    chart_data = chart_df["Specialty"].value_counts()
    st.bar_chart(chart_data)

elif chart_choice == "Revenue by Case Type":
    chart_data = chart_df.groupby("Case type")["Revenue"].sum()
    st.bar_chart(chart_data)

elif chart_choice == "Cases by Gender":
    chart_data = chart_df["Gender"].value_counts()
    st.bar_chart(chart_data)

elif chart_choice == "Cases by Severity":
    chart_data = chart_df["Severity"].value_counts().sort_index()
    st.bar_chart(chart_data)



# 11. Search hospital cases
st.subheader("Search Hospital Cases")

search_term = st.text_input(
    "Search by Case Number",
    placeholder="Enter a case number..."
)

search_df = filtered_df.copy()

if search_term:
    search_df = search_df[
        search_df["Case_No"].astype(str).str.contains(
            search_term, case=False, na=False
        )
    ]

st.write(f"Showing {len(search_df):,} cases")

st.dataframe(search_df, use_container_width=True)


# 12. Download filtered data
csv_data = filtered_df.to_csv(index=False).encode("utf-8")

st.download_button(
    label="Download Filtered Data",
    data=csv_data,
    file_name="hospital_filtered_data.csv",
    mime="text/csv"
)


# --------------------------------------------------
# ML MODEL PERFORMANCE AND FINDINGS
# --------------------------------------------------

st.header("🤖 Machine Learning Findings")

st.write(
    "Comparison of Linear Regression, Decision Tree, "
    "and Random Forest models for Length of Stay and Revenue."
)

metrics_path = project_root / "outputs" / "model_metrics.csv"

if metrics_path.exists():
    metrics_df = pd.read_csv(metrics_path)

    # Best model for each prediction task, based on MAE
    los_results = metrics_df[metrics_df["Target"] == "LOS"]
    revenue_results = metrics_df[metrics_df["Target"] == "Revenue"]

    col1, col2 = st.columns(2)

    if not los_results.empty:
        best_los = los_results.loc[los_results["MAE"].idxmin()]

        col1.metric(
            "Best LOS Model (by MAE)",
            str(best_los["Model"]),
            f'MAE: {best_los["MAE"]:.3f} days'
        )

    if not revenue_results.empty:
        best_revenue = revenue_results.loc[
            revenue_results["MAE"].idxmin()
        ]

        col2.metric(
            "Best Revenue Model (by MAE)",
            str(best_revenue["Model"]),
            f'MAE: ₹{best_revenue["MAE"]:,.2f}'
        )

    # Model comparison charts
    st.subheader("Model Performance Comparison")

    task_choice = st.selectbox(
        "Choose prediction task",
        ["LOS", "Revenue"],
        key="ml_task_choice"
    )

    task_df = metrics_df[
        metrics_df["Target"] == task_choice
    ].copy()

    chart1, chart2 = st.columns(2)

    with chart1:
        st.subheader("Mean Absolute Error (MAE)")

        fig_mae = px.bar(
            task_df,
            x="Model",
            y="MAE",
            color="Model",
            title=f"{task_choice}: MAE Comparison"
        )

        st.plotly_chart(fig_mae, use_container_width=True)

    with chart2:
        st.subheader("R² Score")

        fig_r2 = px.bar(
            task_df,
            x="Model",
            y="R2",
            color="Model",
            title=f"{task_choice}: R² Comparison"
        )

        st.plotly_chart(fig_r2, use_container_width=True)

    st.subheader("Complete Model Metrics")

    st.dataframe(
        metrics_df.round(4),
        use_container_width=True,
        hide_index=True
    )

    st.caption(
        "These results are from the saved model evaluation file. "
        "They describe the evaluated dataset and do not guarantee "
        "the same performance on new hospital data."
    )

else:
    st.warning(
        f"Model metrics file not found at: {metrics_path}"
    )












