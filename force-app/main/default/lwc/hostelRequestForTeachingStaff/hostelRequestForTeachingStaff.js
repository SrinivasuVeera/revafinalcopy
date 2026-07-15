import { LightningElement, wire, track, api } from 'lwc';
import getHostelCustomMetadataValue from '@salesforce/apex/revaSWCustomMetadataController.getHostelCustomMetadata';
import getCurrentTeachingContact from '@salesforce/apex/RevaHostelRequestController.getCurrentTeachingContact';
import revaHostelRoomAllotment from '@salesforce/apex/RevaHostelRequestAndAllotment.RevaHostelRoomAllotment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkHostelRequestExists from '@salesforce/apex/RevaHostelRequestController.checkHostelRequestExists';
import updateVacationDate from '@salesforce/apex/RevaHostelRequestController.updateVacationDate';
import REVAHostelDesktopImage from '@salesforce/resourceUrl/REVAHostelDesktopImage';
import REVAHostelImage from '@salesforce/resourceUrl/REVAHostelImage';
import getExistingHostelRequest from '@salesforce/apex/RevaHostelRequestController.getExistingHostelRequest';
import getLoggedInUserId from '@salesforce/apex/RevaHostelRequestAndAllotment.getLoggedInUserId';
import { NavigationMixin } from 'lightning/navigation';
//import revaHostelUITesting from 'c/revaHostelUITesting';
import updateHostelRequest from '@salesforce/apex/RevaHostelRequestController.updateHostelRequest';


export default class HostelRequestForTeachingstaff extends NavigationMixin(LightningElement) {
    @track hostelDescription;
    @track customMetadataValue;
    @track termsAccepted = false;
    @track currentUserContact = {};
    @track showUserDetails = false;
    @track preferredRoomSharing = '';
    @track selectedRoomSharing;
    @track isPremiumCheckbox = false;
    @track isPremium = false;
    @track customSettingsData = [];
    @track showToasts = false;
    @track totalHostelFee;
    @track shouldHideComponent = false;
    @track joiningDate;
    revaHostelImageUrl;
    showAcknowledgeAndRegister = false;
    @track existingHostelRequest;
    showRegistrationPage;
    @track showRevaMealBooking = false;
    @track showCancelConfirmation = false;
    @track showHostelSupportCase = false;
    @track isShowModal = false;
    @track showEndDateInput = false;
    @track showCancelButton = false;
    @track showVacatingDateModal = false;
    showHostelRegistrationPage = false;
    @track showThirdPage = true;
    @track cancellationReason = '';
    @track isLoading = false;
    @track isRegisterButtonDisabled = true;
    @track isDiabledAfterSubmit = false;
    @track showReapplyPopup = false; // New variable for reapply popup
    @track isShowApprovalhistory = true;
    @track isApprovalModelOpen = false;



    get floorOptions() {
        return [{ label: '4', value: '4' },
        { label: '3', value: '3' },
        { label: '2', value: '2' },
        { label: '1', value: '1' }]
    }

    connectedCallback() {

        if(window.innerWidth <= 768){
        this.revaHostelImageUrl = REVAHostelImage;
        }
        else{
            this.revaHostelImageUrl = REVAHostelDesktopImage;
        }

    }



    @wire(getExistingHostelRequest)
    wiredExistingHostelRequest({ error, data }) {
        if (data) {
            console.log("data1", data);
            if (data.length === 0) {
                this.showAcknowledgeAndRegister = true;
                return;
            }

            if (data.length > 0 && data[0]) {
                this.existingHostelRequest = data[0];
                console.log('this.existingHostelRequest', JSON.stringify(this.existingHostelRequest));

                this.showCancelButton = data[0].Room_Number__c && data[0].Status__c === 'Approved';
            }

        } else if (error) {
            console.error('Error fetching existing hostel request', error);
        }
    }



