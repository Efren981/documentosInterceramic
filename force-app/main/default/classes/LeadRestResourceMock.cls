@isTest
global class LeadRestResourceMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        String responseJson = '[{"success":true,"errors":[]}]';
        HTTPResponse response = new HTTPResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(responseJson);
        response.setStatusCode(200);
        return response;
    }
}