
/* IMPORTANT: These comments are used by the preprocessor to include the files - do not remove
//= require vis
//= require vis.min
//= require visNetwork
//= require visNetworkDot

//= require links

/*----------TERMINOLOGY------------*/
//	Sense		: an edge FROM a symbol TO a concept
//	Context		: an edge TO a symbol FROM a concept
//	Concept		: a concept, with a name, description, and unique id
//	Symbol		: a short word or sentence, with no extra data associated
/*---------------------------------*/

Concept = function(concept, options) {
	var nameLines = getLines(concept.name, 20);
	var titleLines = getSentences(concept.description);
	
	this.concept = concept;
	this.id = concept.id;
	this.label = nameLines.join("\n");
	this.title = titleLines[0].substring(0, 80);
	this.group = 'concepts';
	this.anchor = false;
};

Symbol = function(symbol, options) {
	this.id = symbol;
	this.label = symbol;
	this.group = 'symbols';
	this.anchor = false;
};

Sense = function(symbol, concept) {
	this.from = symbol.id;
	this.to = concept.id;
};

Context = function(symbol, concept) {
	this.to = symbol.id;
	this.from = concept.id;
};

ConceptMap = function(container) {
	this.nodes = new vis.DataSet({});
	this.edges = new vis.DataSet({});
	this.data = {nodes: this.nodes, edges: this.edges };
	
	// A sample of the styles that can be applied
	// Full documentation at: visjs.org/docs
	// Mainly interested in Network
	var symbols = { shape: 'box', fontColor: 'black', fontSize: 18};
	symbols.color = { border: 'black', background: 'orange', highlight: { border: 'yellow', background: 'red' } };
	var concepts = { shape: 'ellipse', fontColor: 'black', fontSize: 18};
	concepts.color = { border: 'black', background: 'orange', highlight: { border: 'yellow', background: 'red' } };
	
	var groups = { symbols: symbols, concepts: concepts};
	var edges = { style: 'arrow' };
	
	this.options = {groups: groups, edges: edges };
	
	this.network = new vis.Network(container, this.data, this.options);
	
	this.addEdge = function(edge) {
		var options = {};
		options.filter = function(existing) { return edge.from == existing.from && edge.to == existing.to; };
		var matches = this.edges.get(options);
		if (matches.length == 0)
			this.edges.add(edge);
		else
			console.log("Edge from " + edge.from + " to " + edge.to + " already exists, not adding to dataset.");
	};
	
	this.addNode = function(node) {
		var existing = this.nodes.get(node.id);
		if (existing == null)
			this.nodes.add(node);
		else
			console.log("Node " + node.id + " already exists, not adding to dataset.");
	};
	
	this.showSenses = function(symbol) {
		var self = this;
		getSenses(symbol.id, function(concepts){
			for (var index in concepts) {
				var concept = concepts[index];
				var node = new Concept(concept);
				self.addNode(node);
				var edge = new Sense(symbol, node);
				self.addEdge(edge);
			}
		});
	};
	
	this.showContexts = function(symbol) {
		var self = this;
		getContexts(symbol.id, function(concepts){
			for (var index in concepts) {
				var concept = concepts[index];
				var node = new Concept(concept);
				self.addNode(node);
				var edge = new Context(symbol, node);
				self.addEdge(edge);
			}
		});
	};
	
	this.showSynonyms = function(concept) {
		var self = this;
		getSynonyms(concept.concept, function(symbols){
			for (var index in symbols) {
				var symbol = symbols[index];
				var node = new Symbol(symbol);
				self.addNode(node);
				var edge = new Sense(node, concept);
				self.addEdge(edge);
			}
		});
	};
	
	this.collapse = function() {
		var nodes = this.nodes.get();
		var freeNodes = nodes.filter(function(node) { return !node.anchor; });
		var freeNodeIds = freeNodes.map(function(node) { return node.id; });
		this.nodes.remove(freeNodeIds);
		
		var edges = this.edges.get();
		var freeEdges = edges.filter(function(edge) {
			var toIndex = freeNodeIds.indexOf(edge.to);
			var fromIndex = freeNodeIds.indexOf(edge.from);
			return toIndex >= 0 || fromIndex >= 0;
		});
		
		var freeEdgeIds = freeEdges.map(function(edge) { return edge.id; });
		this.edges.remove(freeEdgeIds);
	};
};
