import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

CASE_FIELDS = ['Case.CaseNumber', 'Case.Subject', 'Case.Status', 'Case.Mentor_Name__c', 'Case.School__c', 'Case.Mentor_Mobile__c', 'Case.Mentor_Email__c', 'Case.Employee_ID__c', 'Case.Mentor_Designation__c'];

export default class RevStdMenteeCaseDetail extends LightningElement {
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


    get caseNumber() {
        return getFieldValue(this.caseRecord, 'Case.CaseNumber') || 'N/A';
    }
    get subject() {
        return getFieldValue(this.caseRecord, 'Case.Subject') || 'N/A';
    }

    get status() {
        return getFieldValue(this.caseRecord, 'Case.Status') || 'N/A';
    }
    get mentorName() {
        return getFieldValue(this.caseRecord, 'Case.Mentor_Name__c') || 'N/A';
    }
    get mentorMobile() {
        return getFieldValue(this.caseRecord, 'Case.Mentor_Mobile__c') || 'N/A';
    }
    get mentorEmail() {
        return getFieldValue(this.caseRecord, 'Case.Mentor_Email__c') || 'N/A';
    }
    get mentorSchool() {
        return getFieldValue(this.caseRecord, 'Case.School__c') || 'N/A';
    }
    get mentorEmployeeID() {
        return getFieldValue(this.caseRecord, 'Case.Employee_ID__c') || 'N/A';
    }

    get mentorDesignation() {
        return getFieldValue(this.caseRecord, 'Case.Mentor_Designation__c') || 'N/A';
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
}