import { LightningElement, wire, api, track } from "lwc";
import getApprovalHistory from "@salesforce/apex/RevaHosteLeaveRequestController.getApprovalHistory";
import { CurrentPageReference } from 'lightning/navigation';
export default class RevaHostelLeaveReqApprovalHistory extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api approvalHistories = [];
    @track isVactionData = false;

    /*vacating Approval Histroy functionlity  : Jadala Devender*/ 
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && !this.recordId) {
            this.recordId = currentPageReference.state.recordId;
            console.log('this.recordId--->'+this.recordId);
            this.isVactionData = true ;
        }
    }
    @wire(getApprovalHistory, { targetObjectId: "$recordId" })
wiredApprovalHistory({ data, error }) {
    try {
        if (data) {
            console.log('data--->' + data);
            let sNo = 0;
            console.log(JSON.stringify(data));

            this.approvalHistories = data.map((approval) => {
                sNo++;
                return {
                    ...approval,
                    sNo, 
                    createdDate: approval.createdDate,
                    status: approval.status, 
                    actorName: approval.actorName, 
                    comments: approval.comments 
                };
            });
        } else if (error) {
            console.error("Error when fetching approval histories", error);
        }
    } catch (err) {
        console.error("An unexpected error occurred:", err);
    }
}

    /*vacating Approval Histroy functionlity , this method is used for redirect back to Home page : Jadala Devender*/ 
    handleBackVactingHistory() {
        window.history.back();
    }
}