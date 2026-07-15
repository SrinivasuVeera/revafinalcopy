@IsTest
private class ContactSelectorTest {

    @IsTest
    static void contactKeys_returnsEmailAndNormalizedPhone() {
        // 10-digit local number → India country code (91) prepended
        Contact c = new Contact(LastName='K', Email='X@Y.COM', MobilePhone='(555) 111-2222');
        insert c;
        ContactSelector.RecordKeys k = ContactSelector.getKeys(c.Id);
        System.assertEquals('x@y.com', k.email);
        System.assertEquals('915551112222', k.mobile);
    }

    @IsTest
    static void normalizePhone_indiaFormats() {
        // 10-digit local
        System.assertEquals('917400357379', ContactSelector.normalizePhone('7400357379'));
        // 12-digit already prefixed
        System.assertEquals('917400357379', ContactSelector.normalizePhone('917400357379'));
        // +91 with spaces
        System.assertEquals('917400357379', ContactSelector.normalizePhone('+91 7400 357 379'));
        // 00 international prefix
        System.assertEquals('971501234567', ContactSelector.normalizePhone('00971501234567'));
        // 11-digit local with leading 0
        System.assertEquals('917400357379', ContactSelector.normalizePhone('07400357379'));
        // Non-India 11-digit (US 1+10) left as-is
        System.assertEquals('15553334444', ContactSelector.normalizePhone('+1-555-333-4444'));
    }

    @IsTest
    static void leadKeys_returnsEmailAndNormalizedPhone() {
        Lead l = new Lead(LastName='L', Company='C',
                          Email='Lead@Example.Com', MobilePhone='+1-555-333-4444');
        insert l;
        ContactSelector.RecordKeys k = ContactSelector.getKeys(l.Id);
        System.assertEquals('lead@example.com', k.email);
        System.assertNotEquals(null, k.mobile);
    }

    @IsTest
    static void phoneVariants_includeFormattedInternationalNumbers() {
        Set<String> india = ContactSelector.phoneVariants('918799388006');
        System.assert(india.contains('+91-8799388006'));
        System.assert(india.contains('91-8799388006'));
        System.assert(india.contains('91 8799388006'));
        System.assert(india.contains('+918799388006'));
        System.assert(india.contains('8799388006'));

        Set<String> us = ContactSelector.phoneVariants('15553334444');
        System.assert(us.contains('+1-555-333-4444'));
        System.assert(us.contains('1-555-333-4444'));
        System.assert(us.contains('+15553334444'));
    }

    @IsTest
    static void nullId_returnsBlanks() {
        ContactSelector.RecordKeys k = ContactSelector.getKeys(null);
        System.assertEquals(null, k.email);
        System.assertEquals(null, k.mobile);
    }

    @IsTest
    static void unsupportedType_returnsBlanks() {
        // Use an Opportunity Id type — not handled by selector.
        Opportunity o = new Opportunity(Name='X', StageName='Prospecting',
                                        CloseDate=Date.today());
        insert o;
        ContactSelector.RecordKeys k = ContactSelector.getKeys(o.Id);
        System.assertEquals(null, k.email);
        System.assertEquals(null, k.mobile);
    }

    @IsTest
    static void accountBranch_executes_returnsKeys() {
        Account a = new Account(Name = 'Test Account');
        insert a;
        ContactSelector.RecordKeys k = ContactSelector.getKeys(a.Id);
        System.assertNotEquals(null, k, 'Account branch should return a RecordKeys instance');
    }

    @IsTest
    static void normalizePhone_blank_returnsNull() {
        System.assertEquals(null, ContactSelector.normalizePhone(null));
        System.assertEquals(null, ContactSelector.normalizePhone(''));
        System.assertEquals(null, ContactSelector.normalizePhone('   '));
    }

    @IsTest
    static void individualApplication_resolvesViaContact() {
        Contact c = new Contact(LastName='IA', Email='IA@Example.com', MobilePhone='+1-555-777-8888');
        insert c;
        IndividualApplication ia = new IndividualApplication(
            Category = 'Resident Indian',
            ContactId = c.Id,
            AppliedDate = Date.today());
        insert ia;
        ContactSelector.RecordKeys k = ContactSelector.getKeys(ia.Id);
        System.assertEquals('ia@example.com', k.email);
        System.assertEquals('15557778888', k.mobile);
    }

    @IsTest
    static void individualApplication_noContactNoAccount_returnsBlanks() {
        IndividualApplication ia = new IndividualApplication(
            Category = 'Resident Indian',
            AppliedDate = Date.today());
        insert ia;
        ContactSelector.RecordKeys k = ContactSelector.getKeys(ia.Id);
        System.assertEquals(null, k.email);
        System.assertEquals(null, k.mobile);
    }

    @IsTest
    static void individualApplication_resolvesLeadByFormattedMobile() {
        Contact c = new Contact(
            LastName = 'MobileOnly',
            MobilePhone = '8799388006'
        );
        insert c;

        Lead l = new Lead(
            LastName = 'MobileLead',
            Company = 'REVA',
            MobilePhone = '+91-8799388006'
        );
        insert l;

        IndividualApplication ia = new IndividualApplication(
            Category = 'Resident Indian',
            ContactId = c.Id,
            AppliedDate = Date.today()
        );
        insert ia;

        ContactSelector.RecordKeys k = ContactSelector.getKeys(ia.Id);
        System.assertEquals(String.valueOf(l.Id), k.leadId);
        System.assertEquals('918799388006', k.mobile);
    }

    @IsTest
    static void hedApplication_resolvesViaLeadAndApplicant() {
        Schema.SObjectType appType = Schema.getGlobalDescribe().get('hed__Application__c');
        if (appType == null) {
            return;
        }

        Contact applicant = new Contact(
            LastName = 'Applicant',
            Email = 'Applicant@Example.com',
            MobilePhone = '7400357379'
        );
        insert applicant;

        Lead lead = new Lead(
            LastName = 'Lead',
            Company = 'REVA',
            Email = 'Lead@Example.com',
            MobilePhone = '9840635677'
        );
        insert lead;

        SObject app = appType.newSObject();
        Map<String, Schema.SObjectField> fields = appType.getDescribe(
            SObjectDescribeOptions.DEFERRED
        ).fields.getMap();
        if (fields.containsKey('hed__Applicant__c')) {
            app.put('hed__Applicant__c', applicant.Id);
        }
        if (fields.containsKey('Lead__c')) {
            app.put('Lead__c', lead.Id);
        }
        if (fields.containsKey('Application_Number__c')) {
            app.put('Application_Number__c', 'APP-HED-1');
        }
        insert app;

        ContactSelector.RecordKeys k = ContactSelector.getKeys((Id) app.get('Id'));
        System.assertEquals('lead@example.com', k.email);
        System.assertEquals(String.valueOf(lead.Id), k.leadId);
        System.assertEquals('APP-HED-1', k.applicationId);
        System.assertNotEquals(null, k.mobile);
    }
}