global class CustomHttpCalloutMockMargenesMB implements HttpCalloutMock {
    HttpResponse mockResponse;
    
    global CustomHttpCalloutMockMargenesMB(HttpResponse mockResponse) {
        this.mockResponse = mockResponse;
    }
    
    global HttpResponse respond(HTTPRequest req) {
        return mockResponse;
    }
}