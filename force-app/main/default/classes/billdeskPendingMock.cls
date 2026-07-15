@isTest
global class billdeskPendingMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('0130|BD9MAIN|null|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|0300|NA|NA|NA|NA|NA|NA|NA|NA|NA|Transaction not found|NA|NA|NA|NA|NA|Y|9EA648550C75EAF83D3C0D4EFC46790B754716458BE1D64FD95E63FC23D1AD5B');
        response.setStatusCode(200);
        return response; 
    }
}