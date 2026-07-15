@RestResource(urlMapping='/AdmissionsOrg/lead/submit')
global with sharing class AdmissionsUnifiedLeadAPIOrg {
    
    private static final Integer OTP_EXPIRY_MINUTES = 10;
    
    // =======================
    // MAIN ENTRY
    // =======================
    @HttpPost
    global static ResponseWrapper submit() {
        try {
            String rawBody = RestContext.request.requestBody.toString();
            System.debug('RAW BODY => ' + rawBody);
            
            RequestWrapper req =
                (RequestWrapper) JSON.deserialize(rawBody, RequestWrapper.class);
            
            if (String.isBlank(req.action)) {
                return error('INVALID_REQUEST', 'Action is required');
            }
            
            if (req.action == 'VERIFY_EMAIL') {
                return handleEmailOtp(req);
            }
            if (req.action == 'VERIFY_EMAIL_OTP') {
                return verifyEmailOtp(req);
            }
            if (req.action == 'RESEND_EMAIL_OTP') {
                return resendEmailOtp(req);
            }
            if (req.action == 'SEND_MOBILE_OTP') {
                return sendMobileOtp(req);
            }
            if (req.action == 'VERIFY_MOBILE_OTP') {
                return verifyMobileOtp(req);
            }
            if (req.action == 'RESEND_MOBILE_OTP') {
                return resendMobileOtp(req);
            }
            if (req.action == 'COMPLETE_REGISTRATION') {
                return completeRegistration(req);
            }
            if (req.action == 'FINAL_SUBMIT') {
                return finalSubmit(req);
            }
            
            return error('INVALID_ACTION', 'Unsupported action');
            
        } catch (Exception e) {
            return error('ERROR', e.getMessage());
        }
    }
    
    // =======================
    // EMAIL OTP FLOW
    // =======================
    
    private static ResponseWrapper handleEmailOtp(RequestWrapper req) {
        
        // 🔹 FIRST: Check Contact
        Contact con = findContactByEmail(req.email);
        if (con != null) {
            
            generateContactRevisitOtp(con);
            update con;
            
            // Same sender method
            sendEmailRevisitOtpContact(con.Id);
            
            return success(
                'OTP_SENT',
                'Revisit OTP sent to contact successfully',
                con.Id
            );
        }
        
        
        Lead lead = findByEmail(req.email);
        //  Boolean isNew = false;
       /* system.debug('req.utmSource:'+req.utmSource);
        system.debug('req.utmMedium:'+req.utmMedium);
        if (lead == null) {
            lead = new Lead(
                FirstName = req.firstName,
                LastName  = String.isBlank(req.lastName) ? 'Student' : req.lastName,
                Company   = 'Individual',
                Status    = 'Unverified',
                Email     = req.email,
                LeadSource = req.utmSource,
                UTM_Source__c   = req.utmSource,
                UTM_Medium__c   = req.utmMedium,
                UTM_Campaign__c = req.utmCampaign
            );
            generateEmailOtp(lead);
            insert lead;
            
            sendEmailOtp(lead.Id);
            
            return success(
                'OTP_SENT',
                'Email OTP sent successfully',
                lead.Id
            );

          }*/
        if (lead == null) {
            
            return error(
                'APPLICANT_NOT_FOUND',
                'Applicant is not available. Please try with new registration.'
            );
        }
        else{
            // generateLeadsRevisitOtp(lead);
            //update lead;
            
            sendEmailOtp(lead.Id);
            
            return success(
                'OTP_SENT',
                'Email OTP sent to lead successfully',
                lead.Id
            );
            
        }      
        
    }
    
    private static void sendEmailOtp(Id leadId) {
        RegistrationFormUtility.sendEmailOtpLead(leadId);
    }
    private static void sendEmailRevisitOtpContact(Id leadId) {
        RegistrationFormUtility.sendEmailRevisitOtpContact(leadId);
    }
    private static ResponseWrapper resendEmailOtp(RequestWrapper req) {
        Lead lead = findByEmail(req.email);
        if (lead == null) return error('LEAD_NOT_FOUND', 'Lead not found');
        
        generateEmailOtp(lead);
        update lead;
        sendEmailOtp(lead.Id);
        
        return success('OTP_RESENT', 'Email OTP resent', lead.Id);
    }
    
    private static ResponseWrapper verifyEmailOtp(RequestWrapper req) {
        
        // =========================
        // 1️⃣ CONTACT FLOW (REVISIT)
        // =========================
        Contact con = findContactByEmail(req.email);
        if (con != null) {
            
            if (con.Revisit_OTP_Expiration__c < System.now()) {
                return error('OTP_EXPIRED', 'OTP expired');
            }
            
            if (con.Revisit_OTP_Code__c != req.emailOtp) {
                return error('OTP_INVALID', 'Incorrect OTP');
            }
            
            // ✅ Application fee already paid
            if (con.Application_Fee_Paid__c == true) {
                String username = '';
                
              User usr = [
                        SELECT Username
                        FROM User
                        WHERE contactId = :con.Id
                        LIMIT 1
              ];
                
                username = usr.Username;
                
                Map<String, Object> resp = new Map<String, Object>{
                    'school'  => con.School__r.Name,
                        'program' => con.Program_Batch__r.Name,
                        'applicationNumber'  => con.Application_Number__c,
                        'username'          => username
                        };
                            
                            return new ResponseWrapper(
                                'PAYMENT_COMPLETED',
                                'Application already submitted',
                                JSON.serialize(resp)
                            );
            }
            
            // Payment pending → send payment link
            String paymentUrl =
                RegistrationFormUtility.getSiteURL() +
                '/s/payment-page?contactId=' + con.Id;
            
            return new ResponseWrapper(
                'PAYMENT_REQUIRED',
                'Application fee pending',
                paymentUrl
            );
            
        }
        
        // =========================
        // 2️⃣ LEAD FLOW (NEW USER)
        // =========================
        Lead lead = findByEmail(req.email);
        if (lead == null) {
            return error('LEAD_NOT_FOUND', 'Lead not found');
        }
        
        if (lead.Email_OTP_Expiration__c < System.now()) {
            return error('OTP_EXPIRED', 'OTP expired');
        }
        
        if (lead.Email_OTP_Code__c != req.emailOtp) {
            return error('OTP_INVALID', 'Incorrect OTP');
        }
        
        lead.Email_OTP_Verified__c = true;
        update lead;
        
        String countryOrStateVal;
        String StateVal;        
        if (String.isNotBlank(lead.Country__c)) {
            countryOrStateVal = lead.Country__c;
        } if (String.isNotBlank(lead.State__c)) {
            StateVal = lead.State__c;
        } /*else {
            countryOrStateVal = null; // or ''
        }*/
        Map<String, Object> resp = new Map<String, Object>{
            'school'  => lead.School__c,
                'program' => lead.Program_Name_Display__c,
                'countryOrState' => countryOrStateVal,
                'state' => StateVal,
                'countryCode' => lead.Country_Code__c,
                'mobilePhone' => lead.MobilePhone,
                'mobileVerification' => lead.Mobile_OTP_Verified__c,
                'Category' => lead.Category__c,
                'firstName' => lead.FirstName,
                'lastName'=> lead.LastName
                };
                    
                    
                    return success(
                        'OTP_VERIFIED',
                        'Email OTP verified successfully',
                        //lead.Id
                        JSON.serialize(resp)
                    );
    }
    
    // =======================
    // MOBILE OTP FLOW
    // =======================
    
    
    private static ResponseWrapper sendMobileOtp(RequestWrapper req) {
        
        Lead lead = findByEmail(req.email);
        
        if (lead == null || !lead.Email_OTP_Verified__c) {
            return error('EMAIL_NOT_VERIFIED', 'Email OTP verification required');
        }
        
        /* ---------------------------------------
STEP 1: Format Mobile Properly
---------------------------------------- */
        
        // Clean mobile (digits only)
        IF(lead.MobilePhone == null){
        String mobile = req.mobile != null 
            ? req.mobile.replaceAll('[^0-9]', '') 
            : '';
        
        if (mobile.length() != 10) {
            return error('INVALID_MOBILE', 'Mobile must be 10 digits');
        }
        
        // Extract country code (+91 or from "India (+91)")
        String countryCode = '';
        
        if (!String.isBlank(req.countryCode)) {
            String rawCode = req.countryCode.trim();
            
            if (rawCode.contains('(') && rawCode.contains(')')) {
                countryCode = rawCode.substring(
                    rawCode.indexOf('(') + 1,
                    rawCode.indexOf(')')
                );
            } else {
                countryCode = rawCode;
            }
            
            countryCode = countryCode.replaceAll('[^+0-9]', '');
        }
        
        if (String.isBlank(countryCode)) {
            return error('INVALID_COUNTRY_CODE', 'Country code required');
        }
        
        // Final formatted number
        String formattedMobile = countryCode + '-' + mobile;
        
        List<Lead> existingLeads = [
            SELECT Id
            FROM Lead
            WHERE MobilePhone = :formattedMobile
            AND Id != :lead.Id
            LIMIT 1
        ];
        
        if (!existingLeads.isEmpty()) {
            return error(
                'MOBILE_ALREADY_REGISTERED',
                'This mobile number already registered, please try with new one'
            );
        }
        }
        /* ---------------------------------------
STEP 3: Update Lead
---------------------------------------- */
        
        lead.MobilePhone = req.mobile;
        lead.Country_Code__c = req.countryCode;
        
        generateMobileOtp(lead);
        update lead;
        
        sendMobileOtpSms(lead.Id);
        
        return success('OTP_SENT', 'Mobile OTP sent', lead.Id);
    }
    
    
    private static ResponseWrapper resendMobileOtp(RequestWrapper req) {
        
        Lead lead = findByEmail(req.email);
        if (lead == null) {
            return error('LEAD_NOT_FOUND', 'Lead not found');
        }
        
        if (String.isBlank(lead.MobilePhone)) {
            return error('MOBILE_REQUIRED', 'Mobile number not available');
        }
        
        generateMobileOtp(lead);
        update lead;
        
        sendMobileOtpSms(lead.Id);
        
        return success(
            'OTP_RESENT',
            'Mobile OTP resent successfully',
            lead.Id
        );
    }
    
    private static ResponseWrapper verifyMobileOtp(RequestWrapper req) {
        
        Lead lead = findByEmail(req.email);
        if (lead == null) return error('LEAD_NOT_FOUND', 'Lead not found');
        
        if (lead.Mobile_OTP_Expiration__c < System.now()) {
            return error('OTP_EXPIRED', 'OTP expired');
        }
        
        if (lead.Mobile_OTP_Code__c != req.mobileOtp) {
            return error('OTP_INVALID', 'Incorrect OTP');
        }
        
        lead.Mobile_OTP_Verified__c = true;
        lead.Status = 'Verified';
        update lead;
        
        return success('OTP_VERIFIED', 'Mobile OTP verified successfully! Kindly click on "Submit" to proceed with payment.', lead.Id);
    }
    
    
    
    // =======================
    // HELPERS
    // =======================
    private static Lead findByEmail(String email) {
        List<Lead> leads = [
            SELECT Id,FirstName,LastName, Country__c,State__c,Email_OTP_Verified__c, Mobile_OTP_Verified__c,Category__c,Country_Code__c,School__c,Program_Name_Display__c,
            Email_OTP_Code__c, Email_OTP_Expiration__c,Revisit_OTP_Code__c,Revisit_OTP_Expiration__c,MobilePhone,
            Mobile_OTP_Code__c, Mobile_OTP_Expiration__c
            FROM Lead
            WHERE Email = :email
            LIMIT 1
        ];
        return leads.isEmpty() ? null : leads[0];
    }
    
    
    private static Contact findContactByEmail(String email) {
        List<Contact> contacts = [
            SELECT Id,
            Email,Application_Number__c,
            Revisit_OTP_Code__c,
            Revisit_OTP_Expiration__c,
            Application_Fee_Paid__c,
            School__c,School__r.Name,
            Program_Batch__c,Program_Batch__r.Name
            FROM Contact
            WHERE Email = :email
            LIMIT 1
        ];
        return contacts.isEmpty() ? null : contacts[0];
    }
    
    private static void generateContactRevisitOtp(Contact con) {
        con.Revisit_OTP_Code__c = generateOtp();
        con.Revisit_OTP_Expiration__c = System.now().addMinutes(OTP_EXPIRY_MINUTES);
    }
    
    private static void generateEmailOtp(Lead lead) {
        lead.Email_OTP_Code__c = generateOtp();
        lead.Email_OTP_Expiration__c = System.now().addMinutes(OTP_EXPIRY_MINUTES);
        lead.Email_OTP_Verified__c = false;
    }
    /*  private static void generateLeadsRevisitOtp(Lead lead) {
lead.Revisit_OTP_Code__c = generateOtp();
lead.Revisit_OTP_Expiration__c = System.now().addMinutes(10);
} */
    private static void generateMobileOtp(Lead lead) {
        lead.Mobile_OTP_Code__c = generateOtp();
        lead.Mobile_OTP_Expiration__c = System.now().addMinutes(OTP_EXPIRY_MINUTES);
        lead.Mobile_OTP_Verified__c = false;
        
        
    }
    
    private static String generateOtp() {
        String otp;
        List<RegistrationFormUtility.UtilityResponse> resp = RegistrationFormUtility.generateOTP();
        otp = resp.size() > 0 ? resp[0].generatedOTP : null;
        return otp;
    }
    
    Public static void sendMobileOtpSms(Id leadId) {
        
        Lead l = [
            SELECT FirstName,
            MobilePhone,
            Mobile_OTP_Code__c,
            Mobile_OTP_Expiration__c
            FROM Lead
            WHERE Id = :leadId
            LIMIT 1
        ];
        
        String expiryTime = String.valueOf(l.Mobile_OTP_Expiration__c);
        System.debug('l:'+l);
        System.debug('expiryTime'+expiryTime);
        RegistrationFormUtility.futureSMS(
            'OTP',
            l.MobilePhone,
            new List<String>{
                l.FirstName,
                    l.Mobile_OTP_Code__c,
                    expiryTime
                    }
        );
    }
    
    // =======================
    // FINAL SUBMISSION
    // =======================
    
    private static ResponseWrapper finalSubmit(RequestWrapper req) {
        
        // 1️⃣ Check Contact
        /*Contact con = findContactByEmail(req.email);
        if (con != null) {
            return success(
                'EXISTING_CONTACT',
                'Applicant already registered,proceed with OTP verification',
                con.Id
            );
        }*/
        String mobile = req.mobile != null
        ? req.mobile.replaceAll('[^0-9]', '')
        : '';

    if (mobile.length() != 10 && req.countryCode.contains('India')) {

        return error(
            'INVALID_MOBILE',
            'Mobile must be 10 digits'
        );
    }

    String countryCode = '';

    if (!String.isBlank(req.countryCode)) {
        String rawCode = req.countryCode.trim();

        if (rawCode.contains('(') &&
            rawCode.contains(')')) {

            countryCode = rawCode.substring(
                rawCode.indexOf('(') + 1,
                rawCode.indexOf(')')
            );

        } else {
            countryCode = rawCode;
        }

        countryCode = countryCode.replaceAll('[^+0-9]','');
    }

    if (String.isBlank(countryCode)) {
        return error('INVALID_COUNTRY_CODE','Country code required');
    }
    String formattedMobile = countryCode + '-' + mobile;
    String duplicateResult = NewLeadCreation.checkDuplicate(req.email,req.mobile);

    if (duplicateResult == 'EMAIL_EXISTS') {
        return error('EMAIL_EXISTS','Email is already registered. Click on Incomplete Registration to continue with your existing application.');
    }

    if (duplicateResult == 'MOBILE_EXISTS') {
        return error('MOBILE_EXISTS','This mobile number already registered, please try with new one.');
    }

    if (duplicateResult == 'EMAIL_MOBILE_EXISTS') {
        return error('EMAIL_MOBILE_EXISTS','Email and mobile already registered. Click Incomplete Registration to resume or use new details.');
    }
        
        // 2️⃣ Check Lead
        //Lead lead = findByEmail(req.email);
        
        // =========================
        // 🚀 FIRST TIME (CREATE LEAD)
        // =========================             
            
            Lead lead = new Lead(
                FirstName = req.firstName,
                LastName  = String.isBlank(req.lastName) ? 'Student' : req.lastName,
                Company   = 'Individual',
                Status    = 'Unverified',
                Email     = req.email,
                MobilePhone = req.mobile,
                Phone = req.mobile,
                Country_Code__c = req.countryCode,
                Category__c = req.category,
                Country__c  = req.country,
                State__c    = req.state,
                School__c   = req.school,
                Program_Name_Display__c = req.programBatch,
                LeadSource = req.utmSource,
                UTM_Source__c   = req.utmSource,
                UTM_Medium__c   = req.utmMedium,
                UTM_Campaign__c = req.utmCampaign
            );
            
            insert lead;
            
            return success('LEAD_CREATED','Application created, proceed with OTP verification',lead.Id);
        
        
        // ====================================================
        // 🔄 NEW: UPDATE EXISTING LEAD (ONLY EMPTY FIELDS)
        // ====================================================
        /*Boolean isUpdated = false;
        
        if (String.isBlank(lead.Category__c) && !String.isBlank(req.category)) {
            lead.Category__c = req.category;
            isUpdated = true;
        }
        
        if (String.isBlank(lead.School__c) && !String.isBlank(req.school)) {
            lead.School__c = req.school;
            isUpdated = true;
        }
        
        if (String.isBlank(lead.Program_Name_Display__c) && !String.isBlank(req.programBatch)) {
            lead.Program_Name_Display__c = req.programBatch;
            isUpdated = true;
        }
        
        if (String.isBlank(lead.State__c) && !String.isBlank(req.state)) {
            lead.State__c = req.state;
            isUpdated = true;
        }
        
        if (String.isBlank(lead.Country__c) && !String.isBlank(req.country)) {
            lead.Country__c = req.country;
            isUpdated = true;
        }
        
        if (String.isBlank(lead.MobilePhone) && !String.isBlank(req.mobile)) {
            lead.MobilePhone = req.mobile;
            isUpdated = true;
        }
        
        if (String.isBlank(lead.Country_Code__c) && !String.isBlank(req.countryCode)) {
            lead.Country_Code__c = req.countryCode;
            isUpdated = true;
        }
        
        if (isUpdated) {
            update lead;
        }
        
        
        // =========================
        // ⛔ BLOCK IF NOT VERIFIED
        // =========================
        if (!lead.Email_OTP_Verified__c ) {
            return error(
                'EMAIL_NOT_VERIFIED',
                'Please verify email OTP first'
            );
        }
        
        /* if (!lead.Mobile_OTP_Verified__c ) {
return error(
'MOBILE_NOT_VERIFIED',
'Please verify mobile OTP first'
);
}
*/
        
        // Check if Indian number (+91)
       /* Boolean isIndianNumber = false;
        
        if (!String.isBlank(lead.Country_Code__c)) {
            String code = lead.Country_Code__c.replaceAll('[^+0-9]', '');
            if (code.contains('+91')) {
                isIndianNumber = true;
            }
        }
        
        // Apply mobile OTP validation ONLY for India
        if (isIndianNumber && !lead.Mobile_OTP_Verified__c) {
            return error(
                'MOBILE_NOT_VERIFIED',
                'Please verify mobile OTP first'
            );
        }
        // =========================
        // ✅ BOTH VERIFIED → CONVERT
        // =========================
        RegistrationFormUtility.updateLeadPriorConversion(lead.Id);
        // 3. Determine Fee Master Category
        String feeMasterCategory;
        if (lead.Category__c == 'Karnataka' || lead.Category__c == 'Non-Karnataka') {
            feeMasterCategory = 'Indian (SAARC)';
        } else {
            feeMasterCategory = lead.Category__c;
        }
        String Shcoolname = lead.School__c;
        // 4. Query Fee Master
        List<Fee_Master__c> feeMasters = [
            SELECT Id
            FROM Fee_Master__c
            WHERE Program_Name_Display__c = :lead.Program_Name_Display__c
            AND School_Name__c LIKE :('%' + Shcoolname + '%')
            AND Applicant_Category__c = :feeMasterCategory
            AND IsActive__c = true
            AND Fee_Type__c = 'Application Fee'
            ORDER BY Application_Number_Prefix__c DESC
            LIMIT 1
        ];
        
        String feeMasterId = feeMasters.isEmpty() ? null : feeMasters[0].Id;
        system.debug('req.school:'+feeMasterId);
        String paymentUrl;
        // 5. Convert Lead
        List<RegistrationFormUtility.UtilityResponse> resp =
            RegistrationFormUtility.convertLead(lead.Id, feeMasterId);
        
        if (resp != null && resp.size() > 0 && resp[0].applicantContactId != null) {
            // Return the applicant contact Id or application Id as needed
            Id contactId = resp[0].applicantContactId;
            Boolean pucUpdateCalled = false; 
            system.debug('contactId:'+contactId);
            General_Setting__mdt pucSetting = [SELECT Boolean_Value__c FROM General_Setting__mdt WHERE DeveloperName = 'PUC_Drive' LIMIT 1];
            system.debug('pucSetting:'+pucSetting);
            if (pucSetting != null && pucSetting.Boolean_Value__c == true) {
                contact conlist= [Select id,name,MobilePhone from contact where id=:contactId ];
                system.debug('StuleadToUpdate:' + conlist.MobilePhone);
                List<PUC_Drive_Data__c> pucData = [SELECT Id FROM PUC_Drive_Data__c WHERE Mobile_Number__c = :conlist.MobilePhone LIMIT 1 ];
                system.debug('pucData:'+pucData);
                if (!pucData.isEmpty() && pucData[0].Id != null) {
                    
                    RegistrationFormUtility.PUCUpdateRecord(contactId);
                    
                }
                
            }
            
        }
        
        
        if (resp != null && !resp.isEmpty() && resp[0].applicantContactId != null) {
            Id contactId = resp[0].applicantContactId;
            paymentUrl = RegistrationFormUtility.getSiteURL()
                + '/s/payment-page?contactId=' + contactId;
        }
        
        return success(
            'FINAL_SUBMIT_SUCCESS',
            'Lead converted and payment initiated',
            paymentUrl
        );*/        
    }
    private static ResponseWrapper completeRegistration(RequestWrapper req) {
            
            // 1ï¸âƒ£ Check Contact
            /*Contact con = findContactByEmail(req.email);
            if (con != null) {
                return success(
                    'EXISTING_CONTACT',
                    'Applicant already registered,proceed with OTP verification',
                    con.Id
                );
            } */
            
            // 2ï¸âƒ£ Check Lead
            Lead lead = findByEmail(req.email);
            
            // =========================
            // ðŸš€ FIRST TIME (CREATE LEAD)
            // =========================
           if (lead == null) {
                    return error(
                        'LEAD_NOT_FOUND',
                        'No incomplete registration found'
                    );
                }
            
            // ====================================================
            // ðŸ”„ NEW: UPDATE EXISTING LEAD (ONLY EMPTY FIELDS)
            // ====================================================
            Boolean isUpdated = false;
            
            if (String.isBlank(lead.Category__c) && !String.isBlank(req.category)) {
                lead.Category__c = req.category;
                isUpdated = true;
            }
            
            if (String.isBlank(lead.School__c) && !String.isBlank(req.school)) {
                lead.School__c = req.school;
                isUpdated = true;
            }
            
            if (String.isBlank(lead.Program_Name_Display__c) && !String.isBlank(req.programBatch)) {
                lead.Program_Name_Display__c = req.programBatch;
                isUpdated = true;
            }
            
            if (String.isBlank(lead.State__c) && !String.isBlank(req.state)) {
                lead.State__c = req.state;
                isUpdated = true;
            }
            
            if (String.isBlank(lead.Country__c) && !String.isBlank(req.country)) {
                lead.Country__c = req.country;
                isUpdated = true;
            }
            
            if (String.isBlank(lead.MobilePhone) && !String.isBlank(req.mobile)) {
                lead.MobilePhone = req.mobile;
                isUpdated = true;
            }
            
            if (String.isBlank(lead.Country_Code__c) && !String.isBlank(req.countryCode)) {
                lead.Country_Code__c = req.countryCode;
                isUpdated = true;
            }
            
            if (isUpdated) {
                update lead;
            }
            
            
            // =========================
            // â›” BLOCK IF NOT VERIFIED
            // =========================
            if (!lead.Email_OTP_Verified__c ) {
                return error(
                    'EMAIL_NOT_VERIFIED',
                    'Please verify email OTP first'
                );
            }
            
            /* if (!lead.Mobile_OTP_Verified__c ) {
    return error(
    'MOBILE_NOT_VERIFIED',
    'Please verify mobile OTP first'
    );
    }
    */
            
            // Check if Indian number (+91)
            Boolean isIndianNumber = false;
            
            if (!String.isBlank(lead.Country_Code__c)) {
                String code = lead.Country_Code__c.replaceAll('[^+0-9]', '');
                if (code.contains('+91')) {
                    isIndianNumber = true;
                }
            }
            
            // Apply mobile OTP validation ONLY for India
            if (isIndianNumber && !lead.Mobile_OTP_Verified__c) {
                return error(
                    'MOBILE_NOT_VERIFIED',
                    'Please verify mobile OTP first'
                );
            }
            // =========================
            // âœ… BOTH VERIFIED â†’ CONVERT
            // =========================
            RegistrationFormUtility.updateLeadPriorConversion(lead.Id);
            // 3. Determine Fee Master Category
            String feeMasterCategory;
            if (lead.Category__c == 'Karnataka' || lead.Category__c == 'Non-Karnataka') {
                feeMasterCategory = 'Indian (SAARC)';
            } else {
                feeMasterCategory = lead.Category__c;
            }
            String Shcoolname = lead.School__c;
            // 4. Query Fee Master
            List<Fee_Master__c> feeMasters = [
                SELECT Id
                FROM Fee_Master__c
                WHERE Program_Name_Display__c = :lead.Program_Name_Display__c
                AND School_Name__c LIKE :('%' + Shcoolname + '%')
                AND Applicant_Category__c = :feeMasterCategory
                AND IsActive__c = true
                AND Fee_Type__c = 'Application Fee'
                ORDER BY Application_Number_Prefix__c DESC
                LIMIT 1
            ];
            
            String feeMasterId = feeMasters.isEmpty() ? null : feeMasters[0].Id;
            system.debug('req.school:'+feeMasterId);
            String paymentUrl;
            // 5. Convert Lead
            List<RegistrationFormUtility.UtilityResponse> resp =
                RegistrationFormUtility.convertLead(lead.Id, feeMasterId);
            
            if (resp != null && resp.size() > 0 && resp[0].applicantContactId != null) {
                // Return the applicant contact Id or application Id as needed
                Id contactId = resp[0].applicantContactId;
                Boolean pucUpdateCalled = false; 
                system.debug('contactId:'+contactId);
                General_Setting__mdt pucSetting = [SELECT Boolean_Value__c FROM General_Setting__mdt WHERE DeveloperName = 'PUC_Drive' LIMIT 1];
                system.debug('pucSetting:'+pucSetting);
                if (pucSetting != null && pucSetting.Boolean_Value__c == true) {
                    contact conlist= [Select id,name,MobilePhone from contact where id=:contactId ];
                    system.debug('StuleadToUpdate:' + conlist.MobilePhone);
                    List<PUC_Drive_Data__c> pucData = [SELECT Id FROM PUC_Drive_Data__c WHERE Mobile_Number__c = :conlist.MobilePhone LIMIT 1 ];
                    system.debug('pucData:'+pucData);
                    if (!pucData.isEmpty() && pucData[0].Id != null) {
                        
                        RegistrationFormUtility.PUCUpdateRecord(contactId);
                        
                    }
                    
                }
                
            }
            
            
            if (resp != null && !resp.isEmpty() && resp[0].applicantContactId != null) {
                Id contactId = resp[0].applicantContactId;
                paymentUrl = RegistrationFormUtility.getSiteURL()
                    + '/s/payment-page?contactId=' + contactId;
            }
            
            return success(
                'FINAL_SUBMIT_SUCCESS',
                'Lead converted and payment initiated',
                paymentUrl
            );
        }
    // =======================
    // RESPONSE HELPERS
    // =======================
    private static ResponseWrapper success(String status, String msg, String ref) {
        return new ResponseWrapper(status, msg, ref);
    }
    
    private static ResponseWrapper error(String status, String msg) {
        RestContext.response.statusCode = 400;
        return new ResponseWrapper(status, msg, null);
    }
    
    
    
    // =======================
    // WRAPPERS
    // =======================
    global class RequestWrapper {
        public String action;
        public String firstName;
        public String lastName;
        public String email;
        public String mobile;
        public String countryCode;
        public String emailOtp;
        public String mobileOtp;
        public String mobileVerification;
        public String emailVerification;
        public String category;
        public String country;
        public String countryOrState;
        public String state;
        public String school;
        public String programBatch;
        public String applicationNumber;
        public String username;
        public String utmSource;
        public String utmMedium;
        public String utmCampaign;
    }
    
    global class ResponseWrapper {
        public String status;
        public String message;
        public String reference;
        
        public ResponseWrapper(String s, String m, String r) {
            status = s;
            message = m;
            reference = r;
        }
    }
    
    
    private static final String ENROLMENT_YEAR_CMDT_NAME = 'Enrolment_Year';
    private static final String FEE_TYPE_APPLICATION = 'Application Fee';   
    @HttpGet
    global static String getData() {
        
        String type = RestContext.request.params.get('type');
        
        if (type == 'schoolPrograms') {
            String selectionMode = RestContext.request.params.get('selectionMode');
            return getSchoolProgramsForWeb(selectionMode);
        }
        
        RestContext.response.statusCode = 400;
        return JSON.serialize(
            new ResponseWrapper(
                'INVALID_REQUEST',
                'Unsupported GET request',
                null
            )
        );
    }
    
    private static String getSchoolProgramsForWeb(String selectionMode) {
        
        
        
        String enrolmentYear = getCurrentEnrolmentYear();
        
        List<Fee_Master__c> records;
        
        if (selectionMode == 'ApplicationFee') {
            records = [
                SELECT School_Name__c, Program_Name_Display__c, Program_Batch__c, Application_Number_Prefix__c
                FROM Fee_Master__c
                WHERE Fee_Type__c = :FEE_TYPE_APPLICATION
                AND Enrolment_Year__c = :enrolmentYear
                AND IsActive__c = true
                AND (
                    (Program_Batch__r.Name LIKE '%2022%' OR Application_Number_Prefix__c LIKE '24%')
                    OR (Program_Batch__r.Name LIKE '%2023%' OR Application_Number_Prefix__c LIKE '24%')
                    OR Program_Batch__r.Name != null
                    OR Application_Number_Prefix__c != null
                )
                ORDER BY School_Name__c, Program_Name_Display__c, Application_Number_Prefix__c DESC
            ];
        } else {
            records = [
                SELECT School_Name__c, Program_Name_Display__c, Program_Batch__c, Application_Number_Prefix__c
                FROM Fee_Master__c
                WHERE Fee_Type__c != :FEE_TYPE_APPLICATION
                AND Enrolment_Year__c = :enrolmentYear
                AND Quota__c = :selectionMode
                AND IsActive__c = true
                AND (
                    (Program_Batch__r.Name LIKE '%2022%' OR Application_Number_Prefix__c LIKE '24%')
                    OR (Program_Batch__r.Name LIKE '%2023%' OR Application_Number_Prefix__c LIKE '24%')
                    OR Program_Batch__r.Name != null
                    OR Application_Number_Prefix__c != null
                )
                ORDER BY School_Name__c, Program_Name_Display__c, Application_Number_Prefix__c DESC        ];
        }
        
        Map<String, Set<String>> tempMap = new Map<String, Set<String>>();
        
        for (Fee_Master__c fm : records) {
            
            if (String.isBlank(fm.School_Name__c) ||
                String.isBlank(fm.Program_Name_Display__c)) {
                    continue;
                }
            
            String schoolName = fm.School_Name__c;
            
            if (schoolName.startsWith('School of Computer Science and Engineering')) {
                schoolName = 'School of Computer Science and Engineering';
            }
            
            if (!tempMap.containsKey(schoolName)) {
                tempMap.put(schoolName, new Set<String>());
            }
            
            tempMap.get(schoolName)
                .add(fm.Program_Name_Display__c);
        }
        
        // Convert Set → List for JSON
        Map<String, List<String>> response = new Map<String, List<String>>();
        
        for (String school : tempMap.keySet()) {
            
            List<String> programs = new List<String>();
            programs.addAll(tempMap.get(school));
            programs.sort(); // optional sorting
            
            response.put(school, programs);
        }
        
        return JSON.serialize(response);
    }
    
    public static String getCurrentEnrolmentYear() {
        return [select Text_Value__c from General_Setting__mdt where DeveloperName = :ENROLMENT_YEAR_CMDT_NAME limit 1].Text_Value__c;
    }
    
}