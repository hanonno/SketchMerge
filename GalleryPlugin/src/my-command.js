// documentation: https://developer.sketchapp.com/reference/api/

var Sketch = require('sketch')
var Document = require('sketch/dom').Document

  log(context.documentPath)

function pageWithId (pages, pageId) {
	// log(pages)
	log("====== Looping pages")
	for(var i = 0; i < pages.length; i++) {
		var page = pages[i]
		var currentPageId = page.objectID()

		if(currentPageId == String(pageId)) {
			return page;
		}
		else {
		    log("===== Not found page")	
		}
	}
}

  var documentURL = NSURL.fileURLWithPath(context.documentPath)

  log(documentURL)

	Document.open(documentURL, (err, document) => {
	log("==== Found document")
	  if (err) {
	    // oh no, we failed to open the document
	    Sketch.UI.message("Error opening doc!!")
	  }
	  else {
        log("==== Found File")

		var page = pageWithId(context.document.pages(), context.pageId)
		var layer = document.getLayerWithID(context.layerId)

		document.centerOnLayer(layer)
		context.document.setCurrentPage(page)	
				
		if (layer) {
            log("==== Found Layer")

		}
       else {
            log("==== Did not find layer")
       }
	  }
	})