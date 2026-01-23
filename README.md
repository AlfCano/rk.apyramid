# rk.apyramid: Population Pyramids for RKWard

![Version](https://img.shields.io/badge/Version-0.1.0-blue.svg)
![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
![RKWard](https://img.shields.io/badge/Platform-RKWard-green)
[![R Linter](https://github.com/AlfCano/rk.apyramid/actions/workflows/lintr.yml/badge.svg)](https://github.com/AlfCano/rk.apyramid/actions/workflows/lintr.yml)

**rk.apyramid** provides a graphical interface for the `{apyramid}` package within RKWard. It allows users to create publication-quality population pyramids from both standard data frames and complex survey design objects (`svydesign`) with minimal effort.

## 🚀 What's New in Version 0.1.0

This is the initial release of the plugin, offering a complete solution for demographic visualization.

### Key Highlights
*   **Survey Support:** Native support for weighted survey data. The plugin automatically handles the complex calculations required to visualize weighted counts or proportions correctly.
*   **Smart Variable Processing:** You don't need to pre-process your data. The plugin can automatically:
    *   **Bin numeric age variables** (e.g., transform raw age 0-100 into 5-year groups).
    *   **Convert variables to factors** on the fly.
*   **Flexible Splitting:** Unlike many pyramid functions, this supports **non-binary** split variables (e.g., comparing 3+ regions or gender categories).

### 🌍 Internationalization
The interface is fully localized in:
*   🇺🇸 English (Default)
*   🇪🇸 Spanish (`es`)
*   🇫🇷 French (`fr`)
*   🇩🇪 German (`de`)
*   🇧🇷 Portuguese (Brazil) (`pt_BR`)

## ✨ Features

### Data Handling
*   **Dual Input Mode:** Works seamlessly with `data.frame` (unweighted) and `survey.design` (weighted) objects.
*   **Variable Transformation:** Built-in options to `cut()` numeric age variables into custom bin widths (e.g., 5 years, 10 years) directly within the plotting dialog.

### Visualization Options
*   **Proportions vs. Counts:** Toggle between showing raw population numbers or percentage distributions.
*   **Midpoint Lines:** Optionally display lines indicating the midpoint of the age groups.
*   **Stacked Groups:** Support for a secondary grouping variable via the `stack_by` argument.

### Customization & Theming
*   **Theme Engine:** Full control over the `ggplot2` theme, including a global **Base Font Size** scaler to ensure text is readable at high resolutions.
*   **Colors:** Integrated palette selector including **Viridis** (Magma, Inferno, Plasma, Cividis) and **ColorBrewer** (Set1, Dark2, Paired, etc.).
*   **Labels:** Extensive labeling options for Title, Subtitle, Caption, and Axes, with automatic text wrapping for long legend titles.

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

Once installed, the plugin can be found in the **Survey** menu:

**`Survey` -> `Graphs` -> `apyramid` -> `Age Pyramid`**

1.  Select your data object (Dataframe or Survey Design).
2.  Select the **Age** variable and the **Split** variable (e.g., Sex).
3.  (Optional) If your Age variable is numeric, select "Bin Numeric Variable" in the frame below.
4.  Customize colors and themes in the tabs.
5.  Click **Submit**.

## 🛠️ Dependencies

This plugin relies on the following R packages:
*   `apyramid` (Core logic)
*   `ggplot2` (Plotting engine)
*   `survey` (For survey object handling)
*   `rkwarddev` (Plugin generation)

## ✍️ Author & License

*   **Author:** Alfonso Cano (<alfonso.cano@correo.buap.mx>)
*   **Assisted by:** Gemini, a large language model from Google.
*   **License:** GPL (>= 3)
