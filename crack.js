(function() {
  "Command line interface for Firecracker";
  var crackName, fs, template;

  crackName = process.argv.slice(2);

  template = "Firecracker.register_group('" + crackName + "', {\n\n    template: \"\"\"\n\n    \"\"\"\n\n    style: \"\"\"\n\n    \"\"\"\n\n})";

  fs = require('fs');

  fs.writeFile("./src/cracks/" + crackName + ".coffee", template, function(err) {
    if (err) {
      return console.log(err);
    }
    return console.log("The file was saved!");
  });

}).call(this);
