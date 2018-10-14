// documentation: https://developer.sketchapp.com/reference/api/

var Sketch = require('sketch')
var Document = require('sketch/dom').Document

  log(context.documentPath)


  var documentURL = NSURL.fileURLWithPath(context.documentPath)

  log(documentURL)

	Document.open(documentURL, (err, document) => {
	// Document.open(context.documentPath, (err, document) => {		
	  if (err) {
	    // oh no, we failed to open the document
	    Sketch.UI.message("Error opening doc!!")
	  }
	  else {
        log("==== Found File")
		// var layer = document.getLayerWithID('EEA2C7E0-C57D-4130-8463-18A78EE5E525')
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