import authMapping from './mapping.json' assert { type: 'json' };

export const handler =  function(event, context, callback) {
    console.log("Getting payload")
    var encodedPayload = event.headers.Authorization.split(' ')[1].split('.')[1];
    console.log("Decoding payload")
    encodedPayload = atob(encodedPayload);
    console.log("Parsing JSON payload")
    var payload = JSON.parse(encodedPayload);
    console.log(payload);
    
    const method = event.httpMethod;
    const resource = event.resource;
    const groups = payload["cognito:groups"];
    
    console.log("Checking authorization")
    for (const group of groups) {
        console.log(group)
        var isAuthorized = getAuthorization(group,resource,method)
        if (isAuthorized) {
            break;
        }
    }
    console.log("Generating authorization policy")
    switch(isAuthorized) {
        case true:
            callback(null, generatePolicy( 'Allow', event.methodArn));
            break;
        case false:
            callback(null, generatePolicy('Deny', event.methodArn));
            break;
        default:
            callback("Unauthorized");
    }
        
};


function getAuthorization(group,resource,method) {
    
    return ( Object.keys(authMapping).includes(group) ) && 
           ( Object.keys(authMapping[group]).includes(resource) ) && 
           ( authMapping[group][resource].includes(method) );
}



var generatePolicy = function(effect, resource) {
    var authResponse = {};
    
    if (effect && resource) {
        var policyDocument = {};
        policyDocument.Version = '2012-10-17'; 
        policyDocument.Statement = [];
        var statementOne = {};
        statementOne.Action = 'execute-api:Invoke'; 
        statementOne.Effect = effect;
        statementOne.Resource = resource;
        policyDocument.Statement[0] = statementOne;
        authResponse.policyDocument = policyDocument;
    }
    
    return authResponse;
}