import sketch from 'sketch'
// documentation: https://developer.sketchapp.com/reference/api/

var Document = require('sketch/dom').Document

export default function() {
    sketch.UI.message("It's alive 🙌")

	sketch.UI.message(context.documentPath)
	// sketch.UI.message(context.layerId)

	Document.open("/Users/hanonno/Design/Hanno/NRC-Times.sketch", (err, document) => {
	// Document.open(context.path, (err, document) => {
	  if (err) {
	    // oh no, we failed to open the document
	    sketch.UI.message("Error opening doc!!")
	  }
	  else {
	    sketch.UI.message("Foud doc?S!!")	

		// var layer = document.getLayerWithID('EEA2C7E0-C57D-4130-8463-18A78EE5E525')
		// var layer = document.getLayerWithID('575891A9-3FAD-45D5-884C-9E76F1337ED7')
		var layer = document.getLayerWithID(context.layerId)
		
		if (layer) {
			sketch.UI.message("Found layer!")
			document.centerOnLayer(layer)
		}
		else {
			sketch.UI.message("Did not find layer")
		}
	  }
	})
}
