# BIOS 731: Advanced Statistical Computing - Simulation Project

## Project Overview
This project evaluates the performance of three statistical inference methods—**Wald**, **Bootstrap-Percentile**, and **Bootstrap-t**—in the context of linear regression. The simulation explores how sample size ($n$) and error distributions (Normal vs. Heavy-tailed) affect estimation bias, standard error volatility, and confidence interval coverage.

## Project Directory Structure

### 1. `source/` Directory
Contains the core R scripts for the simulation pipeline:
* **`01_simulate_data.R`**: Functions for generating synthetic data with varying $n$ and error types.
* **`02_apply_methods.R`**: Implementation of the three CI construction methods.
* **`aggregate_results.R`**: Functions to calculate summary metrics (Bias, Coverage, SE).

### 2. `results/` Directory
Stores simulation outputs and analytical plots:

### 3. `simulations/` Directory
Contains the core R scripts for the simulation pipeline:
* **`run_simulations_parallel_t.R`**: Code for evaluation of **Bootstrap-t**.
* **`run_simulations_parallel_precentile.R`**: Code for evaluation of **Bootstrap-Percentile**.
* **`run_simulations_parallel_wald.R`**: Code for evaluation of **Wald**.

### 4. `analysis/` Directory
Contains the .Rmd file for generating the report.
* **`final_report.Rmd`**: .Rmd file for summary of the results.

---

## Technical Implementation
* **Parallelization:** The simulation utilizes `foreach` and `doParallel` to distribute scenarios across multiple CPU cores.
* **Reproducibility:** Seed management is implemented at both the scenario and replicate levels to ensure consistent results.

## How to Run
1. Open the `.Rproj` file in RStudio.
2. Run `run_simulations_parallel_t.R` to execute the full suite of scenarios for **Bootstrap-t**.
   Run `run_simulations_parallel_percentile.R` to execute the full suite of scenarios for **Bootstrap-Percentile**.
   Run `run_simulations_parallel_wald.R` to execute the full suite of scenarios for **Wald**.
3. Run `final_report.Rmd` to get the summary of results.