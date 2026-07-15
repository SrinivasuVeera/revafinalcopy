import { LightningElement, wire, track } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { CurrentPageReference } from "lightning/navigation";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import CONTACT_ID_FIELD from "@salesforce/schema/User.ContactId";
import getCases from "@salesforce/apex/CaseListViewController.getCases";
import USER_ID from "@salesforce/user/Id";
import { refreshApex } from "@salesforce/apex";

export default class CaseListView extends NavigationMixin(LightningElement) {
    isSpinner;
    contactId;
    recordTypeName = "Infra Support Request";
    openModalForUpdateCase;
    openModalForCreateCase;
    wiredContact;
    wiredCase;
    wireKey = 1;
    isInputDisabled;
    @track selectedCaseRecord = {};
    @track cases = [];

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [CONTACT_ID_FIELD]
    })
    userec(result) {
        this.wiredContact = result;
        if (result.error) {
            console.error("Error", result.error);
            this.isSpinner = false;
        } else if (result.data) {
            this.contactId = result.data.fields[CONTACT_ID_FIELD.fieldApiName].value;
        }
    }

    @wire(getCases, {
        contactId: "$contactId",
        recordTypeName: "$recordTypeName",
        userId: USER_ID,
        wireKey: "$wireKey"
    })
    wiredCases(result) {
        this.wiredCase = result;
        if (result.data) {
            this.cases = result.data;
        }
        else if (result.error) {
            this.isSpinner = false;
            console.error("Error when fetching cases " + error);
        }
    }

    @wire(CurrentPageReference)
    pageRef;

    createCase() {
        this.openModalForCreateCase = true;
    }

    get recordId() {
        console.log('Record Id ' + JSON.stringify(this.selectedCaseRecord.Id)  )
        return this.selectedCaseRecord.Id ?? "-";
    }

    handleError(error) {
        this.isSpinner = false;
        console.error("Error when updating case  " +error.body.message);
        this.showToast("Error when updating case");
    }
    handleSave() {
        this.isSpinner = true;
        const inputFields = this.template.querySelectorAll('.create-input');
        console.log('inputFields',inputFields);
        const isAllValuesFilled = Object.values(inputFields).every(element => {
            return element.value
        });
        if (!isAllValuesFilled) {
            this.showToast(`Please fill all the fields`, "", "info");
            this.isSpinner = false;
            return
        }
        if (this.refs.status.value !== 'New') {
            this.isSpinner = false;
            this.showToast(`Status should be New when creating a case`, "", "info");
            return;
        }
        this.refs.save.click();
      
    }
    handleCreateSuccess() {
        this.isSpinner = false;
        refreshApex(this.wiredCase);
        this.openModalForCreateCase = false;
        this.showToast("Infra Case Created Successfully", "", "success");
    }
    handleSuccess() {
        this.isSpinner = false;
        refreshApex(this.wiredCase);
        this.showToast("Updated Successfully", "", "success");
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    connectedCallback() {
        // this.handlePageRef(this.pageRef);
    }

    handlePageRef(pageRef) {
        const pageName = pageRef.attributes.name;
        if (pageName.contains("Infra")) {
            this.recordTypeName = "Infra Support Request";
        }
        this.recordTypeName = "Infra Support Request";
    }

    handleModalClose() {
        this.openModalForUpdateCase = false;
        this.openModalForCreateCase = false;
    }

    showCaseDetail(event) {
        let selectedCase = this.cases.find((eachCase) => eachCase.Id == event.target.dataset.id);
        this.isInputDisabled = selectedCase.Status === 'Closed';
        if (selectedCase) {
            this.selectedCaseRecord = selectedCase;
            this.openModalForUpdateCase = true;
        }
        
    }
}