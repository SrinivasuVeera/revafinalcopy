import { LightningElement, api, wire, track } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import cancelLeave from '@salesforce/apex/RevaHostelLeaveRequestController.cancelLeave';
import hasStatusUpdated from '@salesforce/apex/RevaHostelLeaveRequestController.hasStatusUpdated';
import { getRecord } from 'lightning/uiRecordApi';
import getLeaveRequestWithContact from '@salesforce/apex/RevaHostelLeaveRequestController.getLeaveRequestWithContact';

const FIELDS = [
    'REVA_Hostel_Leave_Request__c.Status__c',
    'REVA_Hostel_Leave_Request__c.Start_Date_and_Time__c',
    'REVA_Hostel_Leave_Request__c.End_Date__c',
    'REVA_Hostel_Leave_Request__c.End_Date_and_Time__c',
    'REVA_Hostel_Leave_Request__c.Id',
    'REVA_Hostel_Leave_Request__c.Scan__c',
    'REVA_Hostel_Leave_Request__c.Leave_Approved_Extension_Status__c',
    'REVA_Hostel_Leave_Request__c.Old_End_Date__c'
];

export default class RevaHostelLeaveRequestDetail extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @track isSaveButtonVisible = false;
    @track status;
    @track Startdate;
    @track checkday = true;
    @track parentName;
    @track parentPhoneNumber;
    @track showscanner = false;
    @track visibleScan = false;
    @track errorOnEndDate = false;
    @track endDateTime;
    @track endDate;
    @track endDateValue;
    @track isScan;
    @track leaveStartDate;
    @track isCancelDiabled = false;
    @track isEndDateDisabled = false;
    @track currentStatus;
    @track bookingIdSelected;
    @track isExtendStatus = false;

    @wire(getLeaveRequestWithContact, { recordId: '$recordId' })
    wiredLeaveRequest({ error, data }) {
        if (data) {
            this.status = data.Status;
            this.parentName = data.ParentName;
            this.parentPhoneNumber = data.ParentPhoneNumber;
        } else if (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    leaveRequest({ error, data }) {
        if (data) {
            this.status = data.fields.Status__c.value;
            this.Startdate = new Date(data.fields.Start_Date_and_Time__c.value);
            this.endDateTime = new Date(data.fields.End_Date_and_Time__c.value);
            this.endDate = new Date(data.fields.End_Date__c.value);
            this.isScan = data.fields.Scan__c.value;
            this.bookingIdSelected = data.fields.Id.value;
            const extendSatatus = data.fields.Leave_Approved_Extension_Status__c.value;
            console.log('extendSatatus---'+extendSatatus);
            
            this.leaveStartDate = this.Startdate.toISOString().split('T')[0];
            const todaydate = new Date().toISOString().split('T')[0];

            const endDate = this.endDateTime.toISOString().split('T')[0];
            if ((this.status === 'Check Out' && endDate === todaydate) || (this.status === 'Approved' && this.leaveStartDate <= todaydate)) {
                this.visibleScan = true;
            }
            if(extendSatatus != null  ){
                console.log('inside extension'+this.isExtendStatus);
                
                this.isExtendStatus = true;
            }

            this.checkCancelAndEndDate();
        } else if (error) {
            this.showToast('Error', 'Failed to retrieve leave request status.', 'error');
        }
    }

    checkCancelAndEndDate() {
        const todayDateTime = new Date();
        const todayPlus24Hours = new Date(todayDateTime.getTime() + 24 * 60 * 60 * 1000); // Add 24 hours to the current time

        if (this.status === 'Check Out' && this.endDateTime >= todayPlus24Hours) {
            this.isCancelDiabled = false;
            this.isEndDateDisabled = false;
        } else {
            this.isCancelDiabled = true;
            this.isEndDateDisabled = true;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    get isCancelButtonVisible() {
        const today = new Date();
        const startDate = new Date(this.Startdate);
        startDate.setHours(0, 0, 0, 0);
        today.setHours(0, 0, 0, 0);
        return this.status === 'Approved' && today < startDate;
    }

    handleBackClick() {
        if (this.status === 'Leave Requested') {
            this.showToast('Validation Error', 'Cancellation is not allowed at this stage', 'error');
            return;
        }
        this.dispatchEvent(new CustomEvent("clickback"));

        cancelLeave({ recordId: this.recordId })
            .then(() => {
                this.showToast('Success', 'Leave request has been cancelled successfully!', 'success');
                location.reload();
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    handleChange() {
        this.isSaveButtonVisible = true;
    }

    handleEndDateChange(event) {
        this.currentStatus = this.template.querySelector('lightning-input-field[data-id="statusField"]')?.value;
        const selectedDate = new Date(event.target.value);
        const selectedDateISO = selectedDate.toISOString().split('T')[0];
        this.endDateValue = event.target.value;

        const currentDate = new Date();
        const currentDateISO = currentDate.toISOString().split('T')[0];

        const todayPlus24Hours = new Date(currentDate.getTime() + 24 * 60 * 60 * 1000);

        if (this.currentStatus === 'Check Out' && selectedDateISO <= currentDateISO) {
            this.showEndDateError('Selected End date should not be less than or equal to today\'s date. You can extend/shorten your leave at least 24 hours before the current time.');
        } else if (this.currentStatus === 'Check Out' && selectedDate < todayPlus24Hours) {
            this.showEndDateError('You can extend or shorten your leave at least 24 hours before the current date and time.');
        } else {
            this.errorOnEndDate = false;
            this.isSaveButtonVisible = true;
        }
    }

    showEndDateError(message) {
        this.errorOnEndDate = true;
        this.endDateValue = this.endDateTime;
        this.showToast('Validation Error', message, 'error');
    }

    handleSuccess() {
        this.showToast('Success', 'Record has been updated successfully!', 'success');
        location.reload();
    }

    handleError(event) {
        this.showToast('Error', event.detail.message, 'error');
    }

    handleSubmit(event) {
        event.preventDefault();

        const fields = event.detail.fields;

        console.log('fields--'+fields);

        const startDate = new Date(fields.Start_Date_and_Time__c);

        const endDate = new Date(fields.End_Date_and_Time__c);

        console.log('new end date---'+fields.End_Date_and_Time__c);
        console.log('old end date---'+this.endDateTime.toISOString());
        
        if( fields.End_Date_and_Time__c != this.endDateTime.toISOString() ){
            console.log('inside date change'+fields.Old_End_Date__c);
            console.log('inside date change 2'+fields.Leave_Approved_Extension_Status);
            
            fields['Old_End_Date__c'] = this.endDateTime.toISOString();  
            fields['Leave_Approved_Extension_Status__c'] = 'Submitted';  
        }

         //fields.Old_End_Date__c = this.endDateTime;
         console.log('field 33s--'+fields);
        if (endDate <= startDate) {
            this.showToast('Validation Error', 'End date should not be before the start date.', 'error');
        } else if (this.errorOnEndDate) {
            this.showToast('Validation Error', 'Can you check the end date before submit', 'error');
        } else {
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
    }

    handleScan() {
        this.showscanner = true;
    }

    closeModal() {
        this.showscanner = false;
    }

    intervalId;

    connectedCallback() {
        this.startStatusCheck();
    }

    disconnectedCallback() {
        this.stopStatusCheck();
    }

    startStatusCheck() {
        this.intervalId = setInterval(() => this.checkStatusUpdate(), 4000);
    }

    stopStatusCheck() {
        if (this.intervalId) {
            clearInterval(this.intervalId);
        }
    }

    checkStatusUpdate() {
        hasStatusUpdated({ selectedId: this.bookingIdSelected })
            .then((statusUpdated) => {
                if (statusUpdated) {
                    this.closeModal();
                    this.stopStatusCheck();
                }
            })
            .catch((error) => {
                console.error('Error checking status update:', error);
            });
    }
}