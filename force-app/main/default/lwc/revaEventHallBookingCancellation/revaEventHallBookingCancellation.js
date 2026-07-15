import { LightningElement, track } from 'lwc';
// import { NavigationMixin } from 'lightning/navigation';
import getUserFacilityRequests from '@salesforce/apex/FacilityRequestCancellationController.getUserFacilityRequests';
import cancelFacilityRequest from '@salesforce/apex/FacilityRequestCancellationController.cancelFacilityRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import BASE_PATH from '@salesforce/label/c.NonTeachingFacultyEventURL';

export default class FacilityRequestCancellation extends LightningElement {
    @track allRequests = [];
    @track filteredRequests = [];
    @track isCurrentActive = true;
    @track isLoading = false;
    @track showCancelModal = false;
    @track selectedRecordId;
    @track cancelReason = '';
    label = { basepath: BASE_PATH };

    columns = [
        {label: 'Facility Request ID', fieldName: 'Name'  },
        { label: 'Facility Type', fieldName: 'Facility_Type__c' },
        { label: 'Building', fieldName: 'Building_Name__c' },
        { label: 'Floor', fieldName: 'Floor__c' },
        { label: 'Room No', fieldName: 'Room_No__c' },
        { label: 'Start Date', fieldName: 'Start_Date__c', type: 'date' },
        { label: 'End Date', fieldName: 'End_Date__c', type: 'date' },
        { label: 'Start Time', fieldName: 'Start_Time__c' },
        { label: 'End Time', fieldName: 'End_Time__c' },
        { label: 'Status', fieldName: 'TemplateName__c' },
        { label: 'Amenities', fieldName: 'Additional_Amenities_Required2__c' },
        {   label: 'Action',
            type: 'button',
            fixedWidth: 150,
            typeAttributes: {
                label: 'Cancel Booking',
                name: 'cancel',
                variant: 'destructive',
                disabled: { fieldName: 'disableCancel' }
                //disabled: { fieldName: 'isCompleted' }
            }
        }
        
    ];
    

    // Button variants
    get currentVariant() {
        return this.isCurrentActive ? 'brand' : 'neutral';
    }
    get completedVariant() {
        return this.isCurrentActive ? 'neutral' : 'brand';
    }

    connectedCallback() {
        this.loadRequests();
    }

    /* Load all facility requests
    loadRequests() {
        this.isLoading = true;
        getUserFacilityRequests()
            .then((data) => {
                this.allRequests = data.map(item => ({
                    ...item,
                    Start_Time__c: this.formatTime(item.Start_Time__c),
                    End_Time__c: this.formatTime(item.End_Time__c),
                    isCompleted: new Date(item.End_Date__c) < new Date(),
                    canCancel: item.TemplateName__c === 'Approved' 
                }));
                this.filterRequests();
            })
            .catch((error) => {
                this.showToast('Error', error.body?.message || 'Error loading requests', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }*/

      loadRequests() {
    this.isLoading = true;

    getUserFacilityRequests()
        .then((data) => {
            this.allRequests = data.map(item => {
                const isCompleted = new Date(item.End_Date__c) < new Date();
                const isRejected = item.TemplateName__c === 'Rejected';

                return {
                    ...item,
                    Start_Time__c: this.formatTime(item.Start_Time__c),
                    End_Time__c: this.formatTime(item.End_Time__c),

                    isCompleted: isCompleted,

                    // Disable ONLY when Rejected or Completed
                    disableCancel: isRejected || isCompleted
                };
            });

            this.filterRequests();
        })
        .catch((error) => {
            this.showToast('Error', error.body?.message || 'Error loading requests', 'error');
        })
        .finally(() => {
            this.isLoading = false;
        });
}



    // Filter by current or completed
    filterRequests() {
        const today = new Date();
        this.filteredRequests = this.allRequests.filter(req => {
            const endDate = this.normalizeDate(req.End_Date__c);
            if (this.isCurrentActive) {
                return endDate >= today;
        } else {
            return endDate <= today;
        }
            //return this.isCurrentActive ? endDate >= today : endDate <= today;
            
        });
    }

    handleShowCurrent() {
        this.isCurrentActive = true;
        this.filterRequests();
    }

    handleShowCompleted() {
        this.isCurrentActive = false;
        this.filterRequests();
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('Row Action Triggered:', actionName);
        console.log('Selected Row:', JSON.stringify(row));
        if (actionName === 'cancel') {
            this.selectedRecordId = row.Id;
            this.cancelReason = '';
            this.showCancelModal = true;
            
        }
    }

    // Handle reason input
    handleReasonChange(event) {
        this.cancelReason = event.target.value;
    }

    // Close modal
    closeCancelModal() {
        this.showCancelModal = false;
        this.selectedRecordId = null;
        this.cancelReason = '';
    }

