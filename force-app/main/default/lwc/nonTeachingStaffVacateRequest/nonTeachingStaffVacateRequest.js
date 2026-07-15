import updateVacationRequest from '@salesforce/apex/VacationRequestController.updateVacationRequest';
import sendConfirmationEmail from '@salesforce/apex/VacationRequestController.sendConfirmationEmail';
import attachNOCToStaffQuatresRequest from '@salesforce/apex/attachNOCToStaffQuatresRequest.createStaffQuartersRequestAttachment';
import Id from "@salesforce/user/Id";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api, track } from 'lwc';
//import getUserDetails from '@salesforce/apex/revaTeachingStaffQuatersVacation.getUserDetails';

export default class NonTeachingStaffVacateRequest extends LightningElement {
    @track user;
    @track showForm = false;
    //@track isDisabled = false;
    //@track disable;
    userId = Id;
    selectedVacateDate;
    selectedVacateReason;
    @api requestId;

get disable(){
    return (!this.selectedVacateDate || !this.selectedVacateReason);
}

    connectedCallback() {
       
    }

    // @wire(getUserDetails, { userId: '$userId' })
    // wiredUser({ error, data }) {
    //     if (data) {
    //         this.user = data[0];
    //     } else if (error) {
    //         console.error('Error fetching user details:', error);
    //     }
    // }

    handleClick() {
        this.showForm = true;
        console.log('Request ID from parent:', this.requestId);
    }

    handleFormSubmit() {
        const formattedVacateDate = new Date(this.selectedVacateDate).toISOString().split('T')[0];
        console.log('Formatted Vacate Date:', formattedVacateDate);
        updateVacationRequest({ vacateDate: formattedVacateDate, staffQuartersRequestId: this.requestId, selectedVacateReason: this.selectedVacateReason })
            .then(result => {
                if (result === 'Success') {
                    console.log('Record updated successfully');
                    this.disable = true;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Vacting request submitted successfully',
                            variant: 'success',
                        })
                    );
                    
                    //Send confirmation mail to user
                    console.log('THIS.USER ID********' + this.userId);
                    attachNOCToStaffQuatresRequest({ requestId: this.requestId })
                        .then(result => {
                            console.log('Email sent successfully:', result);

                        })
                        .catch(error => {
                            console.error('Error sending email:', error);

                        });
                      
                    // Add any additional logic or UI updates after successful record creation
                } else {
                    console.error('Error creating record:', result);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Error creating record: ' + result,
                            variant: 'error',
                        })
                    );
                }
            })
            .catch(error => {
                console.error('Error creating record:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error creating record: ' + error.body.message,
                        variant: 'error',
                    })
                );
            });
           
        // const childComponent = this.template.querySelector('c-mess-management-n-o-c1');
        // if (childComponent) {
        //     // Call the method in the child component
        //     childComponent.handleSubmit();
        // } else {
        //     console.error('Child component not found');
        // }
        window.location.reload();
    }
    handleDateChange(event) {
        // Update the selectedVacateDate when the date input changes
        let searchCmp = this.template.querySelector(".dateCmps");
        const selectedDate = new Date(event.target.value);
        const today = new Date();

        if (selectedDate < today) {
            searchCmp.setCustomValidity("Vacating date cannot be in the past/Today date");
            this.selectedVacateDate ='';
        } else {
            searchCmp.setCustomValidity("");
            this.selectedVacateDate = event.target.value;
        }
        searchCmp.reportValidity();

    }

    handleReasonChange(event) {
        this.selectedVacateReason = event.target.value;
    }
    handleBackClick (){
        this.showForm = false;
    }
}