function incendiumSearch(id) {
  var term = document.getElementById("term-" + id).value;
  window['incendiumFlameGraph_' + id].search(term);
}

function incendiumClear(id) {
  document.getElementById('term-' + id).value = '';
  window['incendiumFlameGraph_' + id].clear();
}

function incendiumResetZoom(id) {
  window['incendiumFlameGraph_' + id].resetZoom();
}

// Saves the javascript as a file
function incendiumDownload(id) {
  var text = window['incendiumFlameGraphScript_' + id].innerHTML
  var name = "incendium_flamegraph_" + id + ".js";
  var type = "text/javascript";
  var a = document.getElementById("downloader-" + id);
  var file = new Blob([text], { type: type });
  a.href = URL.createObjectURL(file);
  a.download = name;
}

// This function creates an HTML and places it just before
// the script tag that has called the function.
// This is a bit dirty, but it's probably the easiest way of
// having embedded flamegraphs which play well with both HTML
// and markdown.
// Having embedded flamegraphs that play well with markdown
// is important because it makes it possible to embed them
// in places like ExDoc pages
function incendiumFlameGraph(id, data) {
  // Convenience function to make it easier to generate HTML elements from javascript
  function h(type, attributes, children) {
    var el = document.createElement(type);

    for (key in attributes) {
      el.setAttribute(key, attributes[key])
    }

    children.forEach(child => {
      if (typeof child === 'string') {
        el.appendChild(document.createTextNode(child))
      } else {
        el.appendChild(child)
      }
    })

    return el
  }

  var clearAction = "javascript: incendiumClear(\"" + id + "\");";
  var searchAction = "javascript: incendiumSearch(\"" + id + "\");";
  var resetZoomAction = "javascript: incendiumResetZoom(\"" + id + "\");";
  var downloadAction = "javascript: incendiumDownload(\"" + id + "\");";

  var formId = "form-" + id;
  var termId = "term-" + id;
  var chartId = "chart-" + id;
  var detailsId = "details-" + id;
  var downloaderId = "downloader-" + id;

  var newElement =
    h("div", { class: "incendium" }, [
      h("div", { id: chartId, style: "" }, []),
      h("div", { id: detailsId, style: "height: 2.15em;" }, []),
      h("nav", {}, [
        h("div", {}, [
          // h("a", { class: "incendium", href: downloadAction, id: downloaderId, style: styleSeparate }, ["Download"]),
          h("input", { class: "incendium", id: termId }, []),
          h("a", { class: "incendium", href: searchAction, style: "margin-left: 0.75em;" }, ["Search"]),
          h("a", { class: "incendium", href: clearAction, style: "margin-left: 2em;" }, ["Clear search"]),
          h("a", { class: "incendium", href: resetZoomAction, style: "margin-left: 1.25em;" }, ["Reset zoom"])
        ])
      ]),
    ]);

  // Insert the HTML just before the current script
  var script = document.currentScript;
  script.parentNode.insertBefore(newElement, script);

  document.getElementById(termId).addEventListener("keyup", function (event) {
    if (event.key === "Enter") {
      incendiumSearch(id);
    }
  })

  var flameGraphWidthMultiplier = script.dataset.flameGraphWidthMultiplier || 1.0;
  var flameGraphWidth = (script.parentElement.clientWidth || 960) * flameGraphWidthMultiplier;

  var flameGraph = d3.flamegraph()
    .cellHeight(18)
    .transitionDuration(500)
    .width(flameGraphWidth)
    .minFrameSize(0)
    .transitionEase(d3.easeCubic)
    .sort(true)
    .title("")
    .differential(false)
    .selfValue(false)
    .tooltip(false)

  var details = document.getElementById(detailsId);
  flameGraph.setDetailsElement(details);

  window["incendiumFlameGraph_" + id] = flameGraph;
  window["incendiumFlameGraphScript_" + id] = document.currentScript;

  d3.select("#" + chartId)
    .datum(data)
    .call(flameGraph);
}