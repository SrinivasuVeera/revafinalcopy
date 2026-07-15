import { LightningElement,api } from "lwc";

export default class RevaHostelLeaveRequest extends LightningElement {
    showApprovalHistory= false;
    showAttachments= false;
    showDetails = true;

    @api recordId; 

    connectedCallback() {
        // Log or process the leaveRequestId
        console.log('Leave Request ID:', this.recordId);
    }
    handleBackClick(){
        this.dispatchEvent(new CustomEvent('clickback'));
    }
    updateStyles(stepNumber) {
        const tabs = this.template.querySelectorAll(".tab");
        tabs.forEach((tab) => {
            const tabStepNumber = tab.dataset.step;
            if (tabStepNumber != stepNumber) {
                tab.style.backgroundColor = "#FEF3EA";
                tab.style.color = "black";
            } else {
                tab.style.color = "white";
                tab.style.backgroundColor = "#F07F07";
            }
        });
    }

    handleStepClick(event) {
        const stepNumber = event.target.dataset.step;
        if (stepNumber == 1) {
            this.showApprovalHistory = false;
            this.showAttachments = false;
            this.showDetails = true;
            this.updateStyles(stepNumber);
        } else if (stepNumber == 2) {
            this.showApprovalHistory = false;
            this.showAttachments = true;
            this.showDetails = false;
            this.updateStyles(stepNumber);
        } else if (stepNumber == 3) {
            this.showApprovalHistory = true;
            this.showAttachments = false;
            this.showDetails = false;
            this.updateStyles(stepNumber);
        }
    }

    handleClickBack() {}
}