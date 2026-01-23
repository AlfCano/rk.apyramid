// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	preprocess(true);
	calculate(true);
	printout(true);
}

function preprocess(is_preview){
	// add requirements etc. here
	if(is_preview) {
		echo("if(!base::require(apyramid)){stop(" + i18n("Preview not available, because package apyramid is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(apyramid)\n");
	}	if(is_preview) {
		echo("if(!base::require(ggplot2)){stop(" + i18n("Preview not available, because package ggplot2 is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(ggplot2)\n");
	}	if(is_preview) {
		echo("if(!base::require(survey)){stop(" + i18n("Preview not available, because package survey is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(survey)\n");
	}	if(is_preview) {
		echo("if(!base::require(stringr)){stop(" + i18n("Preview not available, because package stringr is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(stringr)\n");
	}
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    function getColumnName(fullName) {
        if (!fullName) return "";
        var lastBracketPos = fullName.lastIndexOf("[[");
        if (lastBracketPos > -1) {
            var lastPart = fullName.substring(lastBracketPos);
            var match = lastPart.match(/\[\[\"(.*?)\"\]\]/);
            if (match) { return match[1]; }
        }
        if (fullName.indexOf("$") > -1) { return fullName.substring(fullName.lastIndexOf("$") + 1); }
        else { return fullName; }
    }
  
    var data = getValue("pyr_data");
    var age_col = getColumnName(getValue("pyr_age"));
    var split = getColumnName(getValue("pyr_split"));
    var stack = getColumnName(getValue("pyr_stack"));
    var trans_mode = getValue("age_trans_mode");
    var bin_w = getValue("bin_width");

    var prop = getValue("pyr_prop") == "1" ? "TRUE" : "FALSE";
    var narm = getValue("pyr_narm") == "1" ? "TRUE" : "FALSE";
    var mid = getValue("pyr_mid") == "1" ? "TRUE" : "FALSE";

    echo("plot_data <- " + data + "\n");

    if (trans_mode == "factor") {
        echo("if(inherits(plot_data, \"survey.design\")) {\n");
        echo("  plot_data <- update(plot_data, " + age_col + " = as.factor(" + age_col + "))\n");
        echo("} else {\n");
        echo("  plot_data[[\"" + age_col + "\"]] <- as.factor(plot_data[[\"" + age_col + "\"]])\n");
        echo("}\n");
    }
    else if (trans_mode == "bin") {
        var cut_cmd_survey = "cut(" + age_col + ", breaks = seq(0, max(" + age_col + ", na.rm=TRUE) + " + bin_w + ", " + bin_w + "), right = FALSE)";
        var ref = "plot_data[[\"" + age_col + "\"]]";
        var cut_cmd_df = "cut(" + ref + ", breaks = seq(0, max(" + ref + ", na.rm=TRUE) + " + bin_w + ", " + bin_w + "), right = FALSE)";

        echo("if(inherits(plot_data, \"survey.design\")) {\n");
        echo("  plot_data <- update(plot_data, " + age_col + " = " + cut_cmd_survey + ")\n");
        echo("} else {\n");
        echo("  plot_data[[\"" + age_col + "\"]] <- " + cut_cmd_df + "\n");
        echo("}\n");
    }

    var opts = [];
    opts.push("data = plot_data");
    opts.push("age_group = " + age_col);
    opts.push("split_by = " + split);
    if (stack) opts.push("stack_by = " + stack);
    opts.push("proportional = " + prop);
    opts.push("na.rm = " + narm);
    opts.push("show_midpoint = " + mid);

    echo("p <- apyramid::age_pyramid(" + opts.join(", ") + ")\n");

    // --- LABELS ---
    var title = getValue("plot_title");
    var sub = getValue("plot_subtitle");
    var cap = getValue("plot_caption");
    var xlab = getValue("plot_xlab");
    var ylab = getValue("plot_ylab");
    var leg = getValue("plot_legend_title");
    var leg_wrap = getValue("plot_leg_wrap"); // New wrap value

    var labs = [];
    if(title) labs.push("title=\"" + title + "\"");
    if(sub) labs.push("subtitle=\"" + sub + "\"");
    if(cap) labs.push("caption=\"" + cap + "\"");
    if(xlab) labs.push("y=\"" + xlab + "\""); // Note: apyramid flips coords
    if(ylab) labs.push("x=\"" + ylab + "\"");

    // Logic for Legend Title Wrapping
    if (leg) {
        if(leg_wrap > 0) {
             labs.push("fill=stringr::str_wrap(\"" + leg + "\", " + leg_wrap + ")");
        } else {
             labs.push("fill=\"" + leg + "\"");
        }
    }

    if(labs.length > 0) echo("p <- p + ggplot2::labs(" + labs.join(", ") + ")\n");

    // --- PALETTES ---
    var pal = getValue("theme_palette");
    // Viridis Options
    if (pal == "viridis") echo("p <- p + ggplot2::scale_fill_viridis_d(option = \"D\")\n");
    if (pal == "magma")   echo("p <- p + ggplot2::scale_fill_viridis_d(option = \"A\")\n");
    if (pal == "inferno") echo("p <- p + ggplot2::scale_fill_viridis_d(option = \"B\")\n");
    if (pal == "plasma")  echo("p <- p + ggplot2::scale_fill_viridis_d(option = \"C\")\n");
    if (pal == "cividis") echo("p <- p + ggplot2::scale_fill_viridis_d(option = \"E\")\n");

    // Brewer Options
    if (pal == "set1")    echo("p <- p + ggplot2::scale_fill_brewer(palette=\"Set1\")\n");
    if (pal == "set2")    echo("p <- p + ggplot2::scale_fill_brewer(palette=\"Set2\")\n");
    if (pal == "set3")    echo("p <- p + ggplot2::scale_fill_brewer(palette=\"Set3\")\n");
    if (pal == "dark2")   echo("p <- p + ggplot2::scale_fill_brewer(palette=\"Dark2\")\n");
    if (pal == "accent")  echo("p <- p + ggplot2::scale_fill_brewer(palette=\"Accent\")\n");
    if (pal == "paired")  echo("p <- p + ggplot2::scale_fill_brewer(palette=\"Paired\")\n");
    if (pal == "pastel1") echo("p <- p + ggplot2::scale_fill_brewer(palette=\"Pastel1\")\n");
    if (pal == "pastel2") echo("p <- p + ggplot2::scale_fill_brewer(palette=\"Pastel2\")\n");

    // Greyscale
    if (pal == "grey")    echo("p <- p + ggplot2::scale_fill_grey()\n");

    // --- THEMES & SIZES ---
    var pos = getValue("theme_legend_pos");
    var base_size = getValue("theme_base_size");
    var rel_title = getValue("rel_title");
    var rel_axis_title = getValue("rel_axis_title");
    var rel_axis_text = getValue("rel_axis_text");
    var rel_legend = getValue("rel_legend");

    echo("p <- p + ggplot2::theme_minimal(base_size = " + base_size + ") + ggplot2::theme(\n");
    echo("  legend.position = \"" + pos + "\",\n");
    echo("  plot.title = ggplot2::element_text(size = ggplot2::rel(" + rel_title + ")),\n");
    echo("  axis.title = ggplot2::element_text(size = ggplot2::rel(" + rel_axis_title + ")),\n");
    echo("  axis.text = ggplot2::element_text(size = ggplot2::rel(" + rel_axis_text + ")),\n");
    echo("  legend.title = ggplot2::element_text(size = ggplot2::rel(" + rel_legend + ")),\n");
    echo("  legend.text = ggplot2::element_text(size = ggplot2::rel(" + rel_legend + "))\n");
    echo(")\n");
  
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Age Pyramid results")).print();	
	}
    if(!is_preview) {
        echo("rk.graph.on(device.type=\"" + getValue("device_type") + "\", width=" + getValue("dev_width") + ", height=" + getValue("dev_height") + ", res=" + getValue("dev_res") + ")\n");
    }
    echo("print(p)\n");
    if(!is_preview) {
        echo("rk.graph.off()\n");
    }
  

}

