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

		log(currentPageId)
		log(pageId)


		if(currentPageId == String(pageId)) {
			return page;
		}
		else {
		    log("===== Not found page")	
		}
	}
	log("-----")
}



  var documentURL = NSURL.fileURLWithPath(context.documentPath)

  log(documentURL)

	Document.open(documentURL, (err, document) => {
	// Document.open(context.documentPath, (err, document) => {		

	log("==== Found document")
	// log(context.document.pages())


	  // document.setCurrentPage(page)

	  if (err) {
	    // oh no, we failed to open the document
	    Sketch.UI.message("Error opening doc!!")
	  }
	  else {
        log("==== Found File")
		// var layer = document.getLayerWithID('EEA2C7E0-C57D-4130-8463-18A78EE5E525')

		  var page = pageWithId(context.document.pages(), context.pageId)

		  // if(page != context.document.currentPage) {
			  context.document.setCurrentPage(page)	
		  // }


		var layer = document.getLayerWithID(context.layerId)
				
		if (layer) {
            log("==== Found Layer")

			document.centerOnLayer(layer)
		}
       else {
            log("==== Did not find layer")
       }
	  }
	})