    // Confirm cancellation
    confirmCancel() {

        console.log('Cancel Confirmation Started');
    console.log('Selected Record Id:', this.selectedRecordId);
    console.log('Entered Reason:', this.cancelReason);
        if (!this.cancelReason.trim()) {
            console.warn('Validation Failed: No reason entered');
            this.showToast('Validation Error', 'Please enter a reason for cancellation.', 'warning');
            return;
        }

        this.isLoading = true;
        console.log('Calling Apex cancelFacilityRequest...');
        cancelFacilityRequest({ recordId: this.selectedRecordId, reason: this.cancelReason })
            .then((result) => {
                 console.log('Apex Result:', result);
                this.showToast('Success', result, 'success');
                if (window.location.pathname.includes('/s/')) {
                    console.log('Inside Community Page. Redirecting to Base Path:', this.label.basepath);
                const basePath = this.label.basepath;
                this[NavigationMixin.Navigate]({
                    type: "standard__webPage",
                    attributes: { url: basePath }
                });
                return; // stop further code
            }
            console.log('Reloading Requests After Cancellation...');
                this.loadRequests();
            })
            .catch((error) => {
                console.error('Cancellation Error:', error.body.message);
                this.showToast('Error', error.body?.message || 'Cancellation failed', 'error');
            })
            .finally(() => {
                console.log('Cancel Process Completed. Closing modal...');
                this.isLoading = false;
                this.closeCancelModal();
            });
    }

          /*  confirmCancel() {

    console.log('Cancel Confirmation Started');
    console.log('Selected Record Id:', this.selectedRecordId);
    console.log('Entered Reason:', this.cancelReason);

    if (!this.cancelReason.trim()) {
        this.showToast('Validation Error', 'Please enter a reason for cancellation.', 'warning');
        return;
    }

    this.isLoading = true;
    console.log('Calling Apex cancelFacilityRequest...');

    cancelFacilityRequest({ recordId: this.selectedRecordId, reason: this.cancelReason })
        .then((result) => {
            console.log('Apex Result:', result);

            // 🔥 FIX STARTS HERE
            if (result?.status === 'success') {
                this.showToast('Success', result.message, 'success');
            } else {
                this.showToast('Error', result.message || 'Cancellation failed', 'error');
                return; //  Do not refresh or navigate
            }
            // 🔥 FIX ENDS HERE

            // Community navigation
            if (window.location.pathname.includes('/s/')) {
                console.log('Inside Community Page. Redirecting to Base Path:', this.label.basepath);
                this[NavigationMixin.Navigate]({
                    type: "standard__webPage",
                    attributes: { url: this.label.basepath }
                });
                return;
            }

            console.log('Reloading Requests After Cancellation...');
            this.loadRequests();
        })
        .catch((error) => {
            console.error('Cancellation Error:', error);
            this.showToast('Error', error.body?.message || 'Cancellation failed', 'error');
        })
        .finally(() => {
            console.log('Cancel Process Completed. Closing modal...');
            this.isLoading = false;
            this.closeCancelModal();
        });
} */

    // Utility: Normalize date
    normalizeDate(dateStr) {
        const d = new Date(dateStr);
        return new Date(d.getFullYear(), d.getMonth(), d.getDate());
    }

    // Utility: Time format
    formatTime(timeValue) {
        if (!timeValue) return '';
        try {
            let timeString = '';
            if (typeof timeValue === 'string' && timeValue.includes(':')) {
                timeString = timeValue.replace('Z', '');
            } else if (!isNaN(timeValue)) {
                const totalSeconds = parseInt(timeValue) / 1000;
                const hours = Math.floor(totalSeconds / 3600);
                const minutes = Math.floor((totalSeconds % 3600) / 60);
                return this.to12HourTime(hours, minutes);
            } else {
                return '';
            }

            const [hours, minutes] = timeString.split(':');
            return this.to12HourTime(parseInt(hours), parseInt(minutes));
        } catch (e) {
            console.error('Error formatting time:', e);
            return '';
        }
    }

    to12HourTime(hours, minutes) {
        if (isNaN(hours) || isNaN(minutes)) return '';
        const ampm = hours >= 12 ? 'PM' : 'AM';
        hours = hours % 12 || 12;
        const minStr = minutes < 10 ? '0' + minutes : minutes;
        return `${hours}:${minStr} ${ampm}`;
    }

    get noData() {
        return !this.isLoading && this.filteredRequests.length === 0;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
    handleNewClick() {
    this.dispatchEvent(new CustomEvent('newbooking'));
    }
    /*handleNewClick() {
    this[NavigationMixin.Navigate]({
        type: "standard__navItemPage",
        attributes: {
            apiName: "Event_Hall_Booking"
        }
    });
}*/
}