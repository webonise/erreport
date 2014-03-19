var http = require('http');
var jdata;

// catch the data from command line argument
var data = process.argv[2]

// parsing data
jdata = JSON.parse(data);
//console.log(jdata);

var serverHost = 'beta.erreport.io';
var serverPath = '/api/v1/error_reports';

delete jdata['host_path'];

//create the JSON object
jsonObject = JSON.stringify(jdata);
// prepare the header
var postheaders = {
    'Content-Type':'application/json',
    'Content-Length':Buffer.byteLength(jsonObject, 'utf8')
};

// the post options
var optionspost = {
    host:serverHost,
    path:serverPath,
    method:'POST',
    headers:postheaders
};

console.info('Options prepared:');
console.info(optionspost);
console.info('Do the POST call');

// do the POST call
var reqPost = http.request(optionspost, function (res) {
    var output = '';

    res.on('data', function (chunk) {
        output += chunk;
    });

    res.on('end', function () {
        var obj = JSON.parse(output);
        if (obj['status'] == true) {
            console.error('Error reported to project-106');
            console.error('Response:' + obj['message']);
        } else {
            console.error('Error While reporting exception to project-106');
            console.error('Response:' + obj['message']);
        }
    });

});

// write the json data
reqPost.write(jsonObject);
reqPost.end();
// handle error
reqPost.on('error', function (e) {
    console.error("[Project-106] Error while reporting exception to project-106 in node support");
    console.error(e);
});