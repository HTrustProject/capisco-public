//Todo: remove readable param and legacy code that depends on ids
function getSenses(symbol, callback) {
	var sensesUrl = encodeURI("/links/senses.json?readable=true&name=" + symbol);
	$.ajax({url: sensesUrl, async: false, success: callback});
};

function getMappings(symbol, callback) {
	var sensesUrl = encodeURI("/links/mappings.json?name=" + symbol);
	$.ajax({url: sensesUrl, async: false, success: callback});
}

function getInlinks(concept, callback) {
	var synmapsUrl = encodeURI("/links/synmaps.json?id=" + concept.id);
	$.ajax({url: synmapsUrl, async: false, success: callback});
}

function getOutlinks(concept, callback) {
	var keymapsUrl = encodeURI("/links/keymaps.json?id=" + concept.id);
	$.ajax({url: keymapsUrl, async: false, success: callback});
}

//Returns a list of synonyms as strings, not concepts, to the callback
function getSynonyms(concept, callback) {
	var synonymsUrl = encodeURI("/links/synonyms.json?id=" + concept.id);
	$.ajax({url: synonymsUrl, async: false, success: callback});
}

function getContexts(symbol, callback) {
	var contextsUrl = encodeURI("/links/contexts.json?name=" + symbol);
	$.ajax({url: contextsUrl, async: false, success: callback});
}
