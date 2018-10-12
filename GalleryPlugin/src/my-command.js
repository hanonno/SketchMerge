import sketch from 'sketch'
// documentation: https://developer.sketchapp.com/reference/api/

var Document = require('sketch/dom').Document

export default function() {
    sketch.UI.message("It's alive 🙌")

    Document.open("/Users/hanonno/Design/Hanno/NRC-Times.sketch", (err, document) => {
	// Document.open(context.path, (err, document) => {
	  if (err) {
	    // oh no, we failed to open the document
	    sketch.UI.message("Error opening doc!!")
	  }
	  else {
	    sketch.UI.message("Foud doc?S!!")	
	  }
	})
}
