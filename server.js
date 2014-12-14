var express = require('express');
var app = express();

app.set('port', (process.env.PORT || 5000));
app.use(express.static(__dirname + '/target/'));

// app.get('/', function(request, response) {
//   response.send('Hello World!');
// });

app.listen(app.get('port'));
