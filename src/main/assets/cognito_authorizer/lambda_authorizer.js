
const authMapping = JSON.parse(process.env.ROLE_MAPPING)

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
        if (error) {
            callback(null, generatePolicy('Deny', event.methodArn));
            console.log(`${decoded.jti} NOT verified jwt to perform the API call`)
        } else {
            var method = event.httpMethod;
            var resource = event.resource;
            var groups = decoded["cognito:groups"];
            
            console.log("Checking authorization")
        
            var isAuthorized = groups.some( (x) => getAuthorization(x,resource,method) )
            
            console.log("Generating authorization policy")
        
            if (isAuthorized) {
                callback(null, generatePolicy( 'Allow', event.methodArn));
                console.log(`User ${payload["cognito:username"]} allowed to perform the API call`)
            } else {
                callback(null, generatePolicy('Deny', event.methodArn));
                console.log(`User ${payload["cognito:username"]} NOT allowed to perform the API call`)        
            }
        }
    })

        
};

function matchPath(mapping_path,resource,method,group) {
    
    return ( ( resource.includes(mapping_path) ) && (authMapping[group][mapping_path].includes(method)) ) ;
}

exports.handler =  function(event, context, callback) {

    console.log("Getting payload")
    var encodedPayload = event.headers.Authorization.split(' ')[1].split('.')[1];
    console.log("Decoding payload")
    var decodedPayload = atob(encodedPayload);
    console.log("Parsing JSON payload")
    var payload = JSON.parse(decodedPayload);




        
};


function getAuthorization(group,resource,method) {
    return ( Object.keys(authMapping).includes(group) ) && 
           ( Object.keys(authMapping[group]).some( (x) => matchPath(x,resource,method,group)) );
}



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