//---read through json file-----
var fs = require('fs');
var file = __dirname + '/error.json';

var fs = require('fs');
var file = __dirname + '/error.json';
var jdata;
var datafs = fs.readFile(file, function (err, data) {

    if (err) {
        throw err;
    }
    //    processFile(data);

    jdata = JSON.parse(data);

    //create the JSON object
    jsonObject = JSON.stringify(jdata);


    // prepare the header
    var postheaders = {
        'Content-Type':'application/json',
        'Content-Length':Buffer.byteLength(jsonObject, 'utf8')
    };

    // the post options
    var optionspost = {
        host:'stage106.weboapps.com',
        path:'/api/v1/error_reports',
        method:'POST',
        headers:postheaders
    };

    console.info('Options prepared:');
    console.info(optionspost);
    console.info('Do the POST call');

    // do the POST call
    var reqPost = http.request(optionspost, function (res) {
        console.log("statusCode: ", res.statusCode);
        console.log("headers: ", res.headers);

        res.on('data', function (d) {
            console.info('POST result:\n');
            //         process.stdout.write(d);
            console.info(d);
            console.info('\n\nPOST completed');
            console.log("[Project-106] Exception Reported to Project-106 server");
        });
    });

    // write the json data
    reqPost.write(jsonObject);
    reqPost.end();
    // handle error
    reqPost.on('error', function (e) {
        console.log("[Project-106] Error while reporting exception to project-106 in node support");
        console.error(e);
        //        console.error(jsonObject);
    })
    return data;
});
 
