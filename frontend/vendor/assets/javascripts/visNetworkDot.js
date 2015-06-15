// This is the code that generates the network graph. It has been taken from the example and changed for our use.

var network = null;

function draw(urlString) {

  var dotString;

  $.ajax({
    dataType: "text",
    // url: "/synonyms/getSynonyms.json" + encodeURI('?query=' + $('#searchbox').val()),
    url: urlString,
    async: false,
    // data: ???
    success: function(result) {
      dotString = result;
    }
  });

  var data = {
  dot: 'dinetwork {' + dotString + '}'
  };

  alert('dinetwork {' + dotString + '}');

  // create a network
  var container = document.getElementById('mynetwork');
  var options = {
    stabilize: false,
    dataManipulation: true,
    onAdd: function(data, callback) {
      var span = document.getElementById('operation');
      var idInput = document.getElementById('node-id');
      var labelInput = document.getElementById('node-label');
      var saveButton = document.getElementById('saveButton');
      var cancelButton = document.getElementById('cancelButton');
      var div = document.getElementById('network-popUp');
      span.innerHTML = "Add Node";
      idInput.value = data.id;
      labelInput.value = data.label;
      saveButton.onclick = saveData.bind(this, data, callback);
      cancelButton.onclick = clearPopUp.bind();
      div.style.display = 'block';
    },
    onEdit: function(data, callback) {
      var span = document.getElementById('operation');
      var idInput = document.getElementById('node-id');
      var labelInput = document.getElementById('node-label');
      var saveButton = document.getElementById('saveButton');
      var cancelButton = document.getElementById('cancelButton');
      var div = document.getElementById('network-popUp');
      span.innerHTML = "Edit Node";
      idInput.value = data.id;
      labelInput.value = data.label;
      saveButton.onclick = saveData.bind(this, data, callback);
      cancelButton.onclick = clearPopUp.bind();
      div.style.display = 'block';
    },
    onConnect: function(data, callback) {
      if (data.from == data.to) {
        var r = confirm("Do you want to connect the node to itself?");
        if (r == true) {
          callback(data);
        }
      }
      else {
        callback(data);
      }
    }
  };
  network = new vis.Network(container, data, options);

  // add event listeners
  network.on('select', function(params) {
    document.getElementById('selection').innerHTML = 'Selection: ' + params.nodes;
  });

  network.on("resize", function(params) {
    console.log(params.width, params.height)
  });

  function clearPopUp() {
    var saveButton = document.getElementById('saveButton');
    var cancelButton = document.getElementById('cancelButton');
    saveButton.onclick = null;
    cancelButton.onclick = null;
    var div = document.getElementById('network-popUp');
    div.style.display = 'none';

  }

  function saveData(data, callback) {
    var idInput = document.getElementById('node-id');
    var labelInput = document.getElementById('node-label');
    var div = document.getElementById('network-popUp');
    data.id = idInput.value;
    data.label = labelInput.value;
    clearPopUp();
    callback(data);

  }
}