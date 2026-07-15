import { LightningElement,track,wire,api} from 'lwc';
/*Get Contact Details Based on the User Login*/
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import insertDetails from '@salesforce/apex/RPL_StudentRegistrationDetails.insertStudentRegDetails';

const FIELDS = ['Contact.FirstName', 'Contact.LastName', 'Contact.MiddleName', 'Contact.Personal_Email__c', 'Contact.MobilePhone'];
export default class Rpl_RevaPlacementRegisterYourselfPage extends LightningElement {
    Rpl_Personal_Mail_ID__c;
 @api contactId;
 @api placementRegistrationText;

 lastName;
 firstName;
 middleName;
 isSpinner;
 @track studentRegMap = {};

 @track studentMapping = {
     'Rpl_Personal_Mail_ID__c': '',
     'firstName': '',
     'middleName': '',
     'lastName': '',
     'countryCode': '',
     'mobileNumber': ''
 }
 isSubmitDisabled = true;
 acknowledgmentChecked = false;
 handleAcknowledgmentChange(event) {
     this.acknowledgmentChecked = event.target.checked;
     this.isSubmitDisabled = !this.acknowledgmentChecked;
 }

 @wire(getRecord, {
     recordId: '$contactId',
     fields: FIELDS
 })
 wiredContact({
     error,
     data
 }) {
     this.isSpinner = true;
     if (data) {

         this.processContactData(data);
         this.isSpinner = false;
     } else if (error) {
         // Handle the error
         console.error(error);
         this.isSpinner = false;
     }

 }
 processContactData(data) {
     this.studentMapping.firstName = this.toTitleCase(this.getFieldValue(data, 'FirstName'));
     this.studentMapping.lastName = this.toTitleCase(this.getFieldValue(data, 'LastName'));
     this.studentMapping.middleName = this.toTitleCase(this.getFieldValue(data, 'MiddleName'));
     this.studentMapping.Rpl_Personal_Mail_ID__c = this.getFieldValue(data, 'Personal_Email__c');
     this.studentMapping.mobileNumber = this.getFieldValue(data, 'MobilePhone');

 }

 toTitleCase(txt) {
     if (txt) {
         return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
     }
         return '';

 }
 getFieldValue(data, field) {
     return data.fields[field].value || '';
 }

 handleInput(event) {
     const label = event.target.dataset.label;
     const value = event.target.value;
     this.studentMapping[label] = value;
 }

 blurHandler(event) {
     const label = event.target.dataset.label;
     const value = event.target.value;
     const input = this.template.querySelector(`[data-label="${label}"]`);
     input.reportValidity();
 }

 /**********************Working one********************************** */

 handleNextButton() {
     let isAllValid = true;
     const inputs = this.template.querySelectorAll('input');
     inputs.forEach(input => {
         if (!input.reportValidity()) {
             isAllValid = false;
             return;
         }
     })

     if (!isAllValid) {
         return;
     } else {
        this.studentRegMap.FirstName = this.studentMapping.firstName;
        this.studentRegMap.MiddleName = this.studentMapping.middleName;
        this.studentRegMap.LastName = this.studentMapping.lastName;
         this.studentRegMap.Name = this.studentMapping.firstName + ' ' + this.studentMapping.middleName + ' ' + this.studentMapping.lastName;
         this.studentRegMap.Rpl_Contact_No__c = this.studentMapping.mobileNumber;
         this.studentRegMap.Rpl_Personal_Mail_ID__c = this.studentMapping.Rpl_Personal_Mail_ID__c;
         this.studentRegMap.Contact__c = this.contactId;
         this.handlestudentyourselfpage(this.studentRegMap);
         this.showToast();
     }
 }

 showToast() {
     const event = new ShowToastEvent({
         title: 'Registered Successfully',
         message: 'You have successfully registered for placement. Now please verify your email and fill your basic details',
         variant: 'success',
         mode: 'dismissable'
     });
     this.dispatchEvent(event);
 }


 /*Communicating from student yourself page to  reva placement Component */
 handlestudentyourselfpage(message) {
     const factor = message;
     this.dispatchEvent(new CustomEvent('revastudentyourselfpage', {
         detail: {
             message: factor
         }
     }));
 }

}