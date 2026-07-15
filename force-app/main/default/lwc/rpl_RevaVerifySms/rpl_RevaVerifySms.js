import { LightningElement , wire, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendOtpToEmail from '@salesforce/apex/RPL_StudentRegistrationDetails.sendOtpToEmail';
import sendOtpToMobile from '@salesforce/apex/RPL_StudentRegistrationDetails.sendOtpToMobile';

import insertDetails from '@salesforce/apex/RPL_StudentRegistrationDetails.insertStudentRegDetails';

import fetchContactDetails from '@salesforce/apex/RPL_StudentRegistrationDetails.getContactDetails';
import getRevaPlacementDetails from '@salesforce/apex/RPL_StudentRegistrationDetails.getPlacementDetails';

export default class Rpl_RevaVerifySms extends LightningElement {
     @api placementRegistrationText;
    @api contactId;
    @api studentRegform;
    @track studentRegToInsert = {};
    isSpinner;
    timeRemaining = 300;
    showEmailResendButton = false;
    isEmailVerified = false;
    showSmsResendButton = false;
  

    userEnteredEmailOtp;
    userEnteredSmsOtp;
    returnedOtpvalue;
    countDownTime;
    fullName;
   

    connectedCallback(){
        this.fullName = this.studentRegform.Name;
        this.studentRegToInsert.Name = this.studentRegform.Name;   
        this.studentRegToInsert.Rpl_First_Name__c  = this.studentRegform.FirstName;
        this.studentRegToInsert.Rpl_Middle_Name__c = this.studentRegform.MiddleName;
        this.studentRegToInsert.Rpl_Last_Name__c = this.studentRegform.LastName;   
        
        this.sendOtpToEmail();
    }
    toTitleCase(str) {
        return str.replace(/\w\S*/g, function(word) {
            return word.charAt(0).toUpperCase() + word.substr(1).toLowerCase();
        });
    }

    handleEmailInput(event) {
        this.userEnteredEmailOtp = event.target.value;
    }
    handleSmsInput(event){
        this.userEnteredSmsOtp = event.target.value;
    }
    getContactDetails(contactId) {
        fetchContactDetails({
                contactId: contactId
            })
            .then(result => {
                if (result) {
                    let element = result[0];
                    this.studentRegToInsert.Rpl_SRN__c = element.SRN_Number__c ? element.SRN_Number__c : '';
                    this.studentRegToInsert.Rpl_Date_of_Birth__c = element.Birthdate ? element.Birthdate : '';
                    //this.studentRegToInsert.Rpl_Contact_No__c = element.MobilePhone;
                    this.studentRegToInsert.Rpl_School__c = element.School_Name__c ? element.School_Name__c : '';
                    this.studentRegToInsert.Rpl_Parents_Contact_No__c = element.RH_Parent_Phone_Number__c ? element.RH_Parent_Phone_Number__c : '';
                    this.studentRegToInsert.Contact__c = contactId;
                    // this.studentRegToInsert.Rpl_Personal_Mail_ID__c =  element.Personal_Email__c;
                    this.studentRegToInsert.VH__c = element.Primary_Academic_Program__r.Rpl_Placement_Vertical_Head__c ? element.Primary_Academic_Program__r.Rpl_Placement_Vertical_Head__c : '';
                    this.studentRegToInsert.Rpl_Branch__c = element.Primary_Academic_Program__r.Name ? element.Primary_Academic_Program__r.Name : '';
                    this.studentRegToInsert.Rpl_University_Mail_ID__c = element.hed__UniversityEmail__c ? element.hed__UniversityEmail__c : '';
                    this.studentRegToInsert.Father_Name__c = element.Father_Name__c ? element.Father_Name__c : '';
                    this.studentRegToInsert.Mother_Name__c = element.Mother_Name__c ? element.Mother_Name__c : '';
                    this.studentRegToInsert.Rpl_Gender__c = element.hed__Gender__c ? element.hed__Gender__c : '';
                    this.studentRegToInsert.Rpl_Parents_Contact_No__c = element.RH_Parent_Phone_Number__c ? element.RH_Parent_Phone_Number__c : '';

                    //this.studentRegToInsert.Course_Name__c = element.Primary_Academic_Program__r.Program_Type__c =="UG"?"UG":element.Program_Name__c;
                }
                this.getRevaPlacementDetails();

            })
            .catch(error => {
                const evt = new ShowToastEvent({
                title: 'Error While Processing OTP',
                message: error.body.message,
                variant: 'destructive'
            });
            this.dispatchEvent(evt);
                this.isSpinner = false;
            });
    }
    getRevaPlacementDetails() {
        getRevaPlacementDetails({
                contactId: this.contactId
            })
            .then(result => {

                this.studentRegToInsert.Reva_Placement__c = result && result.revaPlacementId ? result.revaPlacementId : '';
                this.insertStudentRegistration();
            })
            .catch(error => {
                const evt = new ShowToastEvent({
                title: 'Error While Processing OTP',
                message: error.body.message,
                variant: 'destructive'
            });
            this.dispatchEvent(evt);
                this.isSpinner = false;
            });
    }

    insertStudentRegistration(){
         this.studentRegToInsert.Rpl_Personal_Mail_ID__c = this.studentRegform.Rpl_Personal_Mail_ID__c;

            this.studentRegToInsert.Name = this.fullName;
            this.studentRegToInsert.Rpl_Contact_No__c = this.studentRegform.Rpl_Contact_No__c;
            
                insertDetails({
                    stdRegDetails: this.studentRegToInsert
                }).then(result => {
                   

                const evt = new ShowToastEvent({
                    title: 'Success!',
                    message: 'OTP Verified Successfully',
                    variant: 'success'
                });
                this.dispatchEvent(evt);
                this.dispatchEvent(new CustomEvent('otpverified'));
                            })
                .catch(err => {
                })
                this.isSpinner = false;
            } 

     handleVerifyEmail(event) {
        if (!this.timeRemaining > 0) {
            const evt = new ShowToastEvent({
                title: 'Expired OTP',
                message: 'Your OTP has expired. Please click "Resend OTP" to request a new one.',
                variant: 'destructive'
            });
            this.dispatchEvent(evt);
            return;
        } else if (this.userEnteredEmailOtp != this.returnedOtpvalue) {
            const evt = new ShowToastEvent({
                title: 'Invalid OTP',
                message: 'The entered OTP is invalid.',
                variant: 'destructive'
            });
            this.dispatchEvent(evt);
            return;
        } else if (this.userEnteredEmailOtp == this.returnedOtpvalue) {
            this.isSpinner = true;
            this.isEmailVerified = true;
            const evt = new ShowToastEvent({
                title: 'Email OTP Verified Successfully',
                message: '',
                variant: 'success'
            });
            this.dispatchEvent(evt);
            this.sendOtpToMobile();
        }
    }

    sendOtpToEmail() {
        this.timeRemaining = 300;
        this.startTimer();
        sendOtpToEmail({
                personEmailId: this.studentRegform.Rpl_Personal_Mail_ID__c
            })
            .then(result => {
                this.returnedOtpvalue = result;
            })
            .catch(error => {});
    }

    sendOtpToMobile(){
        this.isSpinner = false;
        this.timeRemaining = 300;
        this.startTimer();
        sendOtpToMobile({
                phoneNumber: this.studentRegform.Rpl_Contact_No__c
            })
            .then(result => {
                this.returnedOtpvalue = result;
            })
            .catch(error => {});

    }
    handleVerifySms(){
        if (!this.timeRemaining > 0) {
            const evt = new ShowToastEvent({
                title: 'Expired OTP',
                message: 'Your OTP has expired. Please click "Resend OTP" to request a new one.',
                variant: 'destructive'
            });
            this.dispatchEvent(evt);
            return;
        } else if (this.userEnteredSmsOtp != this.returnedOtpvalue) {
            const evt = new ShowToastEvent({
                title: 'Invalid OTP',
                message: 'The entered OTP is invalid.',
                variant: 'destructive'
            });
            this.dispatchEvent(evt);
            return;
        } else if ( this.userEnteredSmsOtp == this.returnedOtpvalue) {
            this.isSpinner = true;
            this.isEmailVerified = true;
            this.getContactDetails(this.contactId);           
        }
    }
    handleResendSms(){
        this.timeRemaining = 300;
        this.showEmailResendButton = false;
        this.sendOtpToMobile();        
    }
    handleResendEmail() {
        this.timeRemaining = 300;
        this.sendOtpToEmail();
        this.showEmailResendButton = false;
        sendOtpToEmail({
                personEmailId: this.studentRegform.Rpl_Personal_Mail_ID__c
            })
            .then(result => {
                this.returnedOtpvalue = result;
            })
            .catch(error => {
                console.error('Error sending OTP:', error);
            });
    }

    startTimer() {
        const timerInterval = setInterval(() => {
            if (this.timeRemaining > 0) {
                this.timeRemaining--;
                this.formatTime(this.timeRemaining);
            } else {
                this.showEmailResendButton = true;
                clearInterval(timerInterval);
            }
        }, 1000);
    }

    formatTime(seconds) {
        const minutes = Math.floor(seconds / 60);
        const remainingSeconds = seconds % 60;
        this.countDownTime = `${minutes} : ${remainingSeconds < 10 ? '0' : ''}${remainingSeconds}`;
    }
}