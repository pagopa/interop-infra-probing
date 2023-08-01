function handler(event) {
    var request = event.request;
    
    if (!request.uri.includes('.'))
        request.uri = '/index.html';

    return request;
}