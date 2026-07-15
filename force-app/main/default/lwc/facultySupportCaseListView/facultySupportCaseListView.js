import { LightningElement, wire, track } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { CurrentPageReference } from "lightning/navigation";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import CONTACT_ID_FIELD from "@salesforce/schema/User.ContactId";
import getFacultySupportCases from "@salesforce/apex/CaseListViewController.getFacultySupportCases";
import getFacultyRecordTypeId from "@salesforce/apex/CaseListViewController.getFacultyRecordTypeId";
import USER_ID from "@salesforce/user/Id";
import { refreshApex } from "@salesforce/apex";

export default class FacultySupportCaseListView extends NavigationMixin(LightningElement) {
    @track showOldCaseNumber = false;
    isSpinner = false;
    contactId = null;
    recordTypeName = "Faculty Support Ticket";
    openModalForUpdateCase = false;
    openModalForCreateCase = false;
    wiredContact;
    wiredCase;
    wireKey = 1;
    isInputDisabled = false;
    @track selectedCaseRecord = {};
    @track cases = [];  
    facultyRecordTypeId = null;

    constructor() {
        super();
        console.log("Constructor called");
    }

    connectedCallback() {
        console.log("Component initialized, facultyRecordTypeId:", this.facultyRecordTypeId);
    }

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [CONTACT_ID_FIELD]
    })
    userec(result) {
        this.wiredContact = result;
        console.log("getRecord result:", JSON.stringify(result));
        if (result.error) {
            console.error("Error fetching user record:", result.error);
            this.showToast("Error", "Failed to fetch user data", "error");
        } else if (result.data) {
            this.contactId = result.data.fields[CONTACT_ID_FIELD.fieldApiName].value;
        }
    }
    @wire(getFacultyRecordTypeId)
    wiredRecordTypeId({ error, data }) {
        console.log("getFacultyRecordTypeId called, data:", data, "error:", error);
        if (data) {
            this.facultyRecordTypeId = data;
            console.log("Faculty RecordTypeId set:", this.facultyRecordTypeId);
        } else if (error) {
            console.error("Error fetching Faculty RecordTypeId:", JSON.stringify(error));
            this.showToast("Error", "Failed to fetch Faculty Support Ticket record type", "error");
        }
    }
    @wire(getFacultySupportCases, {
        contactId: "$contactId",
        recordTypeName: "$recordTypeName",
        userId: USER_ID,
        wireKey: "$wireKey"
    })
    wiredCases(result) {
        this.wiredCase = result;
        console.log("getFacultySupportCases result:", JSON.stringify(result));
        if (result.data) {
            this.cases = result.data;
        } else if (result.error) {
            console.error("Error fetching cases:", result.error);
            this.showToast("Error", "Failed to load cases", "error");
        }
    }

    @wire(CurrentPageReference)
    pageRef;

    createCase() {
        console.log("createCase called, facultyRecordTypeId:", this.facultyRecordTypeId);
        if (!this.facultyRecordTypeId) {
            this.showToast("Error", "Faculty Support Ticket record type not configured", "error");
            console.error("No RecordTypeId set");
            return;
        }
        this.openModalForCreateCase = true;
    }

    get recordId() {
        console.log("Getting recordId:", this.selectedCaseRecord.Id);
        return this.selectedCaseRecord.Id || "-";
    }

    handleError(error) {
        this.isSpinner = false;
        console.error("Error updating case:", error.body?.message || error);
        this.showToast("Error", "Failed to update case: " + (error.body?.message || "Unknown error"), "error");
    }

    handleCreateError(error) {
        this.isSpinner = false;
        console.error("Error creating case:", error.body?.message || error);
        this.showToast("Error", "Failed to create case: " + (error.body?.message || "Unknown error"), "error");
    }

    handleSave() {
        this.isSpinner = true;
        console.log("handleSave called");
        const inputFields = this.template.querySelectorAll(".create-input");
        const isAllValuesFilled = Array.from(inputFields).every(element => element.value);
        if (!isAllValuesFilled) {
            this.showToast("Please fill all required fields", "", "info");
            this.isSpinner = false;
            console.log("Required fields missing");
            return;
        }
        if (this.refs.caseStatus && this.refs.caseStatus.value == " ") {
            this.showToast("Case Status must be 'New' when creating a case", "", "info");
            this.isSpinner = false;
            console.log("Case Status not New");
            return;
        }
        console.log("Submitting form");
        this.refs.save.click();
    }

    handleCreateSuccess(event) {
        this.isSpinner = false;
        console.log("Case created, ID:", event.detail.id);
        refreshApex(this.wiredCase);
        this.openModalForCreateCase = false;
        this.showToast("Faculty Case Created Successfully", "", "success");
    }

    handleSuccess() {
        this.isSpinner = false;
        console.log("Case updated");
        refreshApex(this.wiredCase);
        this.showToast("Updated Successfully", "", "success");
    }

    showToast(title, message, variant) {
        console.log(`Toast: ${title}, ${message}, ${variant}`);
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }

    handlePageRef(pageRef) {
        console.log("handlePageRef, pageName:", pageRef?.attributes?.name);
        const pageName = pageRef?.attributes?.name;
        if (pageName?.includes("Faculty")) {
            this.recordTypeName = "Faculty Support Ticket";
        }
    }

    handleModalClose() {
        this.openModalForUpdateCase = false;
        this.openModalForCreateCase = false;
        console.log("Modal closed");
    }

    showCaseDetail(event) {
        console.log("showCaseDetail, ID:", event.target.dataset.id);
        const selectedCase = this.cases.find(eachCase => eachCase.Id === event.target.dataset.id);
        if (selectedCase) {
            this.isInputDisabled = selectedCase.Status === "Closed" || selectedCase.Status === "New";
            this.selectedCaseRecord = selectedCase;
            this.openModalForUpdateCase = true;
        }
    }
    handleCaseStatusChange(event) {
        const selectedValue = event.target.value;
        this.showOldCaseNumber = selectedValue === 'Reopened';
    }

    renderedCallback() {
        console.log("Template rendered, cases:", this.cases.length);
    }
}