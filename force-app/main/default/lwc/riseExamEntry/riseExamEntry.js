import { LightningElement, track, wire } from 'lwc';
import getApplicants from '@salesforce/apex/RISEExamController.getApplicants';
// import getApplicantsByExamDate from '@salesforce/apex/RISEExamController.getApplicantsByExamDate';getAcademicPrograms
import getDepartments  from '@salesforce/apex/RISEExamController.getDepartments';
import getAcademicPrograms from '@salesforce/apex/RISEExamController.getAcademicPrograms';
import saveApplicants from '@salesforce/apex/RISEExamController.saveApplicants';

const DEFAULT_PAGE_SIZE = 50;

export default class RiseExamEntry extends LightningElement {

    @track contacts = [];          // full dataset (all pages)
    @track searchKey      = '';
    // @track searchExamDate = '';
    @track isLoading      = false;
    @track toastMessage   = '';
    @track toastType      = '';
    @track isDirty        = false;

    // ── Pagination state ─────────────────────────────────────────
    @track currentPage = 1;
    @track pageSize    = DEFAULT_PAGE_SIZE;

    pageSizeOptions = [
        { label: '25',  value: 25  },
        { label: '50',  value: 50  },
        { label: '100', value: 100 }
    ];

    // ── Dirty / snapshot tracking ─────────────────────────────────
    _dirtyIds      = new Set();
    _serverSnapshot = [];

    resultOptions = [
        { label: '-- None --', value: '' },
        { label: 'Pass',       value: 'Pass' },
        { label: 'Fail',       value: 'Fail' },
        // { label: 'Absent',     value: 'Absent' },
        // { label: 'Withheld',   value: 'Withheld' }
    ];

    @track departments = [];
    @track academicPrograms = [];
    @track selectedAcademicProgram = '';
    @track selectedDepartment = '';   

    connectedCallback() {
        this.loadApplicants();
    }

    @wire(getDepartments)
    wiredDepartments({ error, data }) {
        if (data) {
            this.departments = data;
        } else if (error) {
            console.error('Error loading departments', error);
        }
    }

     handleDepartmentChange(event) {

        this.selectedDepartment = event.detail.value;

        // Reset academic program selection
        this.selectedAcademicProgram = null;
        this.academicPrograms = [];

        getAcademicPrograms({
            departmentId: this.selectedDepartment
        })
        .then(result => {
            this.academicPrograms = result;
            console.log('this.academicPrograms : '+this.academicPrograms);
        })
        .catch(error => {
            console.error(error);
        });

        console.log('Department Id = ', this.selectedDepartment);
    }

    handleAcademicProgramChange(event) {

        this.selectedAcademicProgram = event.detail.value;

        console.log(
            'Academic Program Id = ',
            this.selectedAcademicProgram
        );
    }

    // ── Data Loading ──────────────────────────────────────────────

    loadApplicants(searchKey,selectedDepartment,selectedAcademicProgram) {
        this.isLoading = true;
        this.clearToast();

        getApplicants({ searchKey: searchKey || '',selectedDepartmentKey: selectedDepartment || '', selectedAcademicProgramKey : selectedAcademicProgram || ''})
            .then(data  => { 
                this._applyServerData(data); 
                console.log('Result :: '+JSON.stringify(data));
            })
            .catch(error => { this.showToast('Error loading records: ' + this.extractError(error), 'error'); })
            .finally(()  => { this.isLoading = false; });
    }

    // loadByExamDate(examDate) {
    //     this.isLoading = true;
    //     this.clearToast();

    //     getApplicantsByExamDate({ examDate })
    //         .then(data  => { this._applyServerData(data); })
    //         .catch(error => { this.showToast('Error loading records: ' + this.extractError(error), 'error'); })
    //         .finally(()  => { this.isLoading = false; });
    // }

    _applyServerData(data) {
        const enriched = this._enrichContacts(data);
        this._serverSnapshot = JSON.parse(JSON.stringify(enriched));
        this.contacts    = enriched;
        this._dirtyIds   = new Set();
        this.isDirty     = false;
        this.currentPage = 1;        // always reset to page 1 on fresh data
    }

