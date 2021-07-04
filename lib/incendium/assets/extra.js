function incendiumSearch(id) {
  console.log("search")
  var term = document.getElementById("term-" + id).value;
  window['incendiumFlamegraph_' + id].search(term);
}

function incendiumClear(id) {
  console.log("clear")
  document.getElementById('term-' + id).value = '';
  window['incendiumFlamegraph_' + id].clear();
}

function incendiumResetZoom(id) {
  window['incendiumFlamegraph_' + id].resetZoom();
}

// Saves the javascript as a file
function incendiumDownload(id) {
  console.log("download")
  var text = window['incendiumFlamegraphScript_' + id].innerHTML
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
function incendiumFlamegraph(id, data) {
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

  var styleSeparate = "margin-right: 1.25em;";

  var newElement =
    h("div", { class: "incendium" }, [
      h("nav", {}, [
        h("div", {}, [
          h("div", { style: "float: left" }, [
            h("a", { class: "incendium", href: downloadAction, id: downloaderId, style: styleSeparate }, ["Download"]),
            h("a", { class: "incendium", href: resetZoomAction, style: styleSeparate }, ["Reset zoom"]),
            h("a", { class: "incendium", href: clearAction, style: styleSeparate }, ["Clear"])
          ]),
          h("div", { style: "float: right" }, [
            h("form", { class: "incendium", id: formId, style: "display: inline-block important!;" }, [
              h("input", { class: "incendium", id: termId }, []),
              h("a", { class: "incendium", style: "margin-left: 5px", href: searchAction }, ["Search"])
            ])
          ])
        ])
      ]),
      h("div", { id: chartId }, []),
      h("div", { id: detailsId }, [])
    ]);

  // Insert the HTML just before the current script
  document.currentScript.parentNode.insertBefore(newElement, document.currentScript);

  var flameGraph = d3.flamegraph()
    .cellHeight(18)
    .transitionDuration(750)
    .minFrameSize(5)
    .transitionEase(d3.easeCubic)
    .sort(true)
    .title("")
    .differential(false)
    .selfValue(false);

  var details = document.getElementById(detailsId);
  flameGraph.setDetailsElement(details);

  window["incendiumFlamegraph_" + id] = flameGraph;
  window["incendiumFlamegraphScript_" + id] = document.currentScript;

  d3.select("#" + chartId)
    .datum(data)
    .call(flameGraph);

  document.getElementById(formId).addEventListener("submit", function (event) {
    event.preventDefault();
    incendiumSearch(id);
  });
}