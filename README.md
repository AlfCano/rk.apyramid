# rk.apyramid: High-Impact Age Pyramids for RKWard

![Version](https://img.shields.io/badge/Version-0.1.2-blue.svg)
![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
![RKWard](https://img.shields.io/badge/Platform-RKWard-green)
[![R Linter](https://github.com/AlfCano/rk.apyramid/actions/workflows/lintr.yml/badge.svg)](https://github.com/AlfCano/rk.apyramid/actions/workflows/lintr.yml)

**rk.apyramid** provides a high-performance graphical interface for the `{apyramid}` package within RKWard, enhanced with Cole Nussbaumer Knaflic's *"Storytelling with Data" (SWD)* principles. It allows users to create publication-quality age pyramids from standard data frames, complex survey objects (`survey`), and `srvyr` (`tbl_svy`) objects with instant execution even on large datasets.

## 🚀 What's New in Version 0.1.2

*   **Dynamic Subsetting:** Added a **"Subset Expression"** field in the Variables tab. You can now filter your data (e.g., `region == 'North'` or `year == 2025`) directly within the plugin dialog. This is applied dynamically before plotting, saving you from creating multiple temporary filtered objects in your workspace.

## What's New in Version 0.1.1

This release focused on performance, professional aesthetics, and robust handling of weighted survey data.

*   **High-Speed Survey Engine:** Re-engineered to use `survey::svytable` for internal aggregation. This ensures near-instant plot generation for large-scale microdata (like ENOE).
*   **srvyr Support:** Native support for `srvyr` objects. The plugin automatically detects `tbl_svy` classes and handles weighted estimation seamlessly.
*   **SWD Aesthetic Standards:**
    *   **Horizontal Y-Axis Titles:** Positioned at the top-left to reduce reader head-tilt.
    *   **Capped Axes:** Uses the `lemon` package to clip axis lines exactly to the data range.
    *   **Absolute Value Labels:** Fixed the "negative sign" artifact; labels now show absolute positive values/percentages on both sides.
*   **Smart Units:** Automatically simplifies large population numbers (e.g., `6,000,000` -> `6M`) using the `scales` package.
*   **Lonely PSU Fix:** Added a toggle to automatically apply `options(survey.lonely.psu="adjust")`.

### 🌍 Internationalization
The interface is fully localized in:
*   🇺🇸 English (Default)
*   🇪🇸 Spanish (`es`)
*   🇫🇷 French (`fr`)
*   🇩🇪 German (`de`)
*   🇧🇷 Portuguese (Brazil) (`pt_BR`)

## ✨ Features

### Data Handling
*   **Triple Input Mode:** Works seamlessly with `data.frame`, `survey.design`, and `srvyr` objects.
*   **On-the-fly Binning:** Automatically `cut()` numeric age variables into custom intervals (e.g., 5-year cohorts) directly within the dialog.
*   **Pre-processing Filter:** Optional R expression to subset data before aggregation.

### Visualization & Layout
*   **Stacked Pyramids:** Supports secondary grouping (e.g., Type of Employment) within the age bars.
*   **Proportions vs. Counts:** Toggle between distribution percentages or raw weighted totals.
*   **Legend Control:** Precision side-by-side wrapping for both Legend Titles and individual labels to ensure the legend fits the plot margin.

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
2.  (Optional) Enter a **Subset Expression** to filter specific populations.
3.  Select the **Age** variable and the **Split** variable (e.g., Sex).
4.  Choose **Age Variable Processing** (Binning is recommended for raw numeric age).
5.  Configure **Highlighting** and **Theme** options in the respective tabs.
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
