import { LightningElement, wire, api, track } from 'lwc';
import getApprovalHistory from '@salesforce/apex/RevaHosteLeaveRequestController.getApprovalHistory';
import { CurrentPageReference } from 'lightning/navigation';

export default class ApprovalHistoryTable extends LightningElement {
    @api recordId; // To store the record ID passed from the parent component
    @track approvalHistories = []; // To store fetched approval histories
    @track isVactionData = false; // To manage the vacation data state

    /* Fetch the current page reference to get the record ID */
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && !this.recordId) {
            this.recordId = currentPageReference.state.recordId;
            this.isVactionData = true; // Set to true if we have a record ID
        }
    }

    /* Fetch the approval history based on the record ID */
    @wire(getApprovalHistory, { targetObjectId: '$recordId' })
    wiredApprovalHistory({ data, error }) {
        if (data) {
            console.log('data------'+data);
            
            let sNo = 0; // Initialize serial number
            this.approvalHistories = data.map((approval) => {
                sNo++;
                return {
                    ...approval,
                    sNo // Add serial number to each approval history entry
                };
            });
        } else if (error) {
            console.error('Error when fetching approval histories: ', error);
            this.approvalHistories = []; // Clear histories if there's an error
        }
    }

    /* Method to handle back button functionality */
    handleBackVactingHistory() {
        window.history.back(); // Navigate back in the history
    }
}