    get roomSharingOptions() {
        let options = [
            { label: '4 Sharing Extra Space', value: '4ExtraSpace' },
            { label: '4 Sharing', value: '4' },
            { label: '3 Sharing', value: '3' },
            { label: '2 Sharing', value: '2' }
        ];
        if (!this.isPremium &&this.currentUserContact.Gender === 'Female') {
            options = options.filter(option => option.value !== '8' && option.value !== '6' &&
                option.value !== '2' && option.value !== '4ExtraSpace');
        }
        if ( !this.isPremium && this.currentUserContact.Gender === 'Male') {
            options = options.filter(option => option.value !== '8' && option.value !== '6' &&
                option.value !== '1');
        }
        
        if (this.isPremium && this.currentUserContact.Gender === 'Female') {
            console.log('inside prime Male');
            options = options.filter(option => option.value === '2');

        };
        if (this.isPremium && this.currentUserContact.Gender === 'Male') {
            
            options = options.filter(option => option.value === '2');
        };
        console.log('i options'+options);
        return options;
    }

    handlePreferredRoomSharingChange(event) {
        this.preferredRoomSharing = event.detail.value;
    }
    @wire(getCurrentTeachingContact)
    wiredCurrentUserContact({ error, data }) {
        if (data) {
            this.currentUserContact = data;
            //this.employeeNumber = data.employeeNumber;
            console.log('Current User Contact:', data);
            // console.log('Current Pursuing Year:', this.currentPursuingYear); // Add this line
        } else if (error) {
            console.error('Error fetching current user contact', error);
        }
    }

    handlePreferredRoomSharingChange(event) {
        this.preferredRoomSharing = event.detail.value;
        console.log('preferredRoomSharing::::::' + this.preferredRoomSharing);
    }


    get isRegisterButtonDisabled() {
        //return !this.preferredRoomSharing || this.isDisabledAfterSubmit;
        if(!this.preferredRoomSharing ){
            return true;
        }
        else if(this.preferredRoomSharing  &&  this.isDisabledAfterSubmit) {
            return true;
        }
        else {
           return  false;
        }
           

        
    }
    get isStatusVacated() {
        return this.existingHostelRequest?.Status__c === 'Vacated';
    }

     get isStatusRejected() {
        return this.existingHostelRequest?.Status__c === 'Rejected';
    }

    handleRejoinHostelClick() {
     /*   updateHostelRequest({
            requestId: this.existingHostelRequest.Id,
            roomSharing: this.existingHostelRequest.Type__c,
            joiningDate: this.existingHostelRequest.Reva_Hostel_JoiningDate__c,
            isPremium: this.existingHostelRequest.Reva_Hostel_Premium_Room__c,
        })
            .then(() => {
                //this.showToast('Success', 'Request updated to Rejoin successfully', 'success');
                this.showAcknowledgeAndRegister = false;
                this.showHostelRegistrationPage = true;
                this.showRegistrationPage = true;
                this.existingHostelRequest = false;

            })
            .catch(error => {
                this.showToast('Error', 'Failed to update the request for rejoin', 'error');
                console.error('Error updating rejoin request:', error);
            });*/

                this.showAcknowledgeAndRegister = false;
                this.showHostelRegistrationPage = true;
                this.showRegistrationPage = true;
                this.existingHostelRequest = false;
    } 

     handleReapplyClick() {
        if (this.isStatusRejected) {
            this.showReapplyPopup = true;
           // this.preferredRoomSharing = this.existingHostelRequest.Room_Sharing__c;
            //this.joiningDate = this.existingHostelRequest.Reva_Hostel_JoiningDate__c;
            //this.isPremium = this.existingHostelRequest.Premium__c;
        }
    }

     handleApprovalHistory (event){

        this.isApprovalModelOpen = true;
    }

     // Closes the reapply popup
     closeReapplyPopup() {
        this.showReapplyPopup = false;
    }

    // Submits the updated request

handleSubmitReapply() {
    this.isLoading = true;
    updateHostelRequest({
        requestId: this.existingHostelRequest.Id,
        roomSharing: this.preferredRoomSharing,
        joiningDate: this.joiningDate,
        isPremium: this.isPremium
    })
    .then((result) => {
      //  this.showToast('Success', 'Request updated successfully', 'success');
      if (result && result.Status === 'Success'){
        this.showReapplyPopup = false;
        this.showToast('Success', 'Sucessfully Re-applied for Hostel', 'success');
       
        this.event1 = setTimeout(() => {        
            window.location.reload();
          }, 8000);
      }
      else if (result && result.Status === 'Not Available'){
        this.isLoading = false;
        this.showReapplyPopup = true;
        this.showToast('Warning', 'Room not available for the requested category!', 'Warning');
      }
      else {
        this.isLoading = false;
        this.showReapplyPopup = true;
        this.showToast('Error', 'An error occurred while processing your Re join request Contact admin', 'error'); 
      }
       
    })
    .catch(error => {
        this.isLoading = false;
        this.showToast('Error', 'An error occurred while processing your Re join request Contact admin', 'error');
        console.error(error);
    });
}

handleCloseModal(event){
    this.isApprovalModelOpen = false;

  }
    

