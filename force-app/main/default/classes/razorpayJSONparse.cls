public class razorpayJSONparse{
    public String account_id;   //acc_J7LjT9AYniLrwI
    public list<string> contains; // cls_contains[] contains;
    public Integer created_at;  //1669680554
    public String entity;   //event
    public String event;    //payment_link.paid
    public cls_payload payload;
    public class cls_payload {
        public cls_order order;
        public cls_payment payment;
        public cls_payment_link payment_link;
    }
    public class cls_order {
        public cls_entity1 entity;
    }
    public class cls_entity1 {
        public Integer amount;  
        public Integer amount_due;
        public Integer amount_paid;  
        public Integer attempts;
        public Integer created_at;
        public String ccurrency;
        public String entity;
        public String id;
        public cls_notes notes;
        public String offer_id;
        public String receipt;
        public String status;
    }    
    public class cls_notes {
        public String paymentType;
        public String reference_id;  
    }
    public class cls_payment {
        public cls_entity2 entity;
    }
    public class cls_entity2 {
        public cls_acquirer_data acquirer_data;
        public Integer amount;  
        public Integer amount_refunded;
        public Integer amount_transferred;  
        public Integer authorized_at;
        public boolean auto_captured;
        public String bank;
        public Integer base_amount;
        public boolean captured;
        public Integer captured_at;
        public cls_card card;
        public String card_id;
        public String contact;
        public Integer created_at;
        public String ccurrency;
        public String description;
        public String email;
        public String entity;
        public String error_code;
        public String error_description;
        public Integer fee;
        public String fee_bearer;
        public String id;
        public boolean international;
        public String invoice_id;
        public boolean late_authorized;
        public String method;
        public cls_notes notes;
        public String order_id;
        public String refund_status;
        public String status;
        public String tax;
        public String vpa;
        public String wallet;
    }   
    public class cls_acquirer_data {
        public String auth_code;    
    }    
    public class cls_card {
        public boolean emi;
        public String entity;   //card
        public String id;   //card_KleSnsWw1GJrau
        public boolean international;
        public string issuer;
        public String last4;    //1111
        public String name; //
        public String network;  //Visa
        public String sub_type; //consumer
        public string token_iin;
        public String type; //debit
    }    
    public class cls_payment_link {
        public cls_entity entity;
    }
    public class cls_entity {
        public boolean accept_partial;
        public Integer amount;  
        public Integer amount_paid; 
        public String callback_method;  
        public String callback_url; 
        public Integer cancelled_at;   
        public Integer created_at;  
        public String ccurrency; 
        public cls_customer customer;
        public String description; 
        public Integer expire_by;   
        public Integer expired_at;  
        public Integer first_min_partial_amount;    
        public String id;   
        public cls_notes notes;
        public cls_notify notify;
        public String order_id; 
        public String reference_id; 
        public boolean reminder_enable;
        public cls_reminders reminders;
        public String short_url;    
        public String status;   
        public Integer updated_at;  
        public boolean upi_link;
        public String user_id;  
    }
    public class cls_customer {
        public String contact;  
        public String email;    
        public String name; 
    }
    public class cls_notify {
        public boolean email;
        public boolean sms;
        public boolean whatsapp;
    }
    public class cls_reminders {
        public String status;  
    }
    public static razorpayJSONparse parse(String json){
        return (razorpayJSONparse) System.JSON.deserialize(json, razorpayJSONparse.class);
    }
}