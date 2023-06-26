const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');


const keyClient = jwksClient({
    cache: true,
    cacheMaxAge: 86400000,
    rateLimit: true,
    jwksRequestsPerMinute: 10,
    strictSsl: true,
    jwksUri: process.env.JWKS_URI
})

function getSigningKey (header = decoded.header, callback) {
    keyClient.getSigningKey(header.kid, function(err, key) {
        const signingKey = key.publicKey || key.rsaPublicKey;
        callback(null, signingKey);
    })
}

exports.handler =  function(event, context, callback) {

    console.log("Getting payload")
    var token = event.headers.Authorization.split(' ')[1];
    
    console.log("Generating authorization policy")

    jwt.verify(token, getSigningKey, {"algorithms": ["RS256"]}, function (error) {
        var decoded = jwt.decode(token);
        console.log(decoded)
        if (error) {
            callback(null, generatePolicy('Deny', event.methodArn));
            console.log(`${decoded.payload.jti} NOT allowed to perform the API call`)
        } else {
            callback(null, generatePolicy( 'Allow', event.methodArn));
            console.log(`${decoded.payload.jti} NOT allowed to perform the API call`)
        }
    })

        
};


var generatePolicy = function(effect, resource) {
    
        var policyDocument = {
            "Version" : "2012-10-17",
            "Statement":[
                {
                    "Action":"execute-api:Invoke",
                    "Effect":effect,
                    "Resource":resource
                }
            ]
        };

    var authResponse = {
        "policyDocument":policyDocument
    };
    
    return authResponse;
}