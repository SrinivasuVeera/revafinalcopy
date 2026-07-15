import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getGuestHouserequests from '@salesforce/apex/RevaGuestHouseController.getGuestHouserequests';
import cancelGuestHouseRequest from '@salesforce/apex/RevaGuestHouseController.cancelGuestHouseRequest';
import getChildRecords from '@salesforce/apex/RevaGuestHouseController.getChildRecords'; // Import your method
import { getRecord } from 'lightning/uiRecordApi';
const FIELDS = [
    'Reva_Guest_House_Booking__c.Status__c',
    'Reva_Guest_House_Booking__c.Check_In__c'
];
export default class RevaGuestHouseBooking extends NavigationMixin(LightningElement) {
    @track guestHouseRequest=[];
    @track childRecords = []; // To store child records
    @track showListView = true;
    @track showDetailPage = false;
    @track showNewRequestForm = false;
    @api recordId;
    @track isLoading = false;
    @track isModalOpen = false;
    @track error;
    @track isCancelButtonVisible ;
    @track CheckIn;
    @track status;
   
    // Define columns for the guest persons datatable
    @track guestPersonColumns = [
        { label: 'Name', fieldName: 'Guest_Name__c' },
        { label: 'Age', fieldName: 'Age__c' },
        { label: 'Gender', fieldName: 'Gender__c' }
    ];

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

 @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    leaveRequest({ error, data }) {
        if (data) {
            this.status = data.fields.Status__c.value;
            this.CheckIn = data.fields.Check_In__c.value;
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                  //  title: 'Error : Status not available',
                    message: 'Failed to retrieve leave request status.',
                    variant: 'error'
                })
            );
        }
    }
    @wire(getGuestHouserequests)
    wiredGuestHouseRequests({ error, data }) {
        if (data) {
            console.log("data", data);
            this.guestHouseRequest = data;
            console.log("guestHouseRequest List ==> ", this.guestHouseRequest);
            this.showListView = this.guestHouseRequest.length > 0;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.guestHouseRequest = undefined;
        }
    }

    @wire(getChildRecords, { guestHouseRequestId: '$recordId' })
    wiredChildRecords({ error, data }) {
        if (data) {
            this.childRecords = data;
            console.log("this.childRecords",this.childRecords);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.childRecords = [];
        }
    }

    handleClickBack() {
        this.showDetailPage = false;
        this.showListView = true;
    }

    handleShowNewCaseForm() {
        this.showListView = false;
        this.showNewRequestForm = true;
    }

    handleClose() {
        this.showNewRequestForm = false;
    }

    handleNameClick(event) {
        this.recordId = event.target.dataset.id;
        this.showListView = false;
        this.showDetailPage = true;
    }

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleConfirmCancellation() {
        cancelGuestHouseRequest({ guestHouseRequestId: this.recordId })
            .then(() => {
                this.isLoading = true;
                this.showToast('Success', 'Request has been cancelled successfully.', 'success');
                location.reload();
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error', 'An error occurred while cancelling the request.', 'error');
                console.error('Error occurred while cancelling the request:', error);
            });
    }

    handleBack() {
        this.showNewRequestForm = false;
        this.showDetailPage = false;
        this.showListView = true; 
    }

    @track purposeOfVisit = '';
    @track selectedVisitType = [];

    get visitTypeOptions() {
        return [
            { label: 'Private', value: 'Private' },
            { label: 'Official', value: 'Official' }
        ];
    }

    handlePurposeOfVisitChange(event) {
        this.purposeOfVisit = event.target.value;
    }

    handleVisitTypeChange(event) {
        this.selectedVisitType = event.detail.value;
    }
    
 get isButtonVisible() {
        return this.status !== 'Cancelled' && !this.CheckIn;
    }
}