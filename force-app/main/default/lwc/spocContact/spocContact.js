import { LightningElement, track, wire } from 'lwc';
import getContacts from '@salesforce/apex/SpocContactController.getContacts';
import updateContact from '@salesforce/apex/SpocContactController.updateContact';
import searchUsers from '@salesforce/apex/SpocContactController.searchUsers';
import assignUsers from '@salesforce/apex/SpocContactController.assignUsers';
import isSpocUser from '@salesforce/apex/SpocContactController.isSpocUser';
import isSchoolHead from '@salesforce/apex/SpocContactController.isSchoolHead';

import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import SCHOOL_DISPOSITION_FIELD from '@salesforce/schema/Contact.School_Disposition__c';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import USER_ID from '@salesforce/user/Id';

export default class SpocContact extends LightningElement {

    userId = USER_ID;

    @track allContacts = [];
    @track filteredContacts = [];
    @track selectedContactIds = [];

    @track userOptions = [];
    @track selectedUserIds = [];
    @track selectedUserName = '';
    @track showDropdown = false;
    searchKey = '';

    @track selectedContact = {};
    @track showModal = false;

    @track recordTypeId;
    @track schoolDispositionOptions = [];

    isSpoc = false;
    wiredResult;
    sortedBy;
    sortedDirection = 'asc';
    isSchoolHeadUser = false;

    currentFilter = 'ALL';
    statusFilter = 'ALL';
    @track programOptions = [];
    selectedProgram = 'ALL';

    columns = [
        {
            label: 'Name',
            fieldName: 'Name',
            type: 'button',
            sortable: true, 
            typeAttributes: {
                label: { fieldName: 'Name' },
                name: 'view',
                variant: 'base',
                class: 'name-link'
            },
            cellAttributes: {
                alignment: 'left',
                class: 'truncate-cell'
            },
            wrapText: false 
        },
        { label: 'Mobile', fieldName: 'MobilePhone', sortable: true  },
        { label: 'Email', fieldName: 'Email', sortable: true  },
        { label: 'Counselor', fieldName: 'OwnerName', sortable: true  },
        { label: 'Disposition', fieldName: 'Disposition__c', sortable: true  },
        { label: 'State', fieldName: 'State__c', sortable: true  },
        { label: 'RISE', fieldName: 'Applying_For_REVA_CET__c', sortable: true  },
        { label: 'Acad Disp', fieldName: 'displayDisposition', sortable: true  },
        { label: 'Acad Remarks', fieldName: 'School_Description__c', sortable: true  },
        { label: 'Assigned To', fieldName: 'AssignedUserName', sortable: true  },
        { label: 'Application Status', fieldName: 'hed__Application_Status__c', sortable: true  },
        { label: 'Application Fee', fieldName: 'Application_Fee_Paid__c', sortable: true  }
    ];

    @wire(isSpocUser)
    wiredSpoc({ data }) {
        this.isSpoc = data;
    }
    @wire(isSchoolHead)
    wiredHead({ data }) {
        if (data !== undefined) {
            this.isSchoolHeadUser = data;
        }
    }

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$recordTypeId',
        fieldApiName: SCHOOL_DISPOSITION_FIELD
    })
    picklistHandler({ data, error }) {
        if (data) {
            this.schoolDispositionOptions = data.values;
        }
    }

    @wire(getContacts)