    handlePremiumCheckboxChange(event) {
        this.isPremium = event.target.checked;
        // Uncheck the Non-Premium checkbox if Premium is checked
        if (this.isPremium) {
            // this.isNonPremium = false;

            // Show the fee variation message in a toast
            /* const feeVariationMessage = 'The fee for Premium rooms may vary. Please check the fee details.';
             this.showToast('Premium Room Fee Variation', feeVariationMessage, 'info'); */
        }
    }

    /*handleJoingingDate(event){
    this.joiningDate = event.target.value;
    console.log('joining date:::',this.joiningDate);
    }*/

    handleRegisterClick() {
        this.showAcknowledgeAndRegister = false;
        this.showHostelRegistrationPage = true;
        this.showRegistrationPage = true;
        console.log('this.showUserDetails============' + showUserDetails);
    }

    handleSubmitEvent(event) {
        this.isDiabledAfterSubmit == true;
        this.isLoading = true;
        

        console.log('User Id:', this.currentUserContact.Id);
        console.log('Occupancy:', this.preferredRoomSharing.split(' ')[0]);

        revaHostelRoomAllotment({
            requestForId: this.currentUserContact.Id,
            occupancy: this.preferredRoomSharing.split(' ')[0],
            isPremium: this.isPremium,
            joiningDate: this.joiningDate
        })
            .then(result => {
                console.log('Result of revaHostelRoomAllotment:', result);

                if (result && result.Status === 'Request Created!') {
                    // Check if the response status indicates a new record creation
                    this.event1 = setTimeout(() => {

                        window.location.reload();

                    }, 8000);
                    this.showToast('Success', 'Request Submitted Successfully', 'success');
                } else if(result && result.Status ==='Room not available for the requested category!'){
                    this.isLoading = false;
                    // Existing record found or other status
                    this.showToast('Warning', 'Room not available for the requested category!', 'warning');
                }
                else {
                    this.isLoading = false;
                    this.showToast('Error', 'An error occurred while processing your request contact Admin', 'error');
                }
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error', 'An error occurred while processing your request contact admin', 'error');
                console.error(error);
            });

            
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


    checkExistingHostelRequests() {
        // Call your Apex method to check if the logged-in user has existing hostel requests
        checkHostelRequestExists()
            .then(result => {
                // Set the existingHostelRequest property based on the result
                // this.existingHostelRequest = result;
                // Show user details if there are no existing records
                this.showUserDetails = !this.existingHostelRequest;
                this.showUserDetails = true;
            })
            .catch(error => {
                console.error('Error checking existing hostel requests:', error);
            });
    }

    handleCancelClick() {
        // Show the cancellation confirmation modal
        this.showCancelConfirmation = true;
    }
    showModalBox() {
        this.isShowModal = true;
    }

    // Method to hide the modal box
    closeModal() {
        // this.isShowModal = false;
        this.showEndDateInput = false;
    }
    // Method to handle cancellation confirmation
    handleCancelYesClick() {

        this.showCancelConfirmation = false;
        this.showEndDateInput = true;
        this.showVacatingDateModal = true;
    }

    // Method to handle cancellation denial
    handleCancelNoClick() {

        this.showCancelConfirmation = false;
        this.showEndDateInput = false;
    }
    handleEndDateChange(event) {
        // Get the selected end date value
        const selectedDate = new Date(event.target.value);

        // Get today's date
        const today = new Date();

        // Check if the selected date is prior to today's date
        if (selectedDate < today) {
            // Display an error message or prevent further action
            // For example, you can display a toast message
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'End date cannot be prior to today\'s date.',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);

            // Reset the end date value
            this.endDate = null;
        } else {
            // Update the end date
            this.endDate = event.target.value;
        }
    }

    handleCancellationReasonChange(event) {
        this.cancellationReason = event.target.value;
    }

