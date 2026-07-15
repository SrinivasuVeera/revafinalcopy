import { LightningElement, wire, api, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import isTodayWithinStartDateRange from '@salesforce/apex/RegiFormFileController.isTodayWithinStartDateRange';
import checkRegistrationEligibility from '@salesforce/apex/RegiFormFileController.checkRegistrationEligibility';
import updateContactField from '@salesforce/apex/RegiFormFileController.updateContactRegistrationField';
import checkRegistration from '@salesforce/apex/RegiFormFileController.checkSemRegistrationField';
import displaySemDetails from '@salesforce/apex/RegiFormFileController.displayDetails';
import sendNotifications from '@salesforce/apex/RegiFormFileController.sendNotifications';
import USER_ID from '@salesforce/user/Id';
import CONTACT_ID_FIELD from '@salesforce/schema/User.ContactId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const CONTACT_FIELDS = ['Contact.File_Passport_Size_Photo__c', 'Contact.hed__Gender__c', 'Contact.Name', 'Contact.MailingStreet', 'Contact.MailingCity', 'Contact.MailingState', 'Contact.MailingCountry', 'Contact.MailingPostalCode', 'Contact.Application_Number__c', 'Contact.SRN_Number__c', 'Contact.MobilePhone', 'Contact.School_Name__c', 'Contact.Active_Section__c	', 'Contact.Program_Batch_Name__c', 'Contact.Date_of_Admission_in_Institute__c', 'Contact.Admission_Mode__c', 'Contact.Enrollment_Type__c', 'Contact.Student_Status__c', 'Contact.Birthdate', 'Contact.Email','Contact.Program_Batch__c',];

export default class RegiAcademicYear extends LightningElement {

    acdemicYear = '2025-26';
    contactRecId; 
    ProgramBatch;
    uploading = false;
    uploadVisible = true;
    showTermCond = false;
    showPayFeesMsg = false;
    showNotActivePage = false;
    @track 
    isButtonDisabled = true;
    semester;
    showSpinner = false;
    showAlreadyReg = false;
    showRegSuccessful = false;
    displaySemesterName = "";   

    @wire(getRecord, { recordId: USER_ID, fields: CONTACT_ID_FIELD })
	wiredUser({ error, data }) {
		if (data) {
			this.contactRecId = getFieldValue(data, CONTACT_ID_FIELD);
			console.log('Selected Contact Id -->'+this.contactRecId);       
		} else if (error) {
			this.showErrorToast(error.body.message);

		}
	}

    // Retrieve the Contact record based on the ContactId retrieved from the User record
	@wire(getRecord, { recordId: '$contactRecId', fields: CONTACT_FIELDS })
	wiredContactRecord({ error, data }) {
		if (data) {
			this.contactRecord = data;
			this.ProgramBatch = getFieldValue(this.contactRecord, 'Contact.Program_Batch__c') || 'N/A';
            console.log('Contact Record Program Batch -->'+this.ProgramBatch);  
            this.onLoadDisplayData();
            this.checkRegistrationField();
		} else if (error) {
			this.showErrorToast(error.body.message);
		}
	}   
    	

    //Success Notification
	showSuccessToast() {
		const event = new ShowToastEvent({
			title: 'Success',
			message: 'Your registration is successfull',
			variant: 'success',
			mode: 'dismissable'
		});
		this.dispatchEvent(event);
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

    handleCheckboxChange(event) {
        this.isButtonDisabled = !event.target.checked;
    }

    handleButtonClick() {        
        this.updateContactField();
    }

    checkEligibility(){             
        checkRegistrationEligibility({contactId : this.contactRecId, ProgramBatchId : this.ProgramBatch})
        .then((result) => {
        //   console.log('checkRegistrationEligibility -->'+result);
           this.regEligible = result;
            if(result){
                this.showTermCond = true;
            }else{
                this.showPayFeesMsg = true;           
            }        
       })
       .catch(error => {
           console.error('Error dateRange', error);
       })
   }

   dateRange(){        
         isTodayWithinStartDateRange({ProgramBatchId : this.ProgramBatch, contactId : this.contactRecId})
         .then((result) => {
        //    console.log('isTodayWithinStartDateRange -->'+result);
            this.semester = result;            
            if(result != 0){
                this.checkEligibility();
            }else{
                this.showNotActivePage = true;
            }
            
        })
        .catch(error => {
            console.error('Error dateRange', error);
        })
    }

    updateContactField(){
        this.showSpinner = true;
        updateContactField({contactId : this.contactRecId, semester : this.semester, ProgramBatchId : this.ProgramBatch})
            .then((result) => {
                if(result == 1){
                    this.showSuccessToast();
                    this.showSpinner = false;
                    this.showRegSuccessful = true;
                    this.showTermCond = false;
                    this.handleClickSendEmail();
                }else{
                    this.showErrorToast('Some Issue occured your record is not saved');
                    console.log('Issue while updating record in a table');
                }                
            })
            .catch(error => {
                console.error('Error while updating Sem_Registered__c field ', error);
            })
            .finally(() => {
                this.showSpinner = false; // Hide uploading indicator or enable button                
            });
    }
    // Check registration is completed or not
    checkRegistrationField(){
        this.showSpinner = true;
        checkRegistration({contactId : this.contactRecId, ProgramBatchId : this.ProgramBatch})
            .then((result) => {
                console.log('checkRegistrationField12 -->'+result);
                if(result){
                    this.dateRange();
                }else{                    
                    this.showAlreadyReg = true;                 
                } 
                this.showSpinner = false;               
            })
            .catch(error => {
                console.error('Error while retriving checkRegistration method ', error);
            })
            .finally(() => {
                this.showSpinner = false; // Hide uploading indicator or enable button                
            });
    }

    onLoadDisplayData(){
        this.showSpinner = true;
        displaySemDetails({ProgramBatchId : this.ProgramBatch, contactId : this.contactRecId})
        .then((result) => {
            console.log('onLoadDisplayData -->'+result);
            if(result != null){
                this.displaySemesterName = '('+result+')';
            }else{                    
                console.log('Some error while fetching display details');             
            } 
            this.showSpinner = false;               
        })
        .catch(error => {
            console.error('Error while retriving onLoadDisplayData method', error);
        })
        .finally(() => {
            this.showSpinner = false; // Hide uploading indicator or enable button                
        });
    }

    get cardTitle() {
        return `Registration for the academic year ${this.acdemicYear} ${this.displaySemesterName}`;
    }

    handleClickSendEmail() {
        sendNotifications({ contactId : this.contactRecId,semesterNum : this.semester,ProgramBatchId : this.ProgramBatch})
            .then(result => {
                console.log('Email sent successfully'+result);
                // Handle success as needed
            })
            .catch(error => {
                console.error('Error sending email', error);
                // Handle error as needed
            });
    }
      
    
}