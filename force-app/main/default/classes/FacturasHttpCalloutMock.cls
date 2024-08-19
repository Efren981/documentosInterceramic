@isTest
global class FacturasHttpCalloutMock implements HttpCalloutMock{
	protected Integer statusCode;
    protected String status;
    protected String response;
    protected Map<String, String> responseHeaders;
    //protected CCP_AccessToken__c access;
    public FacturasHttpCalloutMock(MockParameters parameters) {
        this.statusCode = parameters.statusCode;
        this.status = parameters.status;
        this.response = parameters.response;
        this.responseHeaders = parameters.responseHeaders;
        //this.access =ccp_TestDataFactory_cls.crearConfiguracionAccess();
    }
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        res.setBody(this.response);
        res.setStatusCode(this.statusCode);
        res.setStatus(this.status);
        return res;
    }
    public  class MockParameters {
        public Map<String, String> responseHeaders {get; set;}
        public String response {get; set;}
        public String status {get; set;}
        public Integer statusCode {get; set;}
    }
}