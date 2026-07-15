import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class GuestHouseAllignment extends NavigationMixin(LightningElement) {
    @api recordId; // Get recordId dynamically
    @track isFlowLoaded = false; // To control when to display the flow
    @track isFlowFinished = false; // To control when to show a completion message

    flowApiName = "Guest_House_Screen_Flow"; // API name of your flow

    connectedCallback() {
        console.log('Connected Callback: Record ID is', this.recordId);
        // Adding a delay to see if the recordId gets populated later
        setTimeout(() => {
            if (this.recordId) {
                console.log('Record ID is now available after delay:', this.recordId);
                this.isFlowLoaded = true;
            } else {
                console.error('Record ID is still undefined after delay.');
                this.showToast(
                    "Error",
                    "Record ID is not available after delay. Please ensure this component is placed on a record page.",
                    "error"
                );
            }
        }, 1500); // Wait for 3 seconds before checking again
    }

    // Set flow input variables using the dynamic recordId
    get flowInputVariables() {
        return [
            {
                name: "recordId",
                type: "String",
                value: this.recordId || '',
            },
        ];
    }

    // Show a toast message
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            })
        );
    }

    // Handle flow status changes
    handleFlowStatusChange(event) {
        console.log("Flow status:", event.detail.status);
        if (event.detail.status === "FINISHED") {
            this.showToast("Success", "Room Allotted Successfully", "success");
            this.isFlowLoaded = false; // Hide the flow once it's finished
            this.isFlowFinished = true; // Show a completion message
            location.reload();
        }
    }

}