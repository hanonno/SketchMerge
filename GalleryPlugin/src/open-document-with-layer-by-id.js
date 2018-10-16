// documentation: https://developer.sketchapp.com/reference/api/

var Sketch = require('sketch')
var Document = require('sketch/dom').Document


function pageWithId (pages, pageId) {
	// log(pages)
	log("====== Looping pages")
	for(var i = 0; i < pages.length; i++) {
		var page = pages[i]
		var currentPageId = page.objectID()

		if(currentPageId == String(pageId)) {
			return page;
		}
	}
}


log("Document path: " + context.documentPath)

var documentURL = NSURL.fileURLWithPath(context.documentPath)
log("Document URL: " + documentURL)

Document.open(documentURL, (err, document) => {
  if (err) {
    // oh no, we failed to open the document
    Sketch.UI.message("Error opening doc!!")
  }
  else {
    log("==== Found Document ")

    var doc = Sketch.fromNative(context.document)
	
	var page = pageWithId(context.document.pages(), context.pageId)
	log("==== Found page")

	var layer = doc.getLayerWithID(context.layerId)

	context.document.setCurrentPage(page)
	doc.centerOnLayer(layer)

    layer.moveForward();
    layer.moveBackward();

	var selection = document.selectedLayers
	selection.clear()

    layer.selected = true;

	if (layer) {
		log("==== Found Layer")
	}
	else {
		log("==== Did not find layer")
	}
  }
})