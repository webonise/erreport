var http = require('http');

// catch the data from command line argument
var data = process.argv[2]

// parsing data
jdata = JSON.parse(data);

// create the JSON object
jsonObject = JSON.stringify(jdata);

// prepare the header
var postheaders = {
    'Content-Type' : 'application/json',
    'Content-Length' : Buffer.byteLength(jsonObject, 'utf8')
};

// the post options
var optionspost = {
    host : 'beta.erreport.io',
    path : '/api/v1/error_reports',
    method : 'POST',
    headers : postheaders
};

console.info('Options prepared:');
console.info(optionspost);
console.info('Do the POST call');

// do the POST call
var reqPost = http.request(optionspost, function(res) {
    console.log("statusCode: ", res.statusCode);
    console.log("headers: ", res.headers);
 
    res.on('data', function(d) {
        console.info('POST result:\n');
        data = JSON.parse(d)
        console.error('\n[Project-106] Response status');
        console.error(data['status']);
        console.error('\n[Project-106] Response Message');
        console.error(data['message']);
        console.info('\n\nPOST completed');
        console.error("\n\n[Project-106] Exception Reporting Finished to Project-106 server using node js");
    });
});
 
// write the json data
reqPost.write(jsonObject);
reqPost.end();
// handle error
reqPost.on('error', function(e) {
    console.error("[Project-106] Error while reporting exception to project-106 in node support");
    console.error(e);
});