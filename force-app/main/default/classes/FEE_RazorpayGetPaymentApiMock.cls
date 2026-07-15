@isTest
global class FEE_RazorpayGetPaymentApiMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"id":"pay_Jk32Ifif8C4F1E","entity":"payment","amount":15050000,"currency":"INR","status":"captured","order_id":"order_Jk329IsRSoJYHI","invoice_id":null,"international":false,"method":"card","amount_refunded":0,"refund_status":null,"captured":true,"description":"#Jk324b1KpMbStT","card_id":"card_JflbbiD6wppRDt","bank":null,"wallet":null,"vpa":null,"email":"thogatiudaybhaskar54@gmail.com","contact":"+916303564715","token_id":"token_JflbblCuutmK7F","notes":{"paymentType":"FeePayment"},"fee":0,"tax":0,"error_code":null,"error_description":null,"error_source":null,"error_step":null,"error_reason":null,"acquirer_data":{"auth_code":"358212"},"created_at":1655793385,"authorized_at":1655793389,"auto_captured":true,"captured_at":1655793389,"late_authorized":false}');
        response.setStatusCode(200);
        return response; 
    }
}