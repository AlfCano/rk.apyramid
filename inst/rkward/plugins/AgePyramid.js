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
		echo("if(!base::require(srvyr)){stop(" + i18n("Preview not available, because package srvyr is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(srvyr)\n");
	}	if(is_preview) {
		echo("if(!base::require(lemon)){stop(" + i18n("Preview not available, because package lemon is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(lemon)\n");
	}	if(is_preview) {
		echo("if(!base::require(stringr)){stop(" + i18n("Preview not available, because package stringr is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(stringr)\n");
	}	if(is_preview) {
		echo("if(!base::require(scales)){stop(" + i18n("Preview not available, because package scales is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(scales)\n");
	}	if(is_preview) {
		echo("if(!base::require(RColorBrewer)){stop(" + i18n("Preview not available, because package RColorBrewer is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(RColorBrewer)\n");
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
            if (match) return match[1];
        }
        if (fullName.indexOf("$") > -1) return fullName.substring(fullName.lastIndexOf("$") + 1);
        return fullName;
    }

    function getCleanArray(id) {
        var rawValue = getValue(id);
        if (!rawValue) return [];
        var raw = rawValue.split(/\n/).filter(function(s){return s != ""});
        return raw.map(function(item) {
            var lastBracketPos = item.lastIndexOf("[[");
            if (lastBracketPos > -1) {
                var lastPart = item.substring(lastBracketPos);
                var match = lastPart.match(/\[\[\"(.*?)\"\]\]/);
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
        code += " + ggplot2::theme(plot.title.position = \"plot\", legend.position = \"" + leg_pos + "\", legend.justification = \"left\", panel.grid.minor = ggplot2::element_blank(), panel.grid.major.x = ggplot2::element_blank())";
        code += " + ggplot2::theme(axis.title.y = ggplot2::element_text(angle = " + y_t_ang + ", vjust = " + y_vjust + ", hjust = " + y_hjust + ", color = \"gray40\"), axis.title.x = ggplot2::element_text(angle = " + x_t_ang + ", hjust = 0, color = \"gray40\"))";
        code += " + ggplot2::theme(axis.text.x = ggplot2::element_text(angle = " + x_ang + "), axis.text.y = ggplot2::element_text(angle = " + y_ang + "))";
        return code;
    }

    function getSafeColor(id, defaultVal) {
        var c = getValue(id);
        if (!c || c === "") return defaultVal;
        return c;
    }
  
    var data = getValue("pyr_data");
    var age_col = getColumnName(getValue("pyr_age"));
    var split = getColumnName(getValue("pyr_split"));
    var stack = getColumnName(getValue("pyr_stack"));
    var bin_w = getValue("bin_width");
    var prop = (getValue("pyr_prop") == "1" ? "TRUE" : "FALSE");

    if (getValue("lonely_psu") == "adjust") {
        echo("options(survey.lonely.psu = \"adjust\")\n");
    }

    echo("plot_data <- " + data + "\n");

    echo("if(inherits(plot_data, \"tbl_svy\")) {\n");
    echo("  if(!base::require(srvyr)){stop(\"Package srvyr is required.\")}\n");
    echo("  plot_data <- srvyr::as_survey_design(plot_data)\n");
    echo("}\n");

    var trans_mode = getValue("age_trans_mode");
    if (trans_mode != "none") {
        echo("v_raw <- if(inherits(plot_data, \"survey.design\")) plot_data$variables[[\"" + age_col + "\"]] else plot_data[[\"" + age_col + "\"]]\n");
        var trans_cmd = (trans_mode == "factor") ? "as.factor(v_raw)" : "cut(v_raw, breaks = seq(0, max(v_raw, na.rm=TRUE) + " + bin_w + ", " + bin_w + "), right = FALSE)";
        echo("if(inherits(plot_data, \"survey.design\")) {\n");
        echo("  plot_data$variables[[\"" + age_col + "\"]] <- " + trans_cmd + "\n");
        echo("} else {\n");
        echo("  plot_data[[\"" + age_col + "\"]] <- " + trans_cmd + "\n");
        echo("}\n");
    }

    if (getValue("pyr_narm") == "1") {
        echo("if(inherits(plot_data, \"survey.design\")) {\n");
        echo("  plot_data <- subset(plot_data, !is.na(" + age_col + ") & !is.na(" + split + "))\n");
        echo("} else {\n");
        echo("  plot_data <- plot_data[!is.na(plot_data[[\"" + age_col + "\"]]) & !is.na(plot_data[[\"" + split + "\"]]), ]\n");
        echo("}\n");
    }

    echo("if(inherits(plot_data, \"survey.design\")) {\n");
    var formula = "~" + age_col + "+" + split;
    if (stack != "NULL" && stack != "") formula += "+" + stack;
    echo("  tab <- as.data.frame(survey::svytable(" + formula + ", design = plot_data))\n");
    echo("  if (" + prop + ") tab$Freq <- tab$Freq / sum(tab$Freq)\n");

    var lbl_wrap = getValue("plot_leg_lbl_wrap");
    if (lbl_wrap > 0) {
        var fill_v = (stack != "NULL" && stack != "") ? stack : split;
        echo("  tab[[\"" + fill_v + "\"]] <- factor(tab[[\"" + fill_v + "\"]], labels = scales::label_wrap(" + lbl_wrap + ")(levels(factor(tab[[\"" + fill_v + "\"]]))))\n");
    }

    echo("  p <- apyramid::age_pyramid(data = tab, age_group = \"" + age_col + "\", split_by = \"" + split + "\", count = \"Freq\", proportional = FALSE, show_midpoint = " + (getValue("pyr_mid") == "1" ? "TRUE" : "FALSE"));
    if (stack != "NULL" && stack != "") echo(", stack_by = \"" + stack + "\"");
    echo(")\n");
    echo("} else {\n");

    if (lbl_wrap > 0) {
        var fill_v = (stack != "NULL" && stack != "") ? stack : split;
        echo("  plot_data[[\"" + fill_v + "\"]] <- factor(plot_data[[\"" + fill_v + "\"]], labels = scales::label_wrap(" + lbl_wrap + ")(levels(factor(plot_data[[\"" + fill_v + "\"]]))))\n");
    }

    echo("  p <- apyramid::age_pyramid(data = plot_data, age_group = \"" + age_col + "\", split_by = \"" + split + "\", proportional = " + prop + ", show_midpoint = " + (getValue("pyr_mid") == "1" ? "TRUE" : "FALSE"));
    if (stack != "NULL" && stack != "") echo(", stack_by = \"" + stack + "\"");
    echo(")\n");
    echo("}\n");

    var labs_list = [];
    if(getValue("plot_title")) labs_list.push("title=\"" + getValue("plot_title") + "\"");
    if(getValue("plot_subtitle")) labs_list.push("subtitle=\"" + getValue("plot_subtitle") + "\"");
    if(getValue("plot_caption")) labs_list.push("caption=\"" + getValue("plot_caption") + "\"");
    if(getValue("plot_xlab")) labs_list.push("y=\"" + getValue("plot_xlab") + "\"");
    if(getValue("plot_ylab")) labs_list.push("x=\"" + getValue("plot_ylab") + "\"");

    var leg_title = getValue("plot_legend_title");
    var leg_wrap = getValue("plot_leg_wrap");
    if (leg_title) {
        var leg_final = (leg_wrap > 0) ? "stringr::str_wrap(\"" + leg_title + "\", " + leg_wrap + ")" : "\"" + leg_title + "\"";
        labs_list.push("fill = " + leg_final);
    }
    if(labs_list.length > 0) echo("p <- p + ggplot2::labs(" + labs_list.join(", ") + ")\n");

    var pal = getValue("theme_palette");
    if (pal != "default") {
        var fill_var = (stack != "NULL" && stack != "") ? stack : split;
        echo("lvls <- if(inherits(plot_data, \"survey.design\")) unique(as.character(tab[[\"" + fill_var + "\"]])) else unique(as.character(plot_data[[\"" + fill_var + "\"]]))\n");
        var labs_arg = (lbl_wrap > 0) ? ", labels = scales::label_wrap(" + lbl_wrap + ")" : "";

        if (pal.indexOf("swd") > -1) {
            var swd_hex = (pal == "swd_red") ? "#941100" : (pal == "swd_blue" ? "#1F77B4" : "#FF7F0E");
            echo("p <- p + ggplot2::scale_fill_manual(values = colorRampPalette(c(\"" + swd_hex + "\", \"#D9D9D9\", \"#7F7F7F\"))(length(lvls))" + labs_arg + ")\n");
        } else {
            echo("pal_info <- RColorBrewer::brewer.pal.info[\"" + pal + "\", ]\n");
            echo("p <- p + ggplot2::scale_fill_manual(values = colorRampPalette(RColorBrewer::brewer.pal(pal_info$maxcolors, \"" + pal + "\"))(length(lvls))" + labs_arg + ")\n");
        }
    }

    echo("p <- p " + getThemeCode() + "\n");
    echo("y_lab_fun <- function(x) { if(" + prop + ") scales::label_percent()(abs(x)) else scales::label_number(scale_cut = scales::cut_short_scale())(abs(x)) }\n");
    echo("p <- p + ggplot2::scale_y_continuous(labels = y_lab_fun, expand = ggplot2::expansion(mult = c(0.05, 0.1))) + ggplot2::theme(axis.line = ggplot2::element_line(color=\"gray40\")) + lemon::coord_capped_flip(left=\"top\")\n");
  
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Age Pyramid results")).print();	
	}
    if (is_preview) {
        echo("print(p)\n");
    } else {
        echo("rk.graph.on(device.type=\"" + getValue("device_type") + "\", width=" + getValue("dev_width") + ", height=" + getValue("dev_height") + ", res=" + getValue("dev_res") + ", bg=\"" + getValue("dev_bg") + "\")\n");
        echo("print(p)\n");
        echo("rk.graph.off()\n");
    }
  

}

