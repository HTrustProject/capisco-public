
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
	this.synonymsVisible = false;
	this.sensesVisible = false;
};

Symbol = function(symbol, options) {
	this.id = symbol;
	this.label = symbol;
	this.group = 'symbols';
	this.anchor = false;
	this.sensesVisible = false;
	this.contextsVisible = false;
};

Sense = function(symbol, concept) {
	this.from = symbol.id;
	this.to = concept.id;
};

Context = function(symbol, concept) {
	this.to = symbol.id;
	this.from = concept.id;
};

var EdgePrototype = {
	contains: function(node) {
		return this.to == node.id || this.from == node.id;
	},
	equivalent: function(edge) {
		return (this.to == edge.to && this.from == edge.from)
			|| (this.to == edge.from && this.from == edge.to);
	}
};

Sense.prototype = EdgePrototype;
Context.prototype = EdgePrototype;

ConceptMap = function(container) {
	this.nodes = new vis.DataSet({});
	this.edges = new vis.DataSet({});
	this.data = {nodes: this.nodes, edges: this.edges };
	
	// A sample of the styles that can be applied
	// Full documentation at: visjs.org/docs
	// Mainly interested in Network
	var symbols = { shape: 'box', fontColor: 'black', fontSize: 15};
	symbols.color = { border: '#666666', background: '#ffa341', highlight: { border: '#c15215', background: '#ffa341' } };
	var concepts = { shape: 'ellipse', fontColor: 'black', fontSize: 15};
	concepts.color = { border: '#333333', background: '#f07b00', highlight: { border: '#c15215', background: '#f07b00' } };
	
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
				var edge = new Sense(symbol, node);
				self.addNode(node);
				self.addEdge(edge);
			}
			symbol.sensesVisible = true;
			self.nodes.update(symbol);
		});
	};
	
	this.showContexts = function(symbol) {
		var self = this;
		getContexts(symbol.id, function(concepts){
			for (var index in concepts) {
				var concept = concepts[index];
				var node = new Concept(concept);
				var edge = new Context(symbol, node);
				self.addNode(node);
				self.addEdge(edge);
			}
			symbol.contextsVisible = true;
			self.nodes.update(symbol);
		});
	};
	
	this.showSynonyms = function(concept) {
		var self = this;
		getSynonyms(concept.concept, function(symbols){
			for (var index in symbols) {
				var symbol = symbols[index];
				var node = new Symbol(symbol);
				var edge = new Sense(node, concept);
				self.addNode(node);
				self.addEdge(edge);
			}
			concept.synonymsVisible = true;
			self.nodes.update(concept);
		});
	};
	
	//TODO: Refactor common code
	this.hideSenses = function(symbol) {
		function filter(edge) { return edge.from == symbol.id; }
		var edges = this.edges.get({ filter: filter });
		var edgeIds = edges.map(function(edge) { return edge.id; });
		var nodeIds = edges.map(function(edge) { return edge.to; });
		var nodes = this.nodes.get(nodeIds);
		var looseNodes = nodes.filter(function(node) { return !node.anchor; });
		var looseNodeIds = looseNodes.map(function(node) { return node.id; });
		this.nodes.remove(looseNodeIds);
		this.edges.remove(edgeIds);
		symbol.sensesVisible = false;
		this.nodes.update(symbol);
	};
	
	//TODO: Refactor common code
	this.hideContexts = function(symbol) {
		function filter(edge) { return edge.to == symbol.id; }
		var edges = this.edges.get({ filter: filter });
		var edgeIds = edges.map(function(edge) { return edge.id; });
		var nodeIds = edges.map(function(edge) { return edge.from; });
		var nodes = this.nodes.get(nodeIds);
		var looseNodes = nodes.filter(function(node) { return !node.anchor; });
		var looseNodeIds = looseNodes.map(function(node) { return node.id; });
		this.nodes.remove(looseNodeIds);
		this.edges.remove(edgeIds);
		symbol.contextsVisible = false;
		this.nodes.update(symbol);
	};
	
	//TODO: Refactor common code
	this.hideSynonyms = function(concept) {
		function filter(edge) { return edge.to == concept.id; }
		var edges = this.edges.get({ filter: filter });
		var edgeIds = edges.map(function(edge) { return edge.id; });
		var nodeIds = edges.map(function(edge) { return edge.from; });
		var nodes = this.nodes.get(nodeIds);
		var looseNodes = nodes.filter(function(node) { return !node.anchor; });
		var looseNodeIds = looseNodes.map(function(node) { return node.id; });
		this.nodes.remove(looseNodeIds);
		this.edges.remove(edgeIds);
		concept.synonymsVisible = false;
		this.nodes.update(concept);
	};
	
	this.removeNode = function(node) {
		function filter(edge) { return edge.contains(node); }
		function map(edge) { if (edge.to == concept.id) return edge.from; else return edge.to; }
		var edges = this.edges.get({ filter: filter });
		var edgeIds = edges.map(function(edge) { return edge.id; });
		var nodeIds = edges.map(map);
		var nodes = this.nodes.get(nodeIds);
		var looseNodes = nodes.filter(function(node) { return !node.anchor; });
		var looseNodeIds = looseNodes.map(function(node) { return node.id; });
		this.nodes.remove(looseNodeIds);
		this.edges.remove(edgeIds);
		concept.synonymsVisible = false;
		this.nodes.update(concept);
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