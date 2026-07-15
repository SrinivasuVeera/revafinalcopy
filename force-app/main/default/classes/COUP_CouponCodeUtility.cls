public without sharing class COUP_CouponCodeUtility {

    public static final String COUPON_CODE_IS_APPLIED = ' is available for you to use with a discount of ';
    public static final String COUPON_CODE_IS_NOT_USABLE = ' is not in use or expired';
    public static final String COUPON_CODE_IS_NOT_APPLICABLE = ' is not applicable for you';
    public static final String COUPON_CODE_IS_INVALID = ' is not valid';
    public static final String ORIGINAL_APP_FEE = 'Actual Application Fee is Rs ';
    public static final String DISCOUNTED_APP_FEE = '. Discounted Application Fee is Rs ';
    public static final String PERCENTAGE = '%';
    public static final String COUPON_CODE = 'Coupon Code ';

    @InvocableMethod(label='Coupon Code Utility Invocation')
    public static List<UtilityResponse> decideByInvocation(List<UtilityRequest> utilityRequests){
        List<UtilityResponse> utilityResponses = new List<UtilityResponse>();
        UtilityRequest ur = utilityRequests[0];
        switch on ur.invocationType{
            when 'SINGLE_USE_COUPON_CREATION'{
                CreateCoupon(ur);
            }
            when 'NULLIFY_PREV_COUPON'{
                String contactId = ur.ContactId;
                removeDiscount(contactId);
            }
        }
        return utilityResponses;
    }

    public static void CreateCoupon(UtilityRequest ur) {

        Integer noOfCouponsToBeCreated = ur.noOfCouponsToBeCreated;
        Integer percent = ur.DiscountPercent;
        Date effectiveFrom = ur.EffectiveFromDate;
        Date effectiveTo = ur.EffectiveToDate;
        String Descrption = ur.Description;

        Set<String> couponCodesGenerated = new Set<String>();
        final String numerals = '1234567890';
        final String alphabets = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

        while(couponCodesGenerated.size() != noOfCouponsToBeCreated){
            String couponCode = '';
            while(couponCode.length() != 10){
                String baseCode;
                if(couponCode.length() < 5){
                    baseCode = alphabets;
                }
                else {
                    baseCode = numerals;
                }
                Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), baseCode.length());
                couponCode += baseCode.substring(idx, idx+1);
            }
                system.debug(couponCode);
                //should we fetch all the coupons and check against it as well, to make sure that coupon code is unique across all records.
                if(!couponCodesGenerated.contains(couponCode) && couponCode.length() == 10){ 
                    couponCodesGenerated.add(couponCode);
                } 
        }
            system.debug(couponCodesGenerated);


        if(couponCodesGenerated.size() == noOfCouponsToBeCreated){
            List<Coupon__C> couponRecordsToBeCreated = new List<Coupon__C>();
            for(String coupon : couponCodesGenerated){
                Coupon__c c = new Coupon__c();
                c.Coupon_Code__c = coupon;
                c.Discount_Percent__c = percent;
                c.Effective_From__c = effectiveFrom;
                c.Effective_To__c = effectiveTo;
                c.Description__c = Descrption;
                couponRecordsToBeCreated.add(c);
            }
            
            try{
                System.debug('About to insert ' + couponRecordsToBeCreated.size() + 'Coupon Records');
                insert couponRecordsToBeCreated;
            }
            catch(Exception e){
                System.debug('Exception Thrown ' + e.getMessage());
            }
        }
    }
    @AuraEnabled
    public static String validateCoupon(String enteredCouponCode, String contactId, String programId){

        String displayMessage;
        String discountMessage;
        Decimal originalAmount;

        List<Coupon__c> coupons = [Select Id, Name, Coupon_Code__c, Applicant__c, Program__c, Usable__c, 
                                    Discount_Percent__c from Coupon__C Where Coupon_Code__C = : enteredCouponCode ];
        Coupon__C retrievedCoupon ;
        Student_Fee__c studtFee = [Select id, Amount_Pending__c, Amount__c ,Amount_Paid__c,Description__c,Fee_Master__c,
                                        Fee_Master__r.Fee_Amount__c From Student_Fee__c Where Contact__c =:contactId AND Fee_Type__c='Application Fee' Limit 1];
            
            hed__Application__c applicantApplication = [Select id, Applied_Coupon__c From hed__Application__c 
                                                            Where hed__Applicant__c =:contactId Limit 1];

            Contact contact = [Select Program_Batch__c, Primary_Academic_Program__c,Program_Batch__r.hed__Account__r.Name, Application_Number__c,FirstName, LastName, 
                                Program_Batch__r.hed__Account__c,Program_Batch__r.hed__Account__r.ParentId, Program_Batch__r.Name, Assigned_Users__c
                                        from contact where id =:contactId];
            
            originalAmount=studtFee.Fee_Master__r.Fee_Amount__c;
            if(applicantApplication.Applied_Coupon__c != null){
                applicantApplication.Applied_Coupon__c = null;
                update applicantApplication;
    
                studtFee.Amount__c = originalAmount;
                studtFee.Amount_Pending__c = originalAmount; 
                studtFee.Amount_Paid__c = 0;
                studtFee.Description__c='Application Fee For ' + contact.Program_Batch__r.hed__Account__r.Name;
                update studtFee;
           }
        if(coupons.size() == 1){
            retrievedCoupon = coupons[0];
            if (retrievedCoupon != null )  {
                if(retrievedCoupon.Applicant__c != null ){
                    if(retrievedCoupon.Applicant__c == contactId){
                        if(retrievedCoupon.Usable__c == true){
                            displayMessage = 'Valid. Click on Apply';
                        }else{
                            displayMessage = COUPON_CODE + retrievedCoupon.Coupon_Code__C + COUPON_CODE_IS_NOT_USABLE;
                        }
                    }else{
                        displayMessage = COUPON_CODE + retrievedCoupon.Coupon_Code__C + COUPON_CODE_IS_NOT_APPLICABLE;
                    }
                }   else if(retrievedCoupon.Program__c != null){
                        if( retrievedCoupon.Program__c == programId){
                            if(retrievedCoupon.Usable__c == true){
                                displayMessage = 'Valid. Click on Apply';
                            }else{
                                displayMessage = COUPON_CODE + retrievedCoupon.Coupon_Code__C + COUPON_CODE_IS_NOT_USABLE;
                            }
                        } else{
                            displayMessage = COUPON_CODE + retrievedCoupon.Coupon_Code__C + COUPON_CODE_IS_NOT_APPLICABLE;
                        }
                    }   else{
                            if(retrievedCoupon.Usable__c == true){
                                displayMessage = 'Valid. Click on Apply';
                            }else{
                                displayMessage = COUPON_CODE + retrievedCoupon.Coupon_Code__C + COUPON_CODE_IS_NOT_USABLE;
                            }
                        }
            }
        } else{
            displayMessage = COUPON_CODE + enteredCouponCode + COUPON_CODE_IS_INVALID;           
        }
        return displayMessage;
    }

    @AuraEnabled
    public static List<String> applyDiscount(String enteredCouponCode, String contactId){
        Decimal discountedAmount;
        Decimal originalAmount;
        Decimal discountAppliedAmount;
        Decimal originalPendingAmount;
        Decimal discountPercent;

        List<String> returnValues = new List<String>();

        Student_Fee__c studtFee = [Select id, Amount_Pending__c, Amount__c ,Amount_Paid__c,Description__c,Fee_Master__c,
                                    Fee_Master__r.Fee_Amount__c From Student_Fee__c Where Contact__c =:contactId AND Fee_Type__c='Application Fee' Limit 1];
        
        Coupon__c coupon = [Select Id, Coupon_Code__c,Discount_Percent__c, Campaign__c, Applicant__c,Program__c	from Coupon__c 
                                        Where Coupon_Code__C = : enteredCouponCode limit 1]; 

        hed__Application__c applicantApplication = [Select id, Applied_Coupon__c From hed__Application__c 
                                                                Where hed__Applicant__c =:contactId Limit 1];

        originalAmount=studtFee.Fee_Master__r.Fee_Amount__c;
        discountPercent=coupon.Discount_Percent__c;

      /* if(applicantApplication.Applied_Coupon__c != null){
            applicantApplication.Applied_Coupon__c = null;
            update applicantApplication;

            studtFee.Amount__c = originalAmount;
            studtFee.Amount_Pending__c = originalAmount;
            studtFee.Amount_Paid__c = 0;
            studtFee.Description__c='';
            update studtFee;
       }*/
        
            discountAppliedAmount = (originalAmount *  coupon.Discount_Percent__c)/100;
            discountedAmount = originalAmount - discountAppliedAmount;
            studtFee.Amount_Paid__c=0;
            studtFee.Amount__c = discountedAmount;
            studtFee.Amount_Pending__c =discountedAmount;
            
        if(coupon.Discount_Percent__c==100){
            studtFee.Description__c='100% Discount Offered on the Coupon Code '+coupon.Coupon_Code__c+' for this Application Fee. Hence, No Payment Details related to it.';
        }
        else{
            if(coupon.Applicant__c!=null){
                studtFee.Description__c= coupon.Discount_Percent__c+'% Discount Offered on the Applicant Coupon Code '+coupon.Coupon_Code__c+' for this Application Fee.';
            }else if(coupon.Campaign__c!=null){
                studtFee.Description__c= coupon.Discount_Percent__c+'% Discount Offered on the Campaign Coupon Code '+coupon.Coupon_Code__c+' for this Application Fee.';
            }else{
                studtFee.Description__c= coupon.Discount_Percent__c+'% Discount Offered on the Program Coupon Code '+coupon.Coupon_Code__c+' for this Application Fee.';
            }
            }
            update studtFee;

        applicantApplication.Applied_Coupon__c = coupon.Id;
        system.debug(applicantApplication);
        update applicantApplication;

        String discountMessage =  ORIGINAL_APP_FEE+ originalAmount + DISCOUNTED_APP_FEE + discountedAmount ;
        system.debug(discountMessage);
        returnValues.add(discountMessage);
        returnValues.add(String.valueof(discountPercent));
        return returnValues;
    }

    public static void removeDiscount(String contactId){
        Decimal originalPendingAmount;
        Decimal originalAmount;
        Decimal originalAmountPaid;

        List<Student_Fee__c> studtFeeList = [Select id, Amount_Pending__c, Amount__c ,Amount_Paid__c,Description__c,Fee_Master__c,
                                    Fee_Master__r.Fee_Amount__c From Student_Fee__c Where Contact__c =:contactId AND Fee_Type__c='Application Fee'];
        
        hed__Application__c applicantApplication = [Select id, Applied_Coupon__c From hed__Application__c 
                                                                    Where hed__Applicant__c =:contactId Limit 1];

        Contact contact = [Select Program_Batch__c, Primary_Academic_Program__c,Program_Batch__r.hed__Account__r.Name, Application_Number__c,FirstName, LastName, 
                            Program_Batch__r.hed__Account__c,Program_Batch__r.hed__Account__r.ParentId, Program_Batch__r.Name, Assigned_Users__c
                                    from contact where id =:contactId];
        if(studtFeeList.size() > 0){
            originalAmount = studtFeeList[0].Fee_Master__r.Fee_Amount__c;
            if(applicantApplication != null){
                if(applicantApplication.Applied_Coupon__c != null){
                    applicantApplication.Applied_Coupon__c = null;  
                    update applicantApplication;
                    if(studtFeeList[0] != null){
                        studtFeeList[0].Amount__c = originalAmount;
                        studtFeeList[0].Amount_Pending__c = originalAmount;
                        studtFeeList[0].Amount_Paid__c = 0;
                        studtFeeList[0].Description__c='Application Fee For ' + contact.Program_Batch__r.hed__Account__r.Name;
                        update studtFeeList;
                    }
               }
            }
        }
   }

    public class UtilityRequest{
        @InvocableVariable(label ='No Of Coupons To Be Created')
        public Integer noOfCouponsToBeCreated;

        @InvocableVariable(label ='Discount Percent')
        public Integer DiscountPercent;

        @InvocableVariable(label ='Effective From Date')
        public Date EffectiveFromDate;

        @InvocableVariable(label ='Effective To Date')
        public Date EffectiveToDate;

        @InvocableVariable(label ='Description')
        public String Description;

        @InvocableVariable(label ='Contact Id')
        public String ContactId;


        @InvocableVariable(label ='Invocation Type')
        public String invocationType;
    }

    public class UtilityResponse{
        @InvocableVariable(label ='Message')
        public String message;
    }   
}