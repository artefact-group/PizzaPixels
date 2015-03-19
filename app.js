var express = require('express'),
app         = express(),
http        = require('http');


app.use(express.static(__dirname + "/pixelator_v1.framer/"));

app.get('/', function(req, res) {});

http.createServer(app).listen(3000);
