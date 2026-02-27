local({
  # =========================================================================================
  # 1. Package Definition and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.08-1")

  plugin_name <- "rk.apyramid"
  plugin_ver <- "0.1.2" # Bumped version for new feature

  package_about <- rk.XML.about(
    name = plugin_name,
    author = person(
      given = "Alfonso", family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "High-performance Age pyramids for Data Frames and Survey objects using SWD principles.",
      version = plugin_ver,
      date = format(Sys.Date(), "%Y-%m-%d"),
      url = "https://github.com/AlfCano/rk.apyramid",
      license = "GPL (>= 3)"
    )
  )

  # =========================================================================================
  # 2. Shared Helpers (Strictly NO internal comments)
  # =========================================================================================

  js_helpers <- '
    function getColumnName(fullName) {
        if (!fullName) return "";
        var lastBracketPos = fullName.lastIndexOf("[[");
        if (lastBracketPos > -1) {
            var lastPart = fullName.substring(lastBracketPos);
            var match = lastPart.match(/\\[\\[\\"(.*?)\\"\\]\\]/);
            if (match) return match[1];
        }
        if (fullName.indexOf("$") > -1) return fullName.substring(fullName.lastIndexOf("$") + 1);
        return fullName;
    }

    function getCleanArray(id) {
        var rawValue = getValue(id);
        if (!rawValue) return [];
        var raw = rawValue.split(/\\n/).filter(function(s){return s != ""});
        return raw.map(function(item) {
            var lastBracketPos = item.lastIndexOf("[[");
            if (lastBracketPos > -1) {
                var lastPart = item.substring(lastBracketPos);
                var match = lastPart.match(/\\[\\[\\"(.*?)\\"\\]\\]/);
                if (match) { return match[1]; }
            }
            return item.indexOf("$") > -1 ? item.substring(item.lastIndexOf("$") + 1) : item;
        });
    }

    function getThemeCode() {
        var txt_size = getValue("theme_base_size");
        var leg_pos = getValue("theme_legend_pos");
        var x_ang = getValue("theme_x_angle");
        var y_ang = getValue("theme_y_angle");
        var x_t_ang = getValue("theme_x_title_angle");
        var y_t_ang = getValue("theme_y_title_angle");

        var y_vjust = (y_t_ang == 0) ? "1.02" : "0.5";
        var y_hjust = (y_t_ang == 0) ? "0" : "0.5";

        var code = " + ggplot2::theme_minimal(base_size = " + txt_size + ")";
        code += " + ggplot2::theme(plot.title.position = \\"plot\\", legend.position = \\"" + leg_pos + "\\", legend.justification = \\"left\\", panel.grid.minor = ggplot2::element_blank(), panel.grid.major.x = ggplot2::element_blank())";
        code += " + ggplot2::theme(axis.title.y = ggplot2::element_text(angle = " + y_t_ang + ", vjust = " + y_vjust + ", hjust = " + y_hjust + ", color = \\"gray40\\"), axis.title.x = ggplot2::element_text(angle = " + x_t_ang + ", hjust = 0, color = \\"gray40\\"))";
        code += " + ggplot2::theme(axis.text.x = ggplot2::element_text(angle = " + x_ang + "), axis.text.y = ggplot2::element_text(angle = " + y_ang + "))";
        return code;
    }

    function getSafeColor(id, defaultVal) {
        var c = getValue(id);
        if (!c || c === "") return defaultVal;
        return c;
    }
  '

  # =========================================================================================
  # 3. UI Resources
  # =========================================================================================

  labels_tab <- rk.XML.col(
    rk.XML.input(label = "Plot Title", id.name = "plot_title"),
    rk.XML.input(label = "Plot Subtitle", id.name = "plot_subtitle"),
    rk.XML.input(label = "X-axis Label (Values)", id.name = "plot_xlab"),
    rk.XML.input(label = "Y-Axis Label (Age)", id.name = "plot_ylab"),
    rk.XML.input(label = "Legend Title", id.name = "plot_legend_title"),
    rk.XML.row(
        rk.XML.spinbox(label = "Wrap Title at (chars)", id.name = "plot_leg_wrap", min = 0, max = 100, initial = 0),
        rk.XML.spinbox(label = "Wrap Labels at (chars)", id.name = "plot_leg_lbl_wrap", min = 0, max = 100, initial = 0)
    ),
    rk.XML.input(label = "Plot Caption", id.name = "plot_caption")
  )

  options_tab <- rk.XML.col(
      rk.XML.frame(label = "Axis Title Rotation",
          rk.XML.row(
              rk.XML.spinbox(label = "X Title Angle", id.name = "theme_x_title_angle", min = -90, max = 90, initial = 0),
              rk.XML.spinbox(label = "Y Title Angle", id.name = "theme_y_title_angle", min = -90, max = 90, initial = 0)
          )
      ),
      rk.XML.frame(label = "Axis Value Rotation",
          rk.XML.row(
              rk.XML.spinbox(label = "X Value Angle", id.name = "theme_x_angle", min = -90, max = 90, initial = 0),
              rk.XML.spinbox(label = "Y Value Angle", id.name = "theme_y_angle", min = -90, max = 90, initial = 0)
          )
      )
  )

  theme_tab <- rk.XML.col(
      rk.XML.spinbox(label="Base Font Size", id.name="theme_base_size", min=6, max=50, initial=12),
      rk.XML.dropdown(label="Legend Position", id.name="theme_legend_pos", options=list("Bottom"=list(val="bottom", chk=TRUE), "Top"=list(val="top"), "Right"=list(val="right"), "None"=list(val="none"))),
      rk.XML.dropdown(label="Color Palette", id.name="theme_palette", options=list(
          "Default (apyramid)"=list(val="default", chk=TRUE),
          "SWD Red/Gray"=list(val="swd_red"),
          "SWD Blue/Gray"=list(val="swd_blue"),
          "SWD Orange/Gray"=list(val="swd_orange"),
          "Viridis"=list(val="viridis"),
          "Brewer: Paired"=list(val="Paired"),
          "Brewer: Set1"=list(val="Set1"),
          "Brewer: Accent"=list(val="Accent")
      ))
  )

  device_tab <- rk.XML.col(
    rk.XML.dropdown(label = "Device type", id.name = "device_type", options = list("PNG" = list(val = "PNG", chk = TRUE), "SVG" = list(val = "SVG"))),
    rk.XML.row(
        rk.XML.spinbox(label = "Width (px)", id.name = "dev_width", min = 100, max = 4000, initial = 1024),
        rk.XML.spinbox(label = "Height (px)", id.name = "dev_height", min = 100, max = 4000, initial = 1024)
    ),
    rk.XML.col(
        rk.XML.spinbox(label = "Resolution (ppi)", id.name = "dev_res", min = 50, max = 600, initial = 150),
        rk.XML.dropdown(label = "Background", id.name = "dev_bg", options = list("Transparent" = list(val = "transparent", chk = TRUE), "White" = list(val = "white")))
    )
  )

  pyr_selector <- rk.XML.varselector(id.name = "pyr_selector")
  pyr_data <- rk.XML.varslot(label = "Data Object", source = "pyr_selector", required = TRUE, id.name = "pyr_data", classes = c("data.frame", "survey.design", "tbl_svy"))
  pyr_age <- rk.XML.varslot(label = "Age Variable", source = "pyr_selector", required = TRUE, id.name = "pyr_age")
  pyr_split <- rk.XML.varslot(label = "Split by (Sex)", source = "pyr_selector", required = TRUE, id.name = "pyr_split")
  pyr_stack <- rk.XML.varslot(label = "Stack Variable (Optional)", source = "pyr_selector", id.name = "pyr_stack")

  # NEW: Subset input
  pyr_subset <- rk.XML.input(label = "Subset Expression (e.g. region == 'North')", id.name = "pyr_subset")

  pyr_dialog <- rk.XML.dialog(label = "SWD Age Pyramid", child = rk.XML.row(
      pyr_selector,
      rk.XML.col(
          rk.XML.tabbook(tabs = list(
              "Variables" = rk.XML.col(
                  pyr_data,
                  pyr_subset, # Added here
                  pyr_age,
                  rk.XML.frame(label = "Age Processing",
                      rk.XML.radio(label = "Mode", id.name = "age_trans_mode", options = list(
                          "Use as is (Must be Factor)" = list(val = "none", chk = TRUE),
                          "Convert to Factor" = list(val = "factor"),
                          "Bin Numeric Variable" = list(val = "bin")
                      )),
                      rk.XML.spinbox(label = "Bin Width (Years)", id.name = "bin_width", min = 1, max = 100, initial = 5)
                  ),
                  pyr_split, pyr_stack
              ),
              "Settings" = rk.XML.col(
                  rk.XML.cbox(label = "Show Proportions (%)", value = "1", id.name = "pyr_prop"),
                  rk.XML.cbox(label = "Remove NA values", value = "1", chk = TRUE, id.name = "pyr_narm"),
                  rk.XML.cbox(label = "Show Midpoint lines", value = "1", id.name = "pyr_mid"),
                  rk.XML.frame(label = "Survey Statistics",
                      rk.XML.cbox(label = "Adjust for lonely PSUs", value = "adjust", chk = FALSE, id.name = "lonely_psu")
                  )
              ),
              "Options" = options_tab,
              "Labels" = labels_tab,
              "Theme" = theme_tab,
              "Output & Export" = device_tab
          )),
          rk.XML.preview(mode="plot")
      )
  ))

  # =========================================================================================
  # 4. JavaScript Logic
  # =========================================================================================

  js_calc_pyr <- paste0(js_helpers, '
    var data = getValue("pyr_data");
    var subset_expr = getValue("pyr_subset"); // Get subset string
    var age_col = getColumnName(getValue("pyr_age"));
    var split = getColumnName(getValue("pyr_split"));
    var stack = getColumnName(getValue("pyr_stack"));
    var bin_w = getValue("bin_width");
    var prop = (getValue("pyr_prop") == "1" ? "TRUE" : "FALSE");

    if (getValue("lonely_psu") == "adjust") {
        echo("options(survey.lonely.psu = \\"adjust\\")\\n");
    }

    echo("plot_data <- " + data + "\\n");

    echo("if(inherits(plot_data, \\"tbl_svy\\")) {\\n");
    echo("  if(!base::require(srvyr)){stop(\\"Package srvyr is required.\\")}\\n");
    echo("  plot_data <- srvyr::as_survey_design(plot_data)\\n");
    echo("}\\n");

    // NEW: Apply subset if expression exists
    if(subset_expr) {
        echo("plot_data <- subset(plot_data, " + subset_expr + ")\\n");
    }

    var trans_mode = getValue("age_trans_mode");
    if (trans_mode != "none") {
        echo("v_raw <- if(inherits(plot_data, \\"survey.design\\")) plot_data$variables[[\\"" + age_col + "\\"]] else plot_data[[\\"" + age_col + "\\"]]\\n");
        var trans_cmd = (trans_mode == "factor") ? "as.factor(v_raw)" : "cut(v_raw, breaks = seq(0, max(v_raw, na.rm=TRUE) + " + bin_w + ", " + bin_w + "), right = FALSE)";
        echo("if(inherits(plot_data, \\"survey.design\\")) {\\n");
        echo("  plot_data$variables[[\\"" + age_col + "\\"]] <- " + trans_cmd + "\\n");
        echo("} else {\\n");
        echo("  plot_data[[\\"" + age_col + "\\"]] <- " + trans_cmd + "\\n");
        echo("}\\n");
    }

    if (getValue("pyr_narm") == "1") {
        echo("if(inherits(plot_data, \\"survey.design\\")) {\\n");
        echo("  plot_data <- subset(plot_data, !is.na(" + age_col + ") & !is.na(" + split + "))\\n");
        echo("} else {\\n");
        echo("  plot_data <- plot_data[!is.na(plot_data[[\\"" + age_col + "\\"]]) & !is.na(plot_data[[\\"" + split + "\\"]]), ]\\n");
        echo("}\\n");
    }

    echo("if(inherits(plot_data, \\"survey.design\\")) {\\n");
    var formula = "~" + age_col + "+" + split;
    if (stack != "NULL" && stack != "") formula += "+" + stack;
    echo("  tab <- as.data.frame(survey::svytable(" + formula + ", design = plot_data))\\n");
    echo("  if (" + prop + ") tab$Freq <- tab$Freq / sum(tab$Freq)\\n");

    var lbl_wrap = getValue("plot_leg_lbl_wrap");
    if (lbl_wrap > 0) {
        var fill_v = (stack != "NULL" && stack != "") ? stack : split;
        echo("  tab[[\\"" + fill_v + "\\"]] <- factor(tab[[\\"" + fill_v + "\\"]], labels = scales::label_wrap(" + lbl_wrap + ")(levels(factor(tab[[\\"" + fill_v + "\\"]]))))\\n");
    }

    echo("  p <- apyramid::age_pyramid(data = tab, age_group = \\"" + age_col + "\\", split_by = \\"" + split + "\\", count = \\"Freq\\", proportional = FALSE, show_midpoint = " + (getValue("pyr_mid") == "1" ? "TRUE" : "FALSE"));
    if (stack != "NULL" && stack != "") echo(", stack_by = \\"" + stack + "\\"");
    echo(")\\n");
    echo("} else {\\n");

    if (lbl_wrap > 0) {
        var fill_v = (stack != "NULL" && stack != "") ? stack : split;
        echo("  plot_data[[\\"" + fill_v + "\\"]] <- factor(plot_data[[\\"" + fill_v + "\\"]], labels = scales::label_wrap(" + lbl_wrap + ")(levels(factor(plot_data[[\\"" + fill_v + "\\"]]))))\\n");
    }

    echo("  p <- apyramid::age_pyramid(data = plot_data, age_group = \\"" + age_col + "\\", split_by = \\"" + split + "\\", proportional = " + prop + ", show_midpoint = " + (getValue("pyr_mid") == "1" ? "TRUE" : "FALSE"));
    if (stack != "NULL" && stack != "") echo(", stack_by = \\"" + stack + "\\"");
    echo(")\\n");
    echo("}\\n");

    var labs_list = [];
    if(getValue("plot_title")) labs_list.push("title=\\"" + getValue("plot_title") + "\\"");
    if(getValue("plot_subtitle")) labs_list.push("subtitle=\\"" + getValue("plot_subtitle") + "\\"");
    if(getValue("plot_caption")) labs_list.push("caption=\\"" + getValue("plot_caption") + "\\"");
    if(getValue("plot_xlab")) labs_list.push("y=\\"" + getValue("plot_xlab") + "\\"");
    if(getValue("plot_ylab")) labs_list.push("x=\\"" + getValue("plot_ylab") + "\\"");

    var leg_title = getValue("plot_legend_title");
    var leg_wrap = getValue("plot_leg_wrap");
    if (leg_title) {
        var leg_final = (leg_wrap > 0) ? "stringr::str_wrap(\\"" + leg_title + "\\", " + leg_wrap + ")" : "\\"" + leg_title + "\\"";
        labs_list.push("fill = " + leg_final);
    }
    if(labs_list.length > 0) echo("p <- p + ggplot2::labs(" + labs_list.join(", ") + ")\\n");

    var pal = getValue("theme_palette");
    if (pal != "default") {
        var fill_var = (stack != "NULL" && stack != "") ? stack : split;
        echo("lvls <- if(inherits(plot_data, \\"survey.design\\")) unique(as.character(tab[[\\"" + fill_var + "\\"]])) else unique(as.character(plot_data[[\\"" + fill_var + "\\"]]))\\n");
        var labs_arg = (lbl_wrap > 0) ? ", labels = scales::label_wrap(" + lbl_wrap + ")" : "";

        if (pal.indexOf("swd") > -1) {
            var swd_hex = (pal == "swd_red") ? "#941100" : (pal == "swd_blue" ? "#1F77B4" : "#FF7F0E");
            echo("p <- p + ggplot2::scale_fill_manual(values = colorRampPalette(c(\\"" + swd_hex + "\\", \\"#D9D9D9\\", \\"#7F7F7F\\"))(length(lvls))" + labs_arg + ")\\n");
        } else {
            echo("pal_info <- RColorBrewer::brewer.pal.info[\\"" + pal + "\\", ]\\n");
            echo("p <- p + ggplot2::scale_fill_manual(values = colorRampPalette(RColorBrewer::brewer.pal(pal_info$maxcolors, \\"" + pal + "\\"))(length(lvls))" + labs_arg + ")\\n");
        }
    }

    echo("p <- p " + getThemeCode() + "\\n");
    echo("y_lab_fun <- function(x) { if(" + prop + ") scales::label_percent()(abs(x)) else scales::label_number(scale_cut = scales::cut_short_scale())(abs(x)) }\\n");
    echo("p <- p + ggplot2::scale_y_continuous(labels = y_lab_fun, expand = ggplot2::expansion(mult = c(0.05, 0.1))) + ggplot2::theme(axis.line = ggplot2::element_line(color=\\"gray40\\")) + lemon::coord_capped_flip(left=\\"top\\")\\n");
  ')

  js_print_pyr <- '
    if (is_preview) {
        echo("print(p)\\n");
    } else {
        echo("rk.graph.on(device.type=\\"" + getValue("device_type") + "\\", width=" + getValue("dev_width") + ", height=" + getValue("dev_height") + ", res=" + getValue("dev_res") + ", bg=\\"" + getValue("dev_bg") + "\\")\\n");
        echo("print(p)\\n");
        echo("rk.graph.off()\\n");
    }
  '

  # =========================================================================================
  # 5. Help and Skeleton
  # =========================================================================================

  help_list <- list(
    summary = rk.rkh.summary("Generates weighted Age pyramids for Data Frames and Survey objects using SWD principles."),
    usage = rk.rkh.usage("Calculates weighted counts or proportions. Automatically simplifies large numbers (e.g., 6,000,000 to 6M) and removes negative signs from labels.")
  )

  rk.plugin.skeleton(
    about = package_about,
    path = ".",
    xml = list(dialog = pyr_dialog),
    js = list(
        require = c("apyramid", "ggplot2", "survey", "srvyr", "lemon", "stringr", "scales", "RColorBrewer"),
        calculate = js_calc_pyr,
        printout = js_print_pyr
    ),
    rkh = help_list,
    pluginmap = list(name = "Age Pyramid", hierarchy = list("Survey", "Graphs")),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    load = TRUE, overwrite = TRUE, show = FALSE
  )
    cat("\nPlugin 'rk.apyramid' (v0.1.2) generated successfully.\n")
})
