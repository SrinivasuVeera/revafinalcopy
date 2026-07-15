import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

CASE_FIELDS = ['Case.Contact_Name__c', 'Case.CaseNumber', 'Case.Record_Type_Name__c', 'Case.Sub_Category__c', 'Case.Category__c', 'Case.Subject', 'Case.Case_Status__c', 'Case.Status', 'Case.Description', 'Case.Old_Case_Number__c', 'Case.Agent_Remarks__c', 'Case.Origin', 'Case.Priority', 'Case.SuppliedEmail', 'Case.OwnerId', 'Case.ContactId'];
USER_FIELDS = ['User.Name'];
CONTACT_FIELDS = ['Contact.Name'];
export default class RevStdSupportRequestCaseDetail extends NavigationMixin(LightningElement) {
    @api recordId;
    @track caseRecord;

    @wire(getRecord, { recordId: '$recordId', fields: CASE_FIELDS })
    wiredCaseData({ error, data }) {
        if (data) {

            this.caseRecord = data;
        } else if (error) {
            this.showErrorToast(error.body.message);
        }
    }




    //Error Notification
    showErrorToast(errorMessage) {
        const event = new ShowToastEvent({
            title: 'Error',
            message: errorMessage,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }


    //getters
    get contactName() {
        return getFieldValue(this.caseRecord, 'Case.Contact_Name__c') || 'N/A';
    }
    get caseNumber() {
        return getFieldValue(this.caseRecord, 'Case.CaseNumber') || 'N/A';
    }

    get recordTypeName() {
        return getFieldValue(this.caseRecord, 'Case.Record_Type_Name__c') || 'N/A';
    }

    get subCategory() {
        return getFieldValue(this.caseRecord, 'Case.Sub_Category__c') || 'N/A';
    }

    get category() {
        return getFieldValue(this.caseRecord, 'Case.Category__c') || 'N/A';
    }

    get subject() {
        return getFieldValue(this.caseRecord, 'Case.Subject') || 'N/A';
    }

    get caseStatus() {
        return getFieldValue(this.caseRecord, 'Case.Case_Status__c') || 'N/A';  //Type
    }

    get status() {
        return getFieldValue(this.caseRecord, 'Case.Status') || 'N/A';
    }

    get description() {
        return getFieldValue(this.caseRecord, 'Case.Description') || 'N/A';
    }

    get oldCaseNumber() {
        return getFieldValue(this.caseRecord, 'Case.Old_Case_Number__c') || 'N/A';
    }

    get agentRemarks() {
        return getFieldValue(this.caseRecord, 'Case.Agent_Remarks__c') || 'N/A';
    }

    get origin() {
        return getFieldValue(this.caseRecord, 'Case.Origin') || 'N/A';
    }

    get priority() {
        return getFieldValue(this.caseRecord, 'Case.Priority') || 'N/A';
    }

    get suppliedEmail() {
        return getFieldValue(this.caseRecord, 'Case.SuppliedEmail') || 'N/A';
    }
}