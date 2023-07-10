const AWS = require('aws-sdk');

exports.handler = function(event, context, callback) {

    const bucket = process.env.S3_BUCKET;    
    const key = process.env.KID;
    
    const s3 = new AWS.S3();
    return s3.getObject({Bucket: bucket, Key: key},
       function(err, data) {

            if (err) {
                return err;
            }

            var isBase64Encoded = false;
            const encoding = 'utf8';            
   
            var resp = {
                statusCode: 200,
                headers: {
                    'Content-Type': data.ContentType,
                },
                body: new Buffer(data.Body).toString(encoding),
                isBase64Encoded: isBase64Encoded
            };

            callback(null, resp);
        }
    );
};