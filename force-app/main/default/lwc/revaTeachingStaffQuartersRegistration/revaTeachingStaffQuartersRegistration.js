import { LightningElement, wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import quarterRequestProcess from '@salesforce/apex/RevaStaffQuartersRequestAndAllotment.quarterRequestProcess';
// import { getPicklistValues } from 'lightning/uiObjectInfoApi';
// import TYPE_FIELD from '@salesforce/schema/Staff_Quarters_Request__c.Type__c';
// import { getObjectInfo } from 'lightning/uiObjectInfoApi';
// import SQR_OBJECT from '@salesforce/schema/Staff_Quarters_Request__c';
import fetchInitialInfo from '@salesforce/apex/RevaStaffQuartersRequestAndAllotment.fetchInitialInfo';
import USER_ID from '@salesforce/user/Id';
import initiateVacation from '@salesforce/apex/RevaStaffQuartersRequestAndAllotment.initiateVacation';
import { getRecord } from 'lightning/uiRecordApi';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import  getCurrentNonTeachingContact  from '@salesforce/apex/RevaHostelRequestController.getCurrentTeachingContact';
//import  getTeachingContact  from '@salesforce/apex/RevaHostelRequestController.getCurrentTeachingContact';


export default class RevaTeachingStaffQuartersRegistration extends LightningElement {
    boolSpinner = false;
    roomTypeValues;
    userId = USER_ID;
    strMessage;
    showError = false;
    showWarning = false;
    showBooking = false;
    roomType;
    revaQuarterRequests;
    profileName;
    dataAvl = false;
    joiningDate;
    event1;
    @track currentUserContact = {};
    teachingStaffPicklistValues = [{ label: '1 BHK', value: '1 BHK' },{ label: '2 BHK', value: '2 BHK' } ];
    
    nonTeachingStaffPicklistValues = [{ label: '1 BHK', value: '1 BHK' },{ label: '2 BHK', value: '2 BHK' }];
    schoolDirectorStaffPicklistValues = [{ label: '2 BHK', value: '2 BHK' },{ label: '3 BHK', value: '3 BHK' }];
  
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [PROFILE_NAME_FIELD]
    })
    fetchUserProfile({data, error}){
        if(data){
            console.log(JSON.stringify(data));
            this.profileName = data.fields.Profile.displayValue;
           // this.fetchContact();//newly added
            console.log('PROFILE NAME  ' + JSON.stringify(this.profileName));
            if(this.profileName === 'Professor'){
                this.roomTypeValues = this.teachingStaffPicklistValues;
            }else if(this.profileName === 'Non Teaching Profile'){
                this.roomTypeValues = this.nonTeachingStaffPicklistValues;
            }
            else if(this.profileName === 'School Director'){
                this.roomTypeValues = this.schoolDirectorStaffPicklistValues;
            }
            else {
                this.roomTypeValues = this.teachingStaffPicklistValues;
            }
        }
    }

    handleJoiningDateChange(event) {
        const selectedDate = new Date(event.target.value);
        const today = new Date();
        if (selectedDate < today) {
            // Show error message
            this.showToast('Error', 'Joining date cannot be in the past.', 'error');
            this.joiningDate = null; // Reset the joining date
        } else {
            this.joiningDate = event.target.value;
        }
    }
    
    handleRoomType(event) {
        this.roomType = event.detail.value;
    }

    get disableQuarters() {
        return !this.roomType;
    }

    connectedCallback() {
        this.fetchData();
    }
    
    async fetchData() {
        try {
            this.showWarning = false;
            this.showError = false;
            this.showBooking = false;
            this.strMessage = '';
            const objResult = await fetchInitialInfo({ userId: this.userId });
            console.log('objResultfetched ==> ' + JSON.stringify(objResult));
            if (objResult && objResult.isWarning) {
                this.showWarning = true;
                this.strMessage = objResult.warningMessage;
                this.showBooking = false;
              /*  if (this.strMessage === 'You have vacated a room recently. Book a new one') {
                    this.showBooking = true;
                } */
            }
            if (objResult && objResult.isError) {
                
                
                this.showError = true;
                this.strMessage = objResult.errorMessage;
                this.showBooking = false;
            }
            if (objResult && !objResult.isError && !objResult.isWarning) {
                console.log('objResultfetched1 ==> ' +objResult);
                // this.event1 = setTimeout(() => {
                       // this.showToast('Success', objResult.successMessage, 'success');
                       //window.location.reload();
                       this.showBooking = true;
                        
                   // }, 6000);

                
            }
            this.dataAvl = true;
        } catch (error) {
            this.dataAvl = true;
            this.showBooking = false;
        }
    }

    async handleQuarters() {
        if (!this.joiningDate) {
            // Show error message if joining date is not selected
            this.showToast('Error', 'Please select a valid joining date.', 'error');
            return;
        }
        //window.location.reload();
        this.showSpinner();
        try {
            console.log(this.roomType);
            const objResult = await quarterRequestProcess({ roomType: this.roomType,joiningDate: this.joiningDate });
            console.log('result ' + JSON.stringify(objResult));
            if (objResult && objResult.isError) {
                this.showToast('Error', objResult.errorMessage, 'error');
            }
            if (objResult && objResult.isSuccess) {
                console.log('in');
                
                this.event1 = setTimeout(() => {
                    this.showToast('Success', objResult.successMessage, 'success');
                    window.location.reload();

                  }, 6000);

                //window.location.reload();
                //this.fetchData();
            }
            //this.hideSpinner();
            
        } catch (error) {
            this.handleErrors(error);
        }
    }
    handleErrors(error) {
        this.hideSpinner();
        this.showToast('Error', 'Some Error Occured', error);
    }
    showSpinner() {
        this.boolSpinner = true;
    }
    hideSpinner() {
        this.boolSpinner = false;
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
    async handleVacation(event) {
        this.showSpinner();
        try {
            const objResult = await initiateVacation({ userId: this.userId });
            console.log('objResultvactn ==> ' + objResult);
            if (objResult && objResult.isSuccess) {
                this.showToast('Success', objResult.successMessage, 'success');
            }
            if (objResult && objResult.isError) {
                this.showToast('Error', objResult.errorMessage, 'error');
            }
            this.hideSpinner();
        } catch (error) {
            this.handleErrors(error);
        }
    }


    // for current user contact details
    @wire(getCurrentNonTeachingContact)
    wiredCurrentUserContact({ error, data }) {
    if (data) {
        this.currentUserContact = data;
        console.log('Current User Contact:', data);
    } else if (error) {
        console.error('Error fetching current user contact', error);
    }
}

/*******newly added */
/*fetchContact() {
        if (this.profileName === 'Professor') {
            this.getProfessorContactDetails();
        } else if (this.profileName === 'Non Teaching Profile') {
            this.getNonTeachingStaffContactDetails();
        }
    }
    getProfessorContactDetails() {
        getTeachingContact()
            .then(result => {
                this.currentUserContact = result;
            })
            .catch(error => {
                console.error('Error fetching professor contact:', error);
            });
    }

    // Fetch non-teaching staff contact details
    getNonTeachingStaffContactDetails() {
        getCurrentNonTeachingContact()
            .then(result => {
                this.currentUserContact = result;
            })
            .catch(error => {
                console.error('Error fetching non-teaching staff contact:', error);
            });
    } */

    get isContactAvailable() {
        return Object.keys(this.currentUserContact).length > 0;
    }

    handleReApplyOpen(event){
        console.log('is parent');
        
        console.log('event.detail.isRegistrationOpen;=='+event.detail.isRegistrationOpen);
        
       this.showBooking = event.detail.isRegistrationOpen;
      
    }


}