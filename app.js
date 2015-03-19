var express = require('express'),
app         = express();
process.env.PWD = process.cwd();

app.use(express.static(process.env.PWD + "/pixelator_v1.framer/"));

app.listen(process.env.PORT || 3000);
