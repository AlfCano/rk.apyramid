# rk.apyramid: High-Impact Age Pyramids for RKWard

![Version](https://img.shields.io/badge/Version-0.1.3-blue.svg)
![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
![RKWard](https://img.shields.io/badge/Platform-RKWard-green)
[![R Linter](https://github.com/AlfCano/rk.apyramid/actions/workflows/lintr.yml/badge.svg)](https://github.com/AlfCano/rk.apyramid/actions/workflows/lintr.yml)

**rk.apyramid** provides a high-performance graphical interface for the `{apyramid}` package within RKWard, enhanced with Cole Nussbaumer Knaflic's *"Storytelling with Data" (SWD)* principles. It allows users to create publication-quality age pyramids from standard data frames, complex survey objects (`survey`), and `srvyr` (`tbl_svy`) objects with instant execution even on large datasets.

## 🚀 What's New in Version 0.1.3

*   **Symmetric Axes (Centering Fix):** Added a **"Center Pyramid"** option. By default, charts now force the axes to be symmetric based on the largest group. This prevents label truncation when comparing highly unbalanced populations (e.g., a male-dominated industry vs. a small female workforce).
*   **Cleaner Subsets:**
    *   **Start Bins at:** You can now define the starting age for automatic binning (e.g., start at 15). This eliminates empty bars at the bottom when plotting labor force data (15+).
    *   **Drop Unused Levels:** Automatically removes empty age factor levels, ensuring the chart only displays relevant categories.

## What's New in Version 0.1.2

*   **Dynamic Subsetting:** Added a **"Subset Expression"** field in the Variables tab. You can now filter your data (e.g., `region == 'North'` or `age >= 15`) directly within the plugin dialog before plotting.

## Features

### Data Handling
*   **Triple Input Mode:** Works seamlessly with `data.frame`, `survey.design`, and `srvyr` objects.
*   **Smart Binning:** Automatically `cut()` numeric age variables into custom intervals (e.g., 5-year cohorts).
    *   *New:* Define custom start points and remove empty levels on the fly.
*   **Pre-processing Filter:** Optional R expression to subset data before aggregation.

### Visualization & Layout
*   **Stacked Pyramids:** Supports secondary grouping (e.g., Type of Employment) within the age bars.
*   **Symmetric Layouts:** Forces the "zero" line to stay centered even if one side is significantly larger than the other.
*   **Proportions vs. Counts:** Toggle between distribution percentages or raw weighted totals.
*   **Legend Control:** Precision side-by-side wrapping for both Legend Titles and individual labels to ensure the legend fits the plot margin.
*   **SWD Aesthetics:** Horizontal Y-axis titles, capped axes (`lemon`), and smart unit formatting (e.g., `6M` instead of `6,000,000`).

## 📦 Installation

This plugin is not yet on CRAN. To install it, use the `remotes` or `devtools` package in RKWard.

1.  **Open RKWard**.
2.  **Run the following command** in the R Console:

    ```R
    # If you don't have devtools installed:
    # install.packages("devtools")
    
    local({
      require(devtools)
      install_github("AlfCano/rk.apyramid", force = TRUE)
    })
    ```
3.  **Restart RKWard** to load the new menu entries.

## 💻 Usage

Once installed, the plugin is organized under:

**`Survey` -> `Graphs` -> `Age Pyramid`**

1.  Select your data object (Dataframe, Survey, or srvyr).
2.  (Optional) Enter a **Subset Expression** (e.g., `age >= 15`).
3.  Select the **Age** variable and the **Split** variable (e.g., Sex).
4.  Configure **Age Processing**:
    *   Set **Bin Width** (e.g., 5 years).
    *   Set **Start Bins at** (e.g., 15) to match your subset.
5.  Configure **Settings**: Check "Center Pyramid" to ensure labels aren't cut off.
6.  Click **Submit**.

## 🛠️ Dependencies

This plugin relies on the following R packages:
*   `apyramid`, `ggplot2`, `survey`, `srvyr`
*   `lemon` (Capped axes)
*   `scales` (Label formatting)
*   `dplyr`, `stringr`, `RColorBrewer`

#### Troubleshooting: Errors installing `devtools` or missing binary dependencies (Windows)

If you encounter errors mentioning "non-zero exit status" or requirements for compilation when installing packages, it is likely because the R version bundled with RKWard is older than the current CRAN standard.

**Workaround:**
1.  Download and install the latest version of R from [CRAN](https://cloud.r-project.org/).
2.  Open RKWard and go to the **Settings** menu.
3.  Run the **"Installation Checker"**.
4.  Point RKWard to the newly installed R version.

## ✍️ Author & License

*   **Author:** Alfonso Cano (<alfonso.cano@correo.buap.mx>)
*   **Assisted by:** Gemini, a large language model from Google.
*   **License:** GPL (>= 3)
