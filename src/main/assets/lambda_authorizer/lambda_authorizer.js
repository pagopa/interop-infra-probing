const authMapping = JSON.parse(process.env.ROLE_MAPPING)

export const handler =  function(event, context, callback) {

    console.log("Getting payload")
    var encodedPayload = event.headers.Authorization.split(' ')[1].split('.')[1];
    console.log("Decoding payload")
    var decodedPayload = atob(encodedPayload);
    console.log("Parsing JSON payload")
    var payload = JSON.parse(decodedPayload);

    const method = event.httpMethod;
    const resource = event.resource;
    const groups = payload["cognito:groups"];
    
    console.log("Checking authorization")
    var isAuthorized = groups.some( (x) => getAuthorization(x,resource,method) )
    
    console.log("Generating authorization policy")

    if (isAuthorized) {
        callback(null, generatePolicy( 'Allow', event.methodArn));
        console.log("User allowed to perform the API call")
    } else {
        callback(null, generatePolicy('Deny', event.methodArn));
        console.log("User NOT allowed to perform the API call")
    }
        
};


function getAuthorization(group,resource,method) {
    
    return ( Object.keys(authMapping).includes(group) ) && 
           ( Object.keys(authMapping[group]).includes(resource) ) && 
           ( authMapping[group][resource].includes(method) );
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