    handleSubmitVacating(event) {
        // Handle submission of end date
        if (this.endDate && this.cancellationReason) {
            updateVacationDate({ recordId: this.existingHostelRequest.Id, vacationDate: this.endDate, cancellationReason: this.cancellationReason })
                .then(result => {
                    // Handle success
                    this.showToast('Success', 'Vacation date updated successfully.', 'success');
                    this.closeModal();
                    location.reload();
                    // Optionally, reset any form fields or navigate to another page
                })
                .catch(error => {
                    // Handle error
                    this.showToast('Error', error.body.message, 'error');
                    this.closeModal();
                    console.log('error.body.message===>' + error.body.message);
                });
        } else {
            // Handle if end date is not selected
            this.showToast('Error', 'Please select Future Vacating date/ Enter Reason', 'error');
        }
    }
    /************************JoinigDate newly added*********************************** */
    handleJoiningDateChange(event) {

        const selectedDate = new Date(event.target.value);

        const currentDate = new Date();
        this.joiningDate = event.target.value;

        if (this.joiningDate != null || this.joiningDate !== '') {
            this.isRegisterButtonDisabled = false;
        }
        if (selectedDate <= currentDate) {
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please select a future date for joining.',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
            this.isRegisterButtonDisabled = true;
            this.joiningDate = null;
        } else {

            this.joiningDate = event.target.value;
            this.isRegisterButtonDisabled = false;
        }
    }
    /************************************************************ */
    get isRoomAllotted() {
        return this.existingHostelRequest && (this.existingHostelRequest.Status__c === 'Room Allotted' || this.existingHostelRequest.Status__c === 'Vacate Rejected') ;

    }

    get isHostelNotVacated() {
        console.log('HH::' + this.existingHostelRequest.Status__c);
        console.log("eeee", this.existingHostelRequest.Status__c !== 'Vacated' && this.existingHostelRequest.Status__c !== 'Approved' && this.existingHostelRequest.Status__c !== '');
        return this.existingHostelRequest.Status__c !== 'Vacated' && this.existingHostelRequest.Status__c !== 'Approved' && this.existingHostelRequest.Status__c !== undefined && this.existingHostelRequest.Status__c !== 'Booked' && this.existingHostelRequest.Status__c !== 'Rejoin' && this.existingHostelRequest.Status__c !== 'Rejected' ;
    }


    redirectToRevaMealBooking() {
        /*this.showThirdPage = false; 
        this.showRevaMealBooking = true;
        this.showHostelSupportCase = false;*/
        this.showRevaMealBooking = true;
        this.showAcknowledgeAndRegister = false;
        this.showHostelSupportCase = false; // Hide hostel support case
        this.showRegistrationPage = false;

        //this.showRegistrationPage = false;

        /*this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__revaHostelUITesting'
            }
        });*/
    }

    /* redirectToRevaMealBooking(){
         this.showRevaMealBooking = true;
         //window.location.href = '/NonTeachingStaff/s/meal-booking';
     }*/
    redirectToRevaHostelCasePage() {
        /* this.showHostelSupportCase = true;
          this.showRevaMealBooking = false;*/

        this.showRevaMealBooking = false;
        this.showAcknowledgeAndRegister = false;
        this.showRegistrationPage = false;
        // this.showHostelSupportCase = true;
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent' // or use any other list view name
            }
        });
    }

    handleBackClick() {
        this.showRevaMealBooking = false;
        this.showHostelSupportCase = false;
        this.showAcknowledgeAndRegister = true;
        this.showRegistrationPage = false;

    }
    /***********Newly added for Data format bug 20102024 by veera********************** */
    get formattedJoiningDate() {
        const joiningDate = this.existingHostelRequest?.Reva_Hostel_JoiningDate__c;
        if (joiningDate) {
            const [year, month, day] = joiningDate.split('-'); // Split the date string
            return `${day}-${month}-${year}`; // Format as 'dd-MM-yyyy'
        }
        return ''; // Return an empty string if no date is available
    }
    get formatedVacatingDate(){
        const vactingDate = this.existingHostelRequest?.RevaHostelVacatingDate__c;
        if (vactingDate) {
            const [year, month, day] = vactingDate.split('-'); // Split the date string
            return `${day}-${month}-${year}`; // Format as 'dd-MM-yyyy'
        }
        return ''; // Return an empty string if no date is available
    }
}