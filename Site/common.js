///////////////
// Variables //
///////////////

// Full screen SVG elements
var width = "100%",
    height = "100%";
	
// Definition of zoom
var zoom = d3.behavior.zoom()
    .scaleExtent([0.5, 50]) // Zoom upper and lower bounds
    .on("zoom", zoomed);

// Bypass default drag functions
var drag = d3.behavior.drag()
    .origin(function(d) { return d; })
    .on("dragstart", dragstarted)
    .on("drag", dragged)
    .on("dragend", dragended);

// Create an svg element
var svg = d3.select("body").append("svg")
	.attr("id", "svgEmbed")
    .attr("width", width)
    .attr("height", height)
	.attr("position","fixed")
	.attr("top","0")
	.attr("left","0")
	.attr("bottom","0")
	.attr("right","0")
	.attr("overflow","auto")
    .append("g")
    .call(zoom);

// Beginning of definitions
// Definitions include different ways of rendering more complicated elements
var pattern = svg.append("defs");

// Rendering feature for "Avoin metsämaa"
var v_70_39110 = pattern.append("pattern")
		.attr("id","s_70_39110")
		.attr("patternUnits","userSpaceOnUse")
		.attr("width","1.2")
		.attr("height","1.2")
		.attr("patternTransform","rotate(-45)")
v_70_39110.append("path")
		.attr("d","M0,0 l4,0")
		.attr("style","stroke:#B8D900")
		.attr("stroke-width","1")

// Rendering feature for "Vaikeakulkuisen puuttoman suon"
var v_64_35421 = pattern.append("pattern")
		.attr("id","s_64_35421")
		.attr("patternUnits","userSpaceOnUse")
		.attr("width","1.5")
		.attr("height","1.5")
v_64_35421.append("rect")
		.attr("width", "4")
		.attr("height", "4")
		.attr("x", "0")
		.attr("x", "0")
		.attr("fill", "#D1CC40")
v_64_35421.append("path")
		.attr("d","M0,0 l4,0")
		.attr("style","stroke:#5CE6E6")
		.attr("stroke-width","1")

// Rendering feature for "Vaikeakulkuisen metsää kasvavan suon"
var v_64_35422 = pattern.append("pattern")
		.attr("id","s_64_35422")
		.attr("patternUnits","userSpaceOnUse")
		.attr("width","1.5")
		.attr("height","1.5")
v_64_35422.append("rect")
		.attr("width", "4")
		.attr("height", "4")
		.attr("x", "0")
		.attr("x", "0")
		.attr("fill", "#C7EBEB")
v_64_35422.append("path")
		.attr("d","M0,0 l4,0")
		.attr("style","stroke:#5CE6E6")
		.attr("stroke-width","1")
		
// Rendering feature for "Kaatopaikan"
var v_64_32300 = pattern.append("pattern")
		.attr("id","s_64_32300")
		.attr("patternUnits","userSpaceOnUse")
		.attr("width","1.5")
		.attr("height","1.5")
v_64_32300.append("rect")
		.attr("width", "4")
		.attr("height", "4")
		.attr("x", "0")
		.attr("x", "0")
		.attr("fill", "#FFFFD9")
v_64_32300.append("path")
		.attr("d","M0,0 14,0")
		.attr("style","stroke:#AB5700")
		.attr("stroke-dasharray","4,2")
		.attr("stroke-width","0.5")
		
// Defining drawing area
var rect = svg.append("rect")
    .attr("width", width)
    .attr("height", height)
    .style("fill", "none")
    .style("pointer-events", "all");
	
// Defining container element
var container = svg.append("g");

///////////////
// Functions //
///////////////

// These functions bypass default behaviors mainly regarding zooming and dragging
function zoomed()
{
	container.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
	
	if (d3.event.scale < 2)
	{
		svg.selectAll("#contour").style("opacity", 0);
		svg.selectAll("#agglomeration").style("opacity", 1);
		svg.selectAll("#residential_building").style("opacity", 0);
		svg.selectAll("#public_building").style("opacity", 0);
		svg.selectAll("#vacation_building").style("opacity", 0);
		svg.selectAll("#industrial_building").style("opacity", 0);
		svg.selectAll("#other_building").style("opacity", 0);
	}
	else
	{
		svg.selectAll("#contour").style("opacity", 1);
		svg.selectAll("#agglomeration").style("opacity", 0);
		svg.selectAll("#residential_building").style("opacity", 1);
		svg.selectAll("#public_building").style("opacity", 1);
		svg.selectAll("#vacation_building").style("opacity", 1);
		svg.selectAll("#industrial_building").style("opacity", 1);
		svg.selectAll("#other_building").style("opacity", 1);
	}
}

function dragstarted(d)
{
	d3.event.sourceEvent.stopPropagation();
	d3.select(this).classed("dragging", true);
}

function dragged(d)
{
	d3.select(this).attr("cx", d.x = d3.event.x).attr("cy", d.y = d3.event.y);
}

function dragended(d)
{
	d3.select(this).classed("dragging", false);
}

doClick = function (sender)
{
	alert(sender.id);
}