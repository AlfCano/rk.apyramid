local({
  # =========================================================================================
  # 1. Package Definition and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.08-1")

  plugin_name <- "rk.apyramid"
  plugin_ver <- "0.1.0"

  package_about <- rk.XML.about(
    name = plugin_name,
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "An RKWard plugin to create population pyramids from survey or dataframe objects using the 'apyramid' package. Supports automatic binning and factor conversion.",
      version = plugin_ver,
      date = format(Sys.Date(), "%Y-%m-%d"),
      url = "https://github.com/AlfCano/rk.apyramid",
      license = "GPL (>= 3)"
    )
  )

  # =========================================================================================
  # 2. JS Helpers
  # =========================================================================================
  js_helpers <- '
    function getColumnName(fullName) {
        if (!fullName) return "";
        var lastBracketPos = fullName.lastIndexOf("[[");
        if (lastBracketPos > -1) {
            var lastPart = fullName.substring(lastBracketPos);
            var match = lastPart.match(/\\[\\[\\"(.*?)\\"\\]\\]/);
            if (match) { return match[1]; }
        }
        if (fullName.indexOf("$") > -1) { return fullName.substring(fullName.lastIndexOf("$") + 1); }
        else { return fullName; }
    }
  '

  # =========================================================================================
  # 3. UI Resources
  # =========================================================================================

  # --- Labels Tab (Updated) ---
  labels_tab <- rk.XML.col(
    rk.XML.input(label = "Plot Title", id.name = "plot_title"),
    rk.XML.input(label = "Plot Subtitle", id.name = "plot_subtitle"),
    rk.XML.input(label = "X-axis Label (Count/Prop)", id.name = "plot_xlab"),
    rk.XML.input(label = "Y-axis Label (Age)", id.name = "plot_ylab"),
    rk.XML.input(label = "Legend Title", id.name = "plot_legend_title"),
    # NEW: Legend Title Wrapper
    rk.XML.spinbox(label = "Wrap Legend Title at (chars, 0 to disable)", id.name = "plot_leg_wrap", min = 0, max = 100, initial = 0),
    rk.XML.input(label = "Plot Caption", id.name = "plot_caption")
  )

  # --- Theme Tab (Updated Palettes) ---
  theme_tab <- rk.XML.col(
      rk.XML.spinbox(label="Base Font Size (pts)", id.name="theme_base_size", min=6, max=50, initial=16),

      rk.XML.frame(
          rk.XML.spinbox(label="Plot Title (Relative size)", id.name="rel_title", min=0.1, max=5, initial=1.2, real=TRUE),
          rk.XML.spinbox(label="Axis Labels (Relative size)", id.name="rel_axis_title", min=0.1, max=5, initial=0.9, real=TRUE),
          rk.XML.spinbox(label="Axis Ticks/Text (Relative size)", id.name="rel_axis_text", min=0.1, max=5, initial=0.9, real=TRUE),
          rk.XML.spinbox(label="Legend Text (Relative size)", id.name="rel_legend", min=0.1, max=5, initial=0.8, real=TRUE),
          label = "Fine Tune Element Sizes (Multiplier)"
      ),

      rk.XML.dropdown(label="Legend Position", id.name="theme_legend_pos", options=list("Bottom"=list(val="bottom", chk=TRUE), "Top"=list(val="top"), "Right"=list(val="right"), "Left"=list(val="left"), "None"=list(val="none"))),

      # Expanded Palettes
      rk.XML.dropdown(label="Color Palette", id.name="theme_palette", options=list(
          "Default (apyramid)"=list(val="default", chk=TRUE),
          "Viridis (Default)"=list(val="viridis"),
          "Viridis: Magma"=list(val="magma"),
          "Viridis: Inferno"=list(val="inferno"),
          "Viridis: Plasma"=list(val="plasma"),
          "Viridis: Cividis"=list(val="cividis"),
          "Brewer: Set1"=list(val="set1"),
          "Brewer: Set2"=list(val="set2"),
          "Brewer: Set3"=list(val="set3"),
          "Brewer: Dark2"=list(val="dark2"),
          "Brewer: Accent"=list(val="accent"),
          "Brewer: Paired"=list(val="paired"),
          "Brewer: Pastel1"=list(val="pastel1"),
          "Brewer: Pastel2"=list(val="pastel2"),
          "Grayscale"=list(val="grey")
      ))
  )

  # --- Device Tab ---
  device_tab <- rk.XML.col(
    rk.XML.dropdown(label = "Device type", id.name = "device_type", options = list("PNG" = list(val = "PNG", chk = TRUE), "SVG" = list(val = "SVG"), "JPG" = list(val = "JPG"))),
    rk.XML.spinbox(label = "Width (px)", id.name = "dev_width", min = 100, max = 4000, initial = 800),
    rk.XML.spinbox(label = "Height (px)", id.name = "dev_height", min = 100, max = 4000, initial = 600),
    rk.XML.spinbox(label = "Resolution (ppi)", id.name = "dev_res", min = 50, max = 600, initial = 150)
  )

  # =========================================================================================
  # 4. Main Component: Age Pyramid
  # =========================================================================================

  pyr_selector <- rk.XML.varselector(id.name = "pyr_selector")

  pyr_data <- rk.XML.varslot(label = "Data Object (Survey or Data Frame)", source = "pyr_selector", required = TRUE, id.name = "pyr_data", classes = c("data.frame", "survey.design", "tbl_svy"))
  pyr_age <- rk.XML.varslot(label = "Age Group Variable", source = "pyr_selector", required = TRUE, id.name = "pyr_age")
  pyr_split <- rk.XML.varslot(label = "Split by (Sex/Gender/Region)", source = "pyr_selector", required = TRUE, id.name = "pyr_split")
  pyr_stack <- rk.XML.varslot(label = "Stack by (Optional subgroup)", source = "pyr_selector", id.name = "pyr_stack")

  # Transformation Options
  pyr_trans_mode <- rk.XML.radio(label = "Age Variable Processing", id.name = "age_trans_mode", options = list(
      "Use as is (Must be Factor)" = list(val = "none", chk = TRUE),
      "Convert to Factor (as.factor)" = list(val = "factor"),
      "Bin Numeric Variable (cut)" = list(val = "bin")
  ))
  pyr_bin_width <- rk.XML.spinbox(label = "Bin Width (Years)", id.name = "bin_width", min = 1, max = 100, initial = 5)
  attr(pyr_bin_width, "dependencies") <- list(active = list(string = "age_trans_mode.string == 'bin'"))

  # Options
  pyr_prop <- rk.XML.cbox(label = "Show Proportions (instead of Counts)", value = "1", id.name = "pyr_prop")
  pyr_narm <- rk.XML.cbox(label = "Remove NA values", value = "1", chk = TRUE, id.name = "pyr_narm")
  pyr_mid <- rk.XML.cbox(label = "Show Midpoint lines", value = "1", id.name = "pyr_mid")

  pyr_preview <- rk.XML.preview(mode="plot")

  pyr_dialog <- rk.XML.dialog(label = "Population Pyramid (apyramid)", child = rk.XML.row(
      pyr_selector,
      rk.XML.col(
          rk.XML.tabbook(tabs = list(
              "Variables" = rk.XML.col(
                  pyr_data,
                  pyr_age,
                  rk.XML.frame(pyr_trans_mode, pyr_bin_width),
                  pyr_split,
                  pyr_stack
              ),
              "Settings" = rk.XML.col(pyr_prop, pyr_narm, pyr_mid),
              "Labels" = labels_tab,
              "Theme" = theme_tab,
              "Output" = device_tab
          )),
          pyr_preview
      )
  ))

  js_calc_pyr <- paste0(js_helpers, '
    var data = getValue("pyr_data");
    var age_col = getColumnName(getValue("pyr_age"));
    var split = getColumnName(getValue("pyr_split"));
    var stack = getColumnName(getValue("pyr_stack"));
    var trans_mode = getValue("age_trans_mode");
    var bin_w = getValue("bin_width");

    var prop = getValue("pyr_prop") == "1" ? "TRUE" : "FALSE";
    var narm = getValue("pyr_narm") == "1" ? "TRUE" : "FALSE";
    var mid = getValue("pyr_mid") == "1" ? "TRUE" : "FALSE";

    echo("plot_data <- " + data + "\\n");

    if (trans_mode == "factor") {
        echo("if(inherits(plot_data, \\"survey.design\\")) {\\n");
        echo("  plot_data <- update(plot_data, " + age_col + " = as.factor(" + age_col + "))\\n");
        echo("} else {\\n");
        echo("  plot_data[[\\"" + age_col + "\\"]] <- as.factor(plot_data[[\\"" + age_col + "\\"]])\\n");
        echo("}\\n");
    }
    else if (trans_mode == "bin") {
        var cut_cmd_survey = "cut(" + age_col + ", breaks = seq(0, max(" + age_col + ", na.rm=TRUE) + " + bin_w + ", " + bin_w + "), right = FALSE)";
        var ref = "plot_data[[\\"" + age_col + "\\"]]";
        var cut_cmd_df = "cut(" + ref + ", breaks = seq(0, max(" + ref + ", na.rm=TRUE) + " + bin_w + ", " + bin_w + "), right = FALSE)";

        echo("if(inherits(plot_data, \\"survey.design\\")) {\\n");
        echo("  plot_data <- update(plot_data, " + age_col + " = " + cut_cmd_survey + ")\\n");
        echo("} else {\\n");
        echo("  plot_data[[\\"" + age_col + "\\"]] <- " + cut_cmd_df + "\\n");
        echo("}\\n");
    }

    var opts = [];
    opts.push("data = plot_data");
    opts.push("age_group = " + age_col);
    opts.push("split_by = " + split);
    if (stack) opts.push("stack_by = " + stack);
    opts.push("proportional = " + prop);
    opts.push("na.rm = " + narm);
    opts.push("show_midpoint = " + mid);

    echo("p <- apyramid::age_pyramid(" + opts.join(", ") + ")\\n");

    // --- LABELS ---
    var title = getValue("plot_title");
    var sub = getValue("plot_subtitle");
    var cap = getValue("plot_caption");
    var xlab = getValue("plot_xlab");
    var ylab = getValue("plot_ylab");
    var leg = getValue("plot_legend_title");
    var leg_wrap = getValue("plot_leg_wrap"); // New wrap value

    var labs = [];
    if(title) labs.push("title=\\"" + title + "\\"");
    if(sub) labs.push("subtitle=\\"" + sub + "\\"");
    if(cap) labs.push("caption=\\"" + cap + "\\"");
    if(xlab) labs.push("y=\\"" + xlab + "\\""); // Note: apyramid flips coords
    if(ylab) labs.push("x=\\"" + ylab + "\\"");

    // Logic for Legend Title Wrapping
    if (leg) {
        if(leg_wrap > 0) {
             labs.push("fill=stringr::str_wrap(\\"" + leg + "\\", " + leg_wrap + ")");
        } else {
             labs.push("fill=\\"" + leg + "\\"");
        }
    }

    if(labs.length > 0) echo("p <- p + ggplot2::labs(" + labs.join(", ") + ")\\n");

    // --- PALETTES ---
    var pal = getValue("theme_palette");
    // Viridis Options
    if (pal == "viridis") echo("p <- p + ggplot2::scale_fill_viridis_d(option = \\"D\\")\\n");
    if (pal == "magma")   echo("p <- p + ggplot2::scale_fill_viridis_d(option = \\"A\\")\\n");
    if (pal == "inferno") echo("p <- p + ggplot2::scale_fill_viridis_d(option = \\"B\\")\\n");
    if (pal == "plasma")  echo("p <- p + ggplot2::scale_fill_viridis_d(option = \\"C\\")\\n");
    if (pal == "cividis") echo("p <- p + ggplot2::scale_fill_viridis_d(option = \\"E\\")\\n");

    // Brewer Options
    if (pal == "set1")    echo("p <- p + ggplot2::scale_fill_brewer(palette=\\"Set1\\")\\n");
    if (pal == "set2")    echo("p <- p + ggplot2::scale_fill_brewer(palette=\\"Set2\\")\\n");
    if (pal == "set3")    echo("p <- p + ggplot2::scale_fill_brewer(palette=\\"Set3\\")\\n");
    if (pal == "dark2")   echo("p <- p + ggplot2::scale_fill_brewer(palette=\\"Dark2\\")\\n");
    if (pal == "accent")  echo("p <- p + ggplot2::scale_fill_brewer(palette=\\"Accent\\")\\n");
    if (pal == "paired")  echo("p <- p + ggplot2::scale_fill_brewer(palette=\\"Paired\\")\\n");
    if (pal == "pastel1") echo("p <- p + ggplot2::scale_fill_brewer(palette=\\"Pastel1\\")\\n");
    if (pal == "pastel2") echo("p <- p + ggplot2::scale_fill_brewer(palette=\\"Pastel2\\")\\n");

    // Greyscale
    if (pal == "grey")    echo("p <- p + ggplot2::scale_fill_grey()\\n");

    // --- THEMES & SIZES ---
    var pos = getValue("theme_legend_pos");
    var base_size = getValue("theme_base_size");
    var rel_title = getValue("rel_title");
    var rel_axis_title = getValue("rel_axis_title");
    var rel_axis_text = getValue("rel_axis_text");
    var rel_legend = getValue("rel_legend");

    echo("p <- p + ggplot2::theme_minimal(base_size = " + base_size + ") + ggplot2::theme(\\n");
    echo("  legend.position = \\"" + pos + "\\",\\n");
    echo("  plot.title = ggplot2::element_text(size = ggplot2::rel(" + rel_title + ")),\\n");
    echo("  axis.title = ggplot2::element_text(size = ggplot2::rel(" + rel_axis_title + ")),\\n");
    echo("  axis.text = ggplot2::element_text(size = ggplot2::rel(" + rel_axis_text + ")),\\n");
    echo("  legend.title = ggplot2::element_text(size = ggplot2::rel(" + rel_legend + ")),\\n");
    echo("  legend.text = ggplot2::element_text(size = ggplot2::rel(" + rel_legend + "))\\n");
    echo(")\\n");
  ')

  js_print_pyr <- '
    if(!is_preview) {
        echo("rk.graph.on(device.type=\\"" + getValue("device_type") + "\\", width=" + getValue("dev_width") + ", height=" + getValue("dev_height") + ", res=" + getValue("dev_res") + ")\\n");
    }
    echo("print(p)\\n");
    if(!is_preview) {
        echo("rk.graph.off()\\n");
    }
  '

  # =========================================================================================
  # 5. Skeleton
  # =========================================================================================

  rk.plugin.skeleton(
    about = package_about,
    path = ".",
    xml = list(dialog = pyr_dialog),
    js = list(
        require = c("apyramid", "ggplot2", "survey", "stringr"),
        calculate = js_calc_pyr,
        printout = js_print_pyr
    ),
    pluginmap = list(
        name = "Age Pyramid",
        hierarchy = list("Survey", "Graphs"),
        po_id = "AgePyramid_rkward"
    ),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    load = TRUE, overwrite = TRUE, show = FALSE
  )

  cat("\nPlugin 'rk.apyramid' (v0.1.0) generated successfully.\n")
})