wiredData(result) {
    this.wiredResult = result;

    if (result.data) {

        // 🔥 FIX: map hed__Applicant__r fields
        this.allContacts = result.data.map(row => {
            const c = row.hed__Applicant__r || {};

            return {
                Id: row.hed__Applicant__c, 
                Name: c.Name,
                School_Name__c: c.School_Name__c,
                MobilePhone: c.MobilePhone,
                Email: c.Email,
                OwnerName: c.Owner ? c.Owner.Name : '',
                Assigned_User__c: c.Assigned_User__c,
                AssignedUserName: c.Assigned_User__r ? c.Assigned_User__r.Name : '',
                Disposition__c: c.Disposition__c,
                Description1__c: c.Description1__c,
                School_Disposition__c: c.School_Disposition__c,
                School_Description__c: c.School_Description__c,
                displayDisposition: c.School_Disposition__c || 'Pending',
                State__c: c.state__c,
                Applying_For_REVA_CET__c: c.Applying_For_REVA_CET__c,
                Primary_Academic_Program_Name__c: c.Primary_Academic_Program_Name__c,
                hed__Application_Status__c: row.hed__Application_Status__c,
                Application_Fee_Paid__c: c.Application_Fee_Paid__c
            };
        });

        // 🔥 PROGRAM FILTER (correct field now)
        const programSet = new Set();

        this.allContacts.forEach(rec => {
            if (rec.Primary_Academic_Program_Name__c) {
                programSet.add(rec.Primary_Academic_Program_Name__c);
            }
        });

        this.programOptions = [
            { label: 'All Programs', value: 'ALL' },
            ...[...programSet].sort().map(p => ({
                label: p,
                value: p
            }))
        ];

        this.applyFilter();
    }

    if (result.error) {
        console.error('Error fetching contacts:', result.error);
    }
}
    handleProgramChange(event) {
    this.selectedProgram = event.detail.value;
    this.applyFilter();
}

    applyFilter() {
        let data = [...this.allContacts];

        if (this.currentFilter === 'ASSIGNED') {
            data = data.filter(c => c.Assigned_User__c);
        } 
        else if (this.currentFilter === 'UNASSIGNED') {
            data = data.filter(c => !c.Assigned_User__c);
        }
        else if (this.currentFilter === 'SCHOOL_ALL') {
        data = [...this.allContacts]; 
    }

        if (this.statusFilter === 'PENDING') {
            data = data.filter(c => !c.School_Disposition__c);
        } 
        else if (this.statusFilter === 'COMPLETED') {
            data = data.filter(c => c.School_Disposition__c);
        }
        if (this.selectedProgram !== 'ALL') {
        data = data.filter(
            c => c.Primary_Academic_Program_Name__c === this.selectedProgram
        );
    }

        this.filteredContacts = data;
    }

    showAll() {
        this.currentFilter = 'ALL';
        this.statusFilter = 'ALL';
        this.applyFilter();
    }
    showSchoolAll() {
    this.currentFilter = 'SCHOOL_ALL';
    this.statusFilter = 'ALL'; 
    this.applyFilter();
    }

    showAssigned() {
        this.currentFilter = 'ASSIGNED';
        this.statusFilter = 'ALL';
        this.applyFilter();
    }

    showUnassigned() {
        this.currentFilter = 'UNASSIGNED';
        this.statusFilter = 'ALL';
        this.applyFilter();
    }

    showPending() {
        this.statusFilter = 'PENDING';
        this.currentFilter = 'ALL';
        this.applyFilter();
    }

    showCompleted() {
        this.statusFilter = 'COMPLETED';
        this.currentFilter = 'ALL';
        this.applyFilter();
    }

    get pendingCount() {
        return this.allContacts.filter(c => !c.School_Disposition__c).length;
    }

    get completedCount() {
        return this.allContacts.filter(c => c.School_Disposition__c).length;
    }

    get selectedCount() {
        return this.selectedContactIds.length;
    }

    handleRowSelection(event) {
        this.selectedContactIds = event.detail.selectedRows.map(r => r.Id);
    }

    handleUserSearch(event) {
        this.searchKey = event.target.value;

        if (this.searchKey.length > 1) {
            searchUsers({ searchKey: this.searchKey })
                .then(res => {
                    this.userOptions = res;
                    this.showDropdown = true;
                });
        }
    }
   
handleSort(event) {
    this.sortedBy = event.detail.fieldName;
    this.sortedDirection = event.detail.sortDirection;

    let data = [...this.filteredContacts];

    data.sort((a, b) => {
    let valA = a[this.sortedBy] || '';
    let valB = b[this.sortedBy] || '';

    if (!isNaN(valA) && !isNaN(valB)) {
        return this.sortedDirection === 'asc'
            ? valA - valB
            : valB - valA;
    }

    return this.sortedDirection === 'asc'
        ? valA.toString().localeCompare(valB.toString())
        : valB.toString().localeCompare(valA.toString());
});

    this.filteredContacts = data;
}

    selectUser(event) {
        this.selectedUserIds = [event.currentTarget.dataset.id];
        this.selectedUserName = event.currentTarget.dataset.name;
        this.showDropdown = false;
    }

    removeUser() {
        this.selectedUserIds = [];
        this.selectedUserName = '';
    }

    handleAssign() {
        if (!this.selectedContactIds.length || !this.selectedUserIds.length) {
            this.showToast('Error','Select records & user','error');
            return;
        }

        assignUsers({
            contactIds: this.selectedContactIds,
            userIds: this.selectedUserIds
        }).then(() => {
            this.showToast('Success','Assigned successfully','success');

            this.selectedContactIds = [];
            this.selectedUserIds = [];
            this.selectedUserName = '';
            this.searchKey = '';

            return refreshApex(this.wiredResult).then(() => {
                this.applyFilter();
            });
        });
    }

    handleRowAction(event) {
        this.selectedContact = { ...event.detail.row };

        this.recordTypeId = this.selectedContact.RecordTypeId 
            || this.objectInfo.data.defaultRecordTypeId;

        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

    handleChange(event) {
        const field = event.target.dataset.field;
        this.selectedContact[field] = event.detail.value || event.target.value;
    }

    handleSave() {

    const schoolDisposition = this.selectedContact.School_Disposition__c;
    const schoolDesc = this.selectedContact.School_Description__c;

    // 🔴 STRICT VALIDATION
    if (!schoolDisposition || !schoolDesc || schoolDesc.trim() === '') {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Please fill School Disposition and School Description',
                variant: 'error'
            })
        );
        return;
    }

    // 🔵 OPTIONAL: UI validation (kept)
    const allValid = [...this.template.querySelectorAll(
        'lightning-combobox, lightning-textarea'
    )].reduce((validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
    }, true);

    if (!allValid) return;

    // 🔥 SAVE
    updateContact({ con: this.selectedContact })
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Contact updated successfully',
                    variant: 'success'
                })
            );

            this.showModal = false;
            return refreshApex(this.wiredResult);
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
}

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}