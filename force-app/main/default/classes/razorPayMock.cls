@isTest
global class razorPayMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"accept_partial":false,"amount":23000000,"amount_paid":0,"callback_method":"get","callback_url":"https://reva-university--couat1908.sandbox.my.salesforce-sites.com/RazorPayPGResponse","cancelled_at":0,"created_at":1655732878,"currency":"INR","customer":{"contact":"9398044427","email":"vinodh@epeoplebc.com","name":"Vinodh Kumar"},"description":"Academic Fee,Academic Fee,","expire_by":1671544078,"expired_at":0,"first_min_partial_amount":0,"id":"plink_Jjlr34Ux4WW2UQ","notes":{"paymentType":"FeePayment"},"notify":{"email":true,"sms":true},"payments":null,"reference_id":"2078684829","reminder_enable":true,"reminders":[],"short_url":"https://rzp.io/i/vhJ8KTT9dL","status":"created","updated_at":1655732878,"upi_link":false,"user_id":""}');
        response.setStatusCode(200);
        return response; 
    }
}