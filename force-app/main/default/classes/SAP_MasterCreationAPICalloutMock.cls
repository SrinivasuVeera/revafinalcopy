@isTest
global class SAP_MasterCreationAPICalloutMock implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest request) 
    {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        //response.setBody('[ {"SFDCRecordId": "0011s00001lkJ0yAAE", "statusCode": "0","statusMessage": "Success","SAPID": "null","responseObject": "costCenter is Created Successfully In Dimenssion 1, SAP Code A00136 created." }]');
        string body ='{"Response":[{"SFDCRecordId":"0015j00000etbOMAAY","statusCode":0,"statusMessage":"Success","SAPID":"C0035","responseObject":"CostCenter Is Created Successfully In Dimenssion 3, SAP Code C0035 created."},{"SFDCRecordId":"0015j00000etbPSAAY","statusCode":1,"statusMessage":"Success","SAPID":"C0036","responseObject":"CostCenter Is Created Successfully In Dimenssion 3, SAP Code C0036 created."}]}';
        response.setBody(body);
        response.setStatusCode(200);
        return response; 
    } 
}