    _enrichContacts(data) {
        return data.map((c, idx) => ({
            ...c,
            rowIndex:             idx + 1,   // global 1-based index across all pages
            rowClass:             '',
            RISE_Actual_Score__c: c.RISE_Actual_Score__c ?? '',
            RISE_Result__c:       c.RISE_Result__c        ?? ''
        }));
    }

    // ── Pagination Computed Properties ────────────────────────────

    /** Total number of pages */
    get totalPages() {
        return Math.max(1, Math.ceil(this.contacts.length / this.pageSize));
    }

    /** Slice of contacts visible on the current page */
    get pagedContacts() {
        const start = (this.currentPage - 1) * this.pageSize;
        return this.contacts.slice(start, start + this.pageSize);
    }

    /** Page info string e.g. "Page 2 of 4" */
    get pageInfo() {
        return `Page ${this.currentPage} of ${this.totalPages}`;
    }

    /** Range info e.g. "Showing 51–100 of 183" */
    get rangeInfo() {
        const start = (this.currentPage - 1) * this.pageSize + 1;
        const end   = Math.min(this.currentPage * this.pageSize, this.contacts.length);
        return `Showing ${start}–${end} of ${this.contacts.length}`;
    }

    get isFirstPage() { return this.currentPage === 1; }
    get isLastPage()  { return this.currentPage === this.totalPages; }

    // ── Pagination Handlers ───────────────────────────────────────

    handleFirstPage()    { this.currentPage = 1; }
    handlePrevPage()     { if (!this.isFirstPage) this.currentPage--; }
    handleNextPage()     { if (!this.isLastPage)  this.currentPage++; }
    handleLastPage()     { this.currentPage = this.totalPages; }

    handlePageSizeChange(event) {
        this.pageSize    = parseInt(event.detail.value, 10);
        this.currentPage = 1;   // reset to page 1 when page size changes
    }

    // ── Search / Reset Handlers ───────────────────────────────────

    handleSearchKeyChange(event)  { this.searchKey      = event.target.value; }
    // handleExamDateChange(event)   { this.searchExamDate = event.target.value; }

    handleSearch() {
        // if (this.searchExamDate && !this.searchKey) {
        //     this.loadByExamDate(this.searchExamDate);
        // } else {
        //     this.loadApplicants(this.searchKey);
        // }
        if (this.searchKey || this.selectedDepartment || this.selectedAcademicProgram) {      
            console.log('Input Search Keys ->'+this.searchKey+' : '+this.selectedDepartment+' : '+this.selectedAcademicProgram);     
            this.loadApplicants(this.searchKey,this.selectedDepartment,this.selectedAcademicProgram);
        }
    }

    handleReset() {
        this.searchKey      = '';
        this.selectedDepartment = '';
        this.selectedAcademicProgram = '';
        // this.searchExamDate = '';
        this.clearToast();
        this.loadApplicants();
    }

    handleResetFields() {
        this.contacts = this.contacts.map(c => {
            const snap = this._serverSnapshot.find(s => s.Id === c.Id);
            return {
                ...c,
                RISE_Actual_Score__c: snap ? (snap.RISE_Actual_Score__c ?? '') : '',
                RISE_Result__c:       snap ? (snap.RISE_Result__c        ?? '') : '',
                rowClass: ''
            };
        });
        this._dirtyIds = new Set();
        this.isDirty   = false;
        this.clearToast();
    }

    // ── Score Key Blocker ─────────────────────────────────────────

    handleScoreKeyDown(event) {
        const allowed = ['Backspace','Delete','Tab','ArrowLeft','ArrowRight','ArrowUp','ArrowDown','Home','End'];
        const key = event.key;
        if (allowed.includes(key)) return;
        if (/^\d$/.test(key))      return;
        if (key === '.')            return;
        event.preventDefault();
    }

    // ── Field Change ──────────────────────────────────────────────

    handleFieldChange(event) {
        const contactId = event.target.dataset.id;
        const field     = event.target.dataset.field;
        let   value     = event.target.value;

        if (field === 'RISE_Actual_Score__c') {
            value = value.replace(/[^0-9.]/g, '');
            const parts = value.split('.');
            if (parts.length > 2) value = parts[0] + '.' + parts.slice(1).join('');
            const numeric = parseFloat(value);
            if (!isNaN(numeric) && numeric < 0) { event.target.value = ''; value = ''; }
            if (event.target.value !== value)    event.target.value = value;
        }

        // Update the full contacts array (not just the paged slice) so changes
        // on any page are preserved when the user navigates between pages.
        this.contacts = this.contacts.map(c => {
            if (c.Id === contactId) {
                return { ...c, [field]: value, rowClass: 'row-modified' };
            }
            return c;
        });

        this._dirtyIds.add(contactId);
        this.isDirty = true;
    }

    // ── Submit ────────────────────────────────────────────────────

    handleSubmit() {
        const toSave = this.contacts
            .filter(c => this._dirtyIds.has(c.Id))
            .map(c => ({
                Id:                   c.Id,
                RISE_Actual_Score__c: c.RISE_Actual_Score__c !== '' ? c.RISE_Actual_Score__c : null,
                RISE_Result__c:       c.RISE_Result__c || null
            }));

        if (toSave.length === 0) {
            this.showToast('No changes to save.', 'info');
            return;
        }

        this.isLoading = true;
        this.clearToast();

        saveApplicants({ contacts: toSave })
            .then(result => {
                if (result === 'SUCCESS') {
                    const savedCount = toSave.length;
                    const savedMap   = {};
                    toSave.forEach(s => { savedMap[s.Id] = s; });

                    // Immediately reflect saved values across ALL pages
                    this.contacts = this.contacts.map(c => {
                        if (savedMap[c.Id]) {
                            return {
                                ...c,
                                RISE_Actual_Score__c: savedMap[c.Id].RISE_Actual_Score__c ?? '',
                                RISE_Result__c:       savedMap[c.Id].RISE_Result__c        ?? '',
                                rowClass: ''
                            };
                        }
                        return c;
                    });

                    this._dirtyIds = new Set();
                    this.isDirty   = false;
                    this._serverSnapshot = JSON.parse(JSON.stringify(this.contacts));

                    this.showToast(
                        `${savedCount} record${savedCount !== 1 ? 's' : ''} saved successfully!`,
                        'success'
                    );

                    // Background sync to pick up any server-side trigger/formula changes
                    return getApplicants({ searchKey: this.searchKey || '' })
                        .then(freshData => { this._applyServerData(freshData); });
                }
            })
            .catch(error => {
                this.showToast('Save failed: ' + this.extractError(error), 'error');
            })
            .finally(() => { this.isLoading = false; });
    }

    // ── Computed Properties ───────────────────────────────────────

    get hasContacts()      { return this.contacts && this.contacts.length > 0; }
    get isSubmitDisabled() { return !this.isDirty || this.isLoading; }

    get recordCountLabel() {
        const count = this.contacts ? this.contacts.length : 0;
        return `${count} Applicant${count !== 1 ? 's' : ''} Found`;
    }

    get dirtyCountLabel() {
        return `${this._dirtyIds.size} unsaved change${this._dirtyIds.size !== 1 ? 's' : ''}`;
    }

    get toastClass() {
        const base = 'toast-alert slds-notify slds-notify_alert slds-m-bottom_small ';
        if (this.toastType === 'success') return base + 'toast-success';
        if (this.toastType === 'error')   return base + 'toast-error';
        return base + 'toast-info';
    }

    get toastIcon() {
        if (this.toastType === 'success') return 'utility:success';
        if (this.toastType === 'error')   return 'utility:error';
        return 'utility:info';
    }

    // ── Helpers ───────────────────────────────────────────────────

    showToast(message, type) {
        this.toastMessage = message;
        this.toastType    = type;
        if (type === 'success' || type === 'info') {
            setTimeout(() => { this.clearToast(); }, 4000);
        }
    }

    clearToast()  { this.toastMessage = ''; this.toastType = ''; }

    extractError(error) {
        if (error && error.body && error.body.message) return error.body.message;
        if (error && error.message)                     return error.message;
        return 'Unknown error';
    }

    get isProgramDisabled() {
        return !this.selectedDepartment;
    }
}