/**
 * ContactSelector
 * ---------------------------------------------------------------------------
 * Resolves ids + Email + Mobile from any supported recordId.
 * Add additional sObject types here as needed (Person Account, EDA Affiliation,
 * Education Cloud Student, etc.).
 */
public with sharing class ContactSelector {

    public class RecordKeys {
        public String recordId;
        public String applicationId;
        public String leadId;
        public String email;
        public String mobile;
        public RecordKeys(String e, String m) {
            this(null, null, null, e, m);
        }
        public RecordKeys(Id recordId, String applicationId, String leadId, String e, String m) {
            this.recordId = recordId == null ? null : String.valueOf(recordId);
            this.applicationId = String.isBlank(applicationId) ? null : applicationId.trim();
            this.leadId = String.isBlank(leadId) ? null : leadId.trim();
            this.email = (e != null) ? e.trim().toLowerCase() : null;
            this.mobile = normalizePhone(m);
        }
    }

    public static RecordKeys getKeys(Id recordId) {
        if (recordId == null) {
            return new RecordKeys(null, null);
        }
        Schema.SObjectType type = recordId.getSObjectType();

        if (type == Contact.SObjectType) {
            List<Contact> contacts = [
                SELECT Email, MobilePhone, Phone
                FROM   Contact WHERE Id = :recordId WITH USER_MODE LIMIT 1
            ];
            if (!contacts.isEmpty()) {
                Contact c = contacts[0];
                return new RecordKeys(recordId, null, null, c.Email,
                    String.isNotBlank(c.MobilePhone) ? c.MobilePhone : c.Phone);
            }
        } else if (type == Lead.SObjectType) {
            List<Lead> leads = [
                SELECT Email, MobilePhone, Phone
                FROM   Lead WHERE Id = :recordId WITH USER_MODE LIMIT 1
            ];
            if (!leads.isEmpty()) {
                Lead l = leads[0];
                return new RecordKeys(recordId, null, String.valueOf(l.Id), l.Email,
                    String.isNotBlank(l.MobilePhone) ? l.MobilePhone : l.Phone);
            }
        } else if (type == Account.SObjectType) {
            // Person Accounts expose PersonEmail / PersonMobilePhone when enabled.
            String soql = 'SELECT Id';
            Map<String, Schema.SObjectField> fm = Account.SObjectType.getDescribe(
                SObjectDescribeOptions.DEFERRED
            ).fields.getMap();
            if (fm.containsKey('PersonEmail')) {
                soql += ', PersonEmail';
            }
            if (fm.containsKey('PersonMobilePhone')) {
                soql += ', PersonMobilePhone';
            }
            soql += ' FROM Account WHERE Id = :recordId WITH USER_MODE LIMIT 1';
            List<Account> accounts = (List<Account>) Database.query(soql);
            if (!accounts.isEmpty()) {
                Account a = accounts[0];
                String email = fm.containsKey('PersonEmail')
                    ? (String) a.get('PersonEmail')
                    : null;
                String mobile = fm.containsKey('PersonMobilePhone')
                    ? (String) a.get('PersonMobilePhone')
                    : null;
                return new RecordKeys(recordId, null, null, email, mobile);
            }
        } else if (type.getDescribe().getName() == 'hed__Application__c') {
            return getHedApplicationKeys(recordId);
        } else if (type == IndividualApplication.SObjectType) {
            // Mobile/email: prefer values captured on the application because
            // those are the identifiers sent to SFMC. Account/contact remain
            // fallback sources for older records.
            // Falls back to Contact for either when the preferred path is empty.
            Map<String, Schema.SObjectField> iaFields =
                IndividualApplication.SObjectType.getDescribe(
                    SObjectDescribeOptions.DEFERRED
                ).fields.getMap();
            String soql = 'SELECT ContactId, AccountId';
            if (iaFields.containsKey('Phone__c')) {
                soql += ', Phone__c';
            }
            if (iaFields.containsKey('Email__c')) {
                soql += ', Email__c';
            }
            if (iaFields.containsKey('Long_Application_Id__c')) {
                soql += ', Long_Application_Id__c';
            }
            soql += ', Contact.Email, Contact.MobilePhone, Contact.Phone' +
                    ' FROM IndividualApplication WHERE Id = :recordId' +
                    ' WITH USER_MODE LIMIT 1';
            List<IndividualApplication> apps =
                (List<IndividualApplication>) Database.query(soql);
            if (!apps.isEmpty()) {
                IndividualApplication ia = apps[0];
                String email = firstNonBlank(new List<String>{
                    iaFields.containsKey('Email__c') ? (String) ia.get('Email__c') : null
                });
                String mobile = (iaFields.containsKey('Phone__c'))
                    ? (String) ia.get('Phone__c') : null;

                if (ia.AccountId != null) {
                    RecordKeys k = getKeys(ia.AccountId);
                    if (k != null) {
                        if (String.isBlank(email)) email = k.email;
                        if (String.isBlank(mobile)) mobile = k.mobile;
                    }
                }
                if (String.isBlank(email) && ia.ContactId != null) {
                    email = ia.Contact.Email;
                    if (String.isBlank(mobile)) {
                        mobile = String.isNotBlank(ia.Contact.MobilePhone)
                            ? ia.Contact.MobilePhone : ia.Contact.Phone;
                    }
                }
                String applicationId = iaFields.containsKey('Long_Application_Id__c')
                    ? (String) ia.get('Long_Application_Id__c')
                    : null;
                if (String.isBlank(applicationId)) {
                    applicationId = String.valueOf(recordId);
                }
                return new RecordKeys(
                    recordId,
                    applicationId,
                    resolveLeadId(email, mobile),
                    email,
                    mobile
                );
            }
        }
        return new RecordKeys(null, null);
    }

    private static RecordKeys getHedApplicationKeys(Id recordId) {
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe()
            .get('hed__Application__c')
            .getDescribe(SObjectDescribeOptions.DEFERRED)
            .fields.getMap();

        String soql = 'SELECT Id';
        if (fields.containsKey('Application_Number__c')) {
            soql += ', Application_Number__c';
        }
        if (fields.containsKey('Lead_Id__c')) {
            soql += ', Lead_Id__c';
        }
        if (fields.containsKey('Lead__c')) {
            soql += ', Lead__c, Lead__r.Email, Lead__r.MobilePhone, Lead__r.Phone';
        }
        if (fields.containsKey('hed__Applicant__c')) {
            soql += ', hed__Applicant__c, hed__Applicant__r.Email, hed__Applicant__r.MobilePhone, hed__Applicant__r.Phone';
        }
        soql += ' FROM hed__Application__c WHERE Id = :recordId WITH USER_MODE LIMIT 1';

        List<SObject> apps = Database.query(soql);
        if (apps.isEmpty()) {
            return new RecordKeys(null, null);
        }

        SObject app = apps[0];
        String email;
        String mobile;
        String leadId = fields.containsKey('Lead_Id__c')
            ? (String) app.get('Lead_Id__c')
            : null;

        if (fields.containsKey('Lead__c') && app.get('Lead__c') != null) {
            leadId = String.valueOf(app.get('Lead__c'));
            SObject lead = app.getSObject('Lead__r');
            if (lead != null) {
                email = (String) lead.get('Email');
                mobile = firstNonBlank(new List<String>{
                    (String) lead.get('MobilePhone'),
                    (String) lead.get('Phone')
                });
            }
        }

        if (fields.containsKey('hed__Applicant__c') && app.get('hed__Applicant__c') != null) {
            SObject applicant = app.getSObject('hed__Applicant__r');
            if (applicant != null) {
                if (String.isBlank(email)) {
                    email = (String) applicant.get('Email');
                }
                if (String.isBlank(mobile)) {
                    mobile = firstNonBlank(new List<String>{
                        (String) applicant.get('MobilePhone'),
                        (String) applicant.get('Phone')
                    });
                }
            }
        }

        String applicationId = fields.containsKey('Application_Number__c')
            ? (String) app.get('Application_Number__c')
            : null;
        if (String.isBlank(applicationId)) {
            applicationId = String.valueOf(recordId);
        }
        return new RecordKeys(recordId, applicationId, leadId, email, mobile);
    }

    /**
     * Return a canonical digit-only mobile for Data Cloud matching. If the raw
     * phone already has an international prefix (+ / 00), keep that country
     * code. For local 10-digit numbers we still assume India as the org default,
     * but downstream matching also keeps the local variant.
     */
    @TestVisible
    private static String normalizePhone(String raw) {
        if (String.isBlank(raw)) {
            return null;
        }
        String digits = raw.replaceAll('[^0-9]', '');
        if (String.isBlank(digits)) {
            return null;
        }
        String trimmed = raw.trim();
        if (trimmed.startsWith('+')) {
            return digits;
        }
        if (digits.length() > 11 && digits.startsWith('00')) {
            return digits.substring(2);
        }
        if (digits.length() == 10) {
            return '91' + digits;
        }
        if (digits.length() == 11 && digits.startsWith('0')) {
            return '91' + digits.substring(1);
        }
        return digits;
    }

    private static String firstNonBlank(List<String> values) {
        for (String value : values) {
            if (String.isNotBlank(value)) {
                return value;
            }
        }
        return null;
    }

    private static String resolveLeadId(String email, String mobile) {
        if (String.isNotBlank(email)) {
            List<Lead> leadsByEmail = [
                SELECT Id
                FROM Lead
                WHERE Email = :email
                WITH USER_MODE
                ORDER BY LastModifiedDate DESC
                LIMIT 1
            ];
            if (!leadsByEmail.isEmpty()) {
                return String.valueOf(leadsByEmail[0].Id);
            }
        }
        if (String.isNotBlank(mobile)) {
            Set<String> variants = phoneVariants(mobile);
            String fullPattern = phoneLikePattern(mobile, false);
            String localPattern = phoneLikePattern(mobile, true);
            List<Lead> leadsByPhone = [
                SELECT Id
                FROM Lead
                WHERE MobilePhone IN :variants OR Phone IN :variants
                   OR MobilePhone LIKE :fullPattern OR Phone LIKE :fullPattern
                   OR MobilePhone LIKE :localPattern OR Phone LIKE :localPattern
                WITH USER_MODE
                ORDER BY LastModifiedDate DESC
                LIMIT 1
            ];
            if (!leadsByPhone.isEmpty()) {
                return String.valueOf(leadsByPhone[0].Id);
            }
        }
        return null;
    }

    @TestVisible
    private static Set<String> phoneVariants(String normalizedMobile) {
        Set<String> variants = new Set<String>();
        if (String.isBlank(normalizedMobile)) {
            return variants;
        }
        String digits = normalizedMobile.replaceAll('[^0-9]', '');
        if (String.isBlank(digits)) {
            return variants;
        }

        variants.add(normalizedMobile);
        variants.add(digits);
        variants.add('+' + digits);
        variants.add('00' + digits);

        if (digits.length() == 12 && digits.startsWith('91')) {
            String local = digits.substring(2);
            variants.add(local);
            variants.add('0' + local);
            variants.add('+91' + local);
            variants.add('+91-' + local);
            variants.add('+91 ' + local);
            variants.add('91-' + local);
            variants.add('91 ' + local);
        } else if (digits.length() == 10) {
            variants.add(digits);
            variants.add('0' + digits);
            variants.add('91' + digits);
            variants.add('+91' + digits);
            variants.add('+91-' + digits);
            variants.add('+91 ' + digits);
            variants.add('91-' + digits);
            variants.add('91 ' + digits);
        }

        if (digits.length() > 10) {
            for (Integer ccLen = 1; ccLen <= 3; ccLen++) {
                if (digits.length() <= ccLen + 5) continue;
                String cc = digits.substring(0, ccLen);
                String local = digits.substring(ccLen);
                variants.add('+' + cc + local);
                variants.add('+' + cc + '-' + local);
                variants.add('+' + cc + ' ' + local);
                variants.add(cc + '-' + local);
                variants.add(cc + ' ' + local);
                variants.add('00' + cc + local);
                if (local.length() == 10) {
                    variants.add('+' + cc + '-' + local.substring(0, 3) + '-' +
                        local.substring(3, 6) + '-' + local.substring(6));
                    variants.add(cc + '-' + local.substring(0, 3) + '-' +
                        local.substring(3, 6) + '-' + local.substring(6));
                }
            }
        }
        return variants;
    }

    private static String phoneLikePattern(String mobile, Boolean useLocalTenDigits) {
        String digits = String.isBlank(mobile) ? '' : mobile.replaceAll('[^0-9]', '');
        if (useLocalTenDigits && digits.length() > 10) {
            digits = digits.substring(digits.length() - 10);
        }
        if (digits.length() < 7) {
            return '__NO_PHONE_MATCH__';
        }
        String pattern = '%';
        for (Integer i = 0; i < digits.length(); i++) {
            pattern += digits.substring(i, i + 1) + '%';
        }
        return pattern;
    }
}