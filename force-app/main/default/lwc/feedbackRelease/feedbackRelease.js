import { LightningElement, wire, track } from 'lwc';
import getAccountIdBasedOnSchoolName from '@salesforce/apex/FeedbackManagementController.getAccountIdBasedOnSchoolName';
import getAccountBasedOnParentIdList from '@salesforce/apex/FeedbackManagementController.getAccountBasedOnParentIdList';
import getProgramBatchList from '@salesforce/apex/FeedbackManagementController.getProgramBatchList';
import getSemesterList from '@salesforce/apex/FeedbackManagementController.getSemesterList';
import getQuestionsByType from '@salesforce/apex/FeedbackManagementController.getQuestionsByType';

import getAllFeedbackReleases from '@salesforce/apex/FeedbackManagementController.getAllFeedbackReleases';
import insertFeedbackRelease from '@salesforce/apex/FeedbackManagementController.insertFeedbackRelease';
import updateFeedbackRelease from '@salesforce/apex/FeedbackManagementController.updateFeedbackRelease';
import deleteFeedbackRelease from '@salesforce/apex/FeedbackManagementController.deleteFeedbackRelease';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex'; 

export default class FeedbackRelease extends LightningElement {
    @track programOptions = [];
    @track programBatchOptions = [];
    @track semesterOptions = [];
    @track displayProgrmaDetails = true;
    @track errorMessage = '';
    progName;
    progBatchName; 
    progSemName;
    readOnlyFlag = false;

    selectedProgram = '';
    selectedProgramName = '';
    selectedProgramBatch = '';
    selectedProgramBatchName = '';
    selectedSemester = '';
    selectedSemesterName = ''; 
    feedbackType;
    selectedTemplateRecId;
    templateTypeDefaultValue;
    minAttendance;
    message = '';   
    @track isModalOpen = false;
    recordIdToDelete;

    @track templateOptions = [];
    @track selectedTemplate = '';
    @track allQuestions = [];
    @track questionsForSelectedTemplate = [];
    // selectedTemplateRecId;
    
    @track fromDate;
    @track toDate;
    @track isChecked = false;
    // @track feedbackReleases;
    @track error;
    showSetUpModal = false;
    modelHeader = '';
    isUpdate;
    recordId;
    disableForEdit = false;
    isSpinner;
    @track wiredData;
     // *********** Feedback Release **************
        @track feedbackList1;
        @track draftValues = [];
        @track showModal = false;
        newFeedback = {};
     // ********************************************
    latestReleases = [];
    historyReleases = [];
    activeTab = 'latest'; // 'latest' | 'history'

    connectedCallback() {
        this.loadPrograms();
    }       

    get feedbackReleases() {
        return this.activeTab === 'latest' ? this.latestReleases : this.historyReleases;
    }

    handleTabChange(event) {
        this.activeTab = event.target.dataset.tab;
    }

    // In your wiredReleases wire handler, replace the assignment line with:
    @wire(getAllFeedbackReleases)
    wiredReleases(result) {
        this.wiredData = result;
        if (result.data) {
            const today = new Date();
            today.setHours(0, 0, 0, 0);

            const mapped = result.data.map(item => ({
                ...item,
                FeedbackTemplateName: item.Template_Id__c || '',
                formattedStartDate: this.formatDate(item.Start_Date__c),
                formattedEndDate: this.formatDate(item.End_Date__c),
                _endDate: item.End_Date__c ? new Date(item.End_Date__c) : null
            }));

            this.latestReleases = mapped.filter(r => r._endDate && r._endDate >= today);
            this.historyReleases = mapped.filter(r => r._endDate && r._endDate < today);
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.latestReleases = [];
            this.historyReleases = [];
        }
    }

    formatDate(dateString) {
        if (!dateString) return '';
        const options = { day: '2-digit', month: 'short', year: 'numeric' };
        return new Intl.DateTimeFormat('en-GB', options).format(new Date(dateString));
    }

    get latestTabClass() {
        return `slds-tabs_default__link${this.activeTab === 'latest' ? ' slds-is-active' : ''}`;
    }

    get historyTabClass() {
        return `slds-tabs_default__link${this.activeTab === 'history' ? ' slds-is-active' : ''}`;
    }

    handleEditClick(event) {
        this.showSetUpModal = true;
        this.modelHeader = 'Update Feedback Release';
        this.isUpdate = true;
        this.readOnlyFlag = true;
        this.recordId = event.currentTarget.dataset.id;
        const selectedRecord = this.feedbackReleases.find(record => record.Id === this.recordId);
        console.log('Selected Record for Edit:', JSON.stringify(selectedRecord, null, 2));
        console.log('selectedRecord Id: '+this.recordId);
            this.templateTypeDefaultValue = selectedRecord.Template_Type__c;
            this.selectedTemplate = '';
            this.feedbackType = selectedRecord.Template_Type__c;
            // this.selectedTemplate = selectedRecord.FeedbackTemplate__r.Name;  
            this.selectedTemplate = selectedRecord.Template_Id__c;  
           
            
              
           
            
            // this.selectedProgram = selectedRecord.Program_Id__c;
            // this.selectedProgramBatch = selectedRecord.Program_Batch_Name__c;            
             this.selectedSemester = selectedRecord.Semester_Name__c;
            // this.templateTypeDefaultValue = selectedRecord.Template_Type__c;
            // this.selectedTemplate = selectedRecord.FeedbackTemplate__r.Name;   
            this.fromDate=selectedRecord.Start_Date__c;
            this.toDate=selectedRecord.End_Date__c;
            this.isChecked = selectedRecord.Active__c;
            this.minAttendance = selectedRecord.Minimum_attendance__c;
            this.displayProgrmaDetails = false;
            this.progName = selectedRecord.Program_Name__c;
            this.progBatchName = selectedRecord.Program_Batch_Name__c;
            this.progSemName = selectedRecord.Semester_Name__c;
            this.loadQuestions().then(() => {
                this.filterQuestions();
            });
    }

    // handleNewSetupClick(){
    //     this.errorMessage = '';
    //     this.showSetUpModal = true;
    //     this.displayProgrmaDetails = true;
    //     this.modelHeader = 'Setup New Feedback Release';
    //     this.isUpdate = false;
    //     this.readOnlyFlag = false;
    // }

    handleNewSetupClick(){
        this.errorMessage = '';
        this.showSetUpModal = true;
        this.displayProgrmaDetails = true;
        this.modelHeader = 'Setup New Feedback Release';
        this.isUpdate = false;
        this.readOnlyFlag = false;

        // Reset all fields that handleEditClick populates
        this.recordId = null;
        this.templateTypeDefaultValue = '';
        this.feedbackType = '';
        this.selectedTemplate = '';
        this.selectedTemplateRecId = '';
        this.selectedProgram = '';
        this.selectedProgramBatch = '';
        this.selectedProgramBatchName = '';
        this.selectedSemester = '';
        this.selectedSemesterName = '';
        this.fromDate = '';
        this.toDate = '';
        this.isChecked = false;
        this.minAttendance = undefined;
        this.progName = '';
        this.progBatchName = '';
        this.progSemName = '';

        // Reset dependent dropdowns
        this.programBatchOptions = [];
        this.semesterOptions = [];

        // Reset questions
        this.allQuestions = [];
        this.templateOptions = [];
        this.questionsForSelectedTemplate = [];
    }

    handleDeleteClick(event){
        this.recordId = event.currentTarget.dataset.id;
        console.log('selectedRecord Id for delete: '+this.recordId);
    }

    get isUpdateAction(){
        return this.isUpdate ? true : false;
    }

    handleSetupCancel(){
        this.showSetUpModal = false;
        this.templateTypeDefaultValue = '';
            this.selectedTemplate = '';
            this.feedbackType = '';
          //  this.selectedTemplate = selectedRecord.FeedbackTemplate__r.Name;  
            
            this.programBatchOptions = [];
            this.semesterOptions = [];
            this.selectedProgram = '';
            this.selectedProgramBatch = '';
            this.selectedSemester = '';
            // this.templateTypeDefaultValue = selectedRecord.Template_Type__c;
            // this.selectedTemplate = selectedRecord.FeedbackTemplate__r.Name;   
            this.fromDate = '';
            this.toDate = '';
            this.isChecked = false;

            // this.displayProgrmaDetails = false;

            // this.progName = selectedRecord.Program_Name__c;
            // this.progBatchName = selectedRecord.Program_Batch_Name__c;
            // this.progSemName = selectedRecord.Semester_Name__c;
    }

    loadPrograms() {
        this.errorMessage = '';
        getAccountIdBasedOnSchoolName()
            .then((result) => {
                if (result && result.length > 0) {
                    const firstSchool = result[0];
                    const schoolId = firstSchool.split('##')[0];
                    return getAccountBasedOnParentIdList({ parentId: schoolId });
                }
                this.programOptions = [];
                return [];
            })
            .then((programs) => {
                if (programs && programs.length > 0) {
                    this.programOptions = programs.map(item => {
                        const [id, name] = item.split('##');
                        return { label: name, value: id };
                    });
                } else {
                    this.programOptions = [];
                }
                this.programBatchOptions = [];
                this.semesterOptions = [];
                this.selectedProgram = '';
                this.selectedProgramBatch = '';
                this.selectedSemester = '';
            })
            .catch(error => {
                this.errorMessage = this._getErrorMessage(error);
                this.programOptions = [];
                this.programBatchOptions = [];
                this.semesterOptions = [];
            });
    }

    handleProgramChange(event) {
        this.errorMessage = '';
        this.selectedProgram = event.detail.value;
        this.selectedProgramName = this.getLabelByValue(this.programOptions, this.selectedProgram);
        console.log(`Selected Program: ID = ${this.selectedProgram}, Name = ${this.selectedProgramName}`);

        getProgramBatchList({ programId: this.selectedProgram })
            .then((batches) => {
                if (batches && batches.length > 0) {
                    this.programBatchOptions = batches.map(item => {
                        const [id, name] = item.split('##');
                        return { label: name, value: id };
                    });
                } else {
                    this.programBatchOptions = [];
                }
                this.semesterOptions = [];
                this.selectedProgramBatch = '';
                this.selectedSemester = '';
            })
            .catch(error => {
                this.errorMessage = this._getErrorMessage(error);
                this.programBatchOptions = [];
                this.semesterOptions = [];
            });
    }

    handleProgramBatchChange(event) {
        this.errorMessage = '';
        this.selectedProgramBatch = event.detail.value;
        this.selectedProgramBatchName = this.getLabelByValue(this.programBatchOptions, this.selectedProgramBatch);
        console.log(`Selected Program Batch: ID = ${this.selectedProgramBatch}, Name = ${this.selectedProgramBatchName}`);

        getSemesterList({ programBId: this.selectedProgramBatch })
            .then((semesters) => {
                if (semesters && semesters.length > 0) {
                    this.semesterOptions = semesters.map(item => {
                        const [id, name] = item.split('##');
                        return { label: name, value: id };
                    });
                } else {
                    this.semesterOptions = [];
                }
                this.selectedSemester = '';
            })
            .catch(error => {
                this.errorMessage = this._getErrorMessage(error);
                this.semesterOptions = [];
            });
    }

    handleSemesterChange(event) {
        this.errorMessage = '';
        this.selectedSemester = event.detail.value;
        this.selectedSemesterName = this.getLabelByValue(this.semesterOptions, this.selectedSemester);
        console.log(`Selected Semester: ID = ${this.selectedSemester}, Name = ${this.selectedSemesterName}`);
    }

    // Helper to get label by value
    getLabelByValue(options, selectedValue) {
        const match = options.find(opt => opt.value === selectedValue);
        return match ? match.label : '';
    }

    // Helper to extract Apex error message
    _getErrorMessage(error) {
        if (Array.isArray(error.body)) {
            return error.body.map(e => e.message).join(', ');
        } else if (error.body && error.body.message) {
            return error.body.message;
        } else if (error.message) {
            return error.message;
        }
        return 'Unknown error';
    }

    get options() {
        return [
            { label: 'Course', value: 'Course' },
            { label: 'Faculty', value: 'Faculty' },
            { label: 'Others', value: 'Others' },
        ];
    }

    handleTemplateTypeChange(event) {
        this.errorMessage = '';
        console.log('handleTemplateTypeChange() executed !!');
        this.templateTypeDefaultValue = event.detail.value;
        this.feedbackType = this.templateTypeDefaultValue;
        console.log('this.feedbackType : '+this.feedbackType);        
        this.loadQuestions();
    }

    loadQuestions() {
        console.log('loadQuestions() executed !!');
        console.log('this.feedbackType : '+this.feedbackType);
        return getQuestionsByType({ feedbackType: this.feedbackType })  // <== return here to handle promises
            .then(result => {
                this.error = undefined;
                console.log('loadQuestions :: '+JSON.stringify(result));
                if(result.length > 0){
                    this.allQuestions = result;
                    console.log('loadQuestions :: '+JSON.stringify(this.allQuestions));
                    // Extract unique templates
                    const uniqueTemplates = [...new Set(result.map(q => q.templateId))];

                    // Map for combobox options
                    this.templateOptions = uniqueTemplates.map(templateName => ({
                        label: templateName,
                        value: templateName
                    })); 
                } else {
                    this.allQuestions = [];
                    this.templateOptions = [];
                    this.selectedTemplate = false;
                }
            })
            .catch(error => {
                this.error = error.body ? error.body.message : error.message;
                this.allQuestions = [];
                this.templateOptions = [];
            });
    }

    handleTemplateChange(event) {
        this.errorMessage = '';
        this.selectedTemplate = event.detail.value;
        console.log('Template selected:', this.selectedTemplate);   
        // Template record id 
        this.selectedTemplateRecId = this.allQuestions.find(u => u.templateId === this.selectedTemplate).tempRecordId;
        console.log('Template Record Id:', this.selectedTemplateRecId);    
        this.filterQuestions();
    }

    filterQuestions() {
        console.log('filterQuestions() executed !');
        console.log('this.selectedTemplate :'+this.selectedTemplate);
        console.log('this.allQuestions : '+JSON.stringify(this.allQuestions));
        
        if (this.selectedTemplate) {
            this.questionsForSelectedTemplate = this.allQuestions.filter(q => q.templateId === this.selectedTemplate);
            console.log('this.questionsForSelectedTemplate :'+JSON.stringify(this.questionsForSelectedTemplate));
        } else {
            this.questionsForSelectedTemplate = [];
        }
    }

    handleFromDateChange(event) {
        this.errorMessage = '';
        this.fromDate = event.target.value;
        console.log('From Date selected:', this.fromDate);
    }

    handleToDateChange(event) {
        this.errorMessage = '';
        this.toDate = event.target.value;
        console.log('To Date selected:', this.toDate);
    }

    handleAttendanceChange(event){
        this.errorMessage = '';
        this.minAttendance = event.target.value;
    }

    handleCheckboxChange(event) {
        this.isChecked = event.target.checked;
        console.log('Checkbox value:', this.isChecked);
    }


    handleDialogSubmit(){
        
        const payload = {
            Program_Batch_Id__c : this.selectedProgramBatch,
            Program_Batch_Name__c : this.selectedProgramBatchName,
            Program_Id__c : this.selectedProgram,
            Program_Name__c : this.selectedProgramName,
            Semester_Id__c : this.selectedSemester,
            Semester_Name__c : this.selectedSemesterName,
            Start_Date__c : this.fromDate,
            End_Date__c : this.toDate,
            Template_Type__c : this.templateTypeDefaultValue,
            FeedbackTemplate__c : this.selectedTemplateRecId,
            Active__c : this.isChecked,
            Template_Id__c : this.selectedTemplate,
            Minimum_attendance__c : this.minAttendance
        };
        console.log('Handle Submit !!'); 
        // console.log('Selected value -->  Program_Batch_Id__c : '+payload.Program_Batch_Id__c +' : '+
        //     'Program_Batch_Name__c : '+payload.Program_Batch_Name__c +' : '+
        //     'Program_Id__c : '+payload.Program_Id__c +' : '+
        //     'Program_Name__c : '+payload.Program_Name__c +' : '+
        //     'Semester_Id__c : '+payload.Semester_Id__c +' : '+
        //     'Semester_Name__c : '+payload.Semester_Name__c +' : '+
        //     'Start_Date__c : '+payload.Start_Date__c +' : '+
        //     'End_Date__c : '+payload.End_Date__c +' : '+
        //     'Template_Type__c : '+payload.Template_Type__c +' : '+
        //     'FeedbackTemplate__c : '+payload.FeedbackTemplate__c +' : '+
        //     'Active__c : '+payload.Active__c );

            
            console.log('Selected value -->', JSON.stringify(payload, null, 2));

            // On click of update below fields to be get updated
           
            // this.allQuestions = [];
            // this.templateOptions = [];
            // this.handleTemplateTypeChange();

            // this.feedbackType = 'Faculty';
            // this.loadQuestions();
            // this.selectedTemplate = 'FT-0001';       
            // this.filterQuestions();

         //   this.questionsForSelectedTemplate = [];
            
            

            //****************** */ On click of update below fields to be get updated

            // this.templateTypeDefaultValue = 'Faculty';
            // this.selectedTemplate = '';
            // this.feedbackType = 'Faculty';
            // this.selectedTemplate = 'FT-0001';  

            // this.loadQuestions().then(() => {
            //     this.filterQuestions();
            // });
            
            // this.selectedProgram = '001Ip00000DLrlrIAD';
            // this.selectedProgramBatch = '';            
            // this.selectedSemester = '';
            // this.templateTypeDefaultValue = 'Faculty';
            // this.selectedTemplate = 'FT-0001';   
            // this.fromDate='';
            // this.toDate='';
            // this.isChecked = false;
            

            // **********************************************************************************
            if(this.selectedProgramBatch === "" || this.selectedProgramBatchName  === "" || this.selectedProgram  === "" || this.selectedProgramName  === "" || this.selectedSemester  === "" || this.selectedSemesterName  === "" 
                || this.fromDate  == null || this.toDate  == null || this.templateTypeDefaultValue  === "" || this.selectedTemplateRecId  === "" || this.selectedTemplate  === "" || this.minAttendance  === undefined){               
                this.errorMessage = 'All Fields Are Mandatory';                
            }else{  
                    this.isSpinner = true;           
                    this.showSetUpModal = false;   
                    insertFeedbackRelease({ feedback: payload })            
                        .then((result) => {
                            console.log('Response Result :: ' + result); 
                            
                            if (result === 'exists') {
                                this.dispatchEvent(new ShowToastEvent({
                                    title: 'Duplicate Found',
                                    message: 'Feedback Release already exists.',
                                    variant: 'warning'
                                }));
                            } else if (result === 'success') {
                                this.dispatchEvent(new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Feedback Release created.',
                                    variant: 'success'
                                }));
                            } else {
                                this.dispatchEvent(new ShowToastEvent({
                                    title: 'Unknown Response',
                                    message: 'Unexpected result from server: ' + result,
                                    variant: 'info'
                                }));
                            }
                            // eslint-disable-next-line @lwc/lwc/no-async-operation
                            setTimeout(() => {
                                this.isSpinner = false;
                                return refreshApex(this.wiredData);
                            }, 300);                             
                        })
                        .catch(error => {
                            console.error('Error in insert Feedback:', error);
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error saving feedback',
                                    message: error.body.message,
                                    variant: 'error'
                                })
                            );
                        });
                }
    }

        handleDialogUpdate(){
            // Validating all the fields
            const fieldsToValidate = [
                'program',
                'programBatch',
                'semester',
                'templateType',
                'templateSelect',
                'fromDate',
                'toDate',
                'minAttendance'
            ];
        
            let allValid = true;
        
            fieldsToValidate.forEach((fieldId) => {
                const input = this.template.querySelector(`[data-id="${fieldId}"]`);
                if (input) {
                    // Optional: Add custom validation for empty value
                    if (!input.value) {
                        input.setCustomValidity('This field is required');
                    } else {
                        input.setCustomValidity('');
                    }
        
                    if (!input.checkValidity()) {
                        input.reportValidity();
                        allValid = false;
                    }
                }
            });
        
            // Extra custom validation: fromDate <= toDate
            const fromDateInput = this.template.querySelector('[data-id="fromDate"]');
            const toDateInput = this.template.querySelector('[data-id="toDate"]');
        
            if (fromDateInput && toDateInput) {
                const from = new Date(fromDateInput.value);
                const to = new Date(toDateInput.value);
                if (from > to) {
                    toDateInput.setCustomValidity('To Date must be after From Date');
                    toDateInput.reportValidity();
                    allValid = false;
                } else {
                    toDateInput.setCustomValidity('');
                }
            }
        
            if (allValid) {
                // Proceed with logic
                console.log('All fields valid. Submitting...');
                this.updateData();
            } else {
                console.log('Validation failed. Fix errors before submitting.');
            }       
        }

        updateData(){
            console.log('Handle Update !!');
            this.showSetUpModal = false;
            const updatePayload = {
                // Program_Batch_Id__c : this.selectedProgramBatch,
                // Program_Batch_Name__c : this.selectedProgramBatchName,
                // Program_Id__c : this.selectedProgram,
                // Program_Name__c : this.selectedProgramName,
                // Semester_Id__c : this.selectedSemester,
                // Semester_Name__c : this.selectedSemesterName,
                Id : this.recordId,
                Start_Date__c : this.fromDate,
                End_Date__c : this.toDate,
                Template_Type__c : this.templateTypeDefaultValue,
                Minimum_attendance__c : this.minAttendance,
                Active__c : this.isChecked,
                Template_Id__c : this.selectedTemplate
            };
            console.log('Selected value -->', JSON.stringify(updatePayload, null, 2));
            this.isSpinner = true;
            updateFeedbackRelease({ feedback: updatePayload })            
                    .then((result) => {
                        console.log('Response Result :: ' + result); 
            
                        if (result === 'success') {
                            this.dispatchEvent(new ShowToastEvent({
                                title: 'Success',
                                message: 'Feedback Release Updated.',
                                variant: 'success'
                            }));
                        } else {
                            this.dispatchEvent(new ShowToastEvent({
                                title: 'Unknown Response',
                                message: 'Unexpected result from server: ' + result,
                                variant: 'info'
                            }));
                        }
                    })
                    .catch(error => {
                        console.error('Error in insert Feedback:', error);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error updating feedback',
                                message: error.body.message,
                                variant: 'error'
                            })
                        );
                    });
                     // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => {
                    this.isSpinner = false;
                    return refreshApex(this.wiredData);
                }, 300); 
        }
        

    columns = [
        { label: 'Program Batch Name', fieldName: 'Program_Batch_Name__c', editable: false },
        { label: 'Program Name', fieldName: 'Program_Name__c', editable: false },
        { label: 'Semester Name', fieldName: 'Semester_Name__c', editable: false },
        { label: 'Start Date', fieldName: 'Start_Date__c', type: 'date', editable: true },
        { label: 'End Date', fieldName: 'End_Date__c', type: 'date', editable: true },
        { label: 'Template Type', fieldName: 'Template_Type__c', editable: true },
        { label: 'Feedback Template', fieldName: 'FeedbackTemplate__c', editable: true },
        { label: 'Active', fieldName: 'Active__c', type: 'boolean', editable: true },
        {
            type: 'action',
            typeAttributes: { rowActions: [{ label: 'Delete', name: 'delete' }] }
        }
    ];

    // @wire(getAllFeedbackReleases)
    // wiredFeedbacks({ error, data }) {
    //     if (data) {
    //         this.feedbackList1 = data;        
    //         console.log('Raw data from Apex:', data);
        
    //     } else if (error) {
    //         this.feedbackList1 = [];
    //     //    this.message = 'Error loading feedback releases.';
    //         console.error(error);
    //     }
    // }

    handleNew() {
        this.newFeedback = {};
        this.showModal = true;
    }

    handleChange(event) {
        const { name, value, checked, type } = event.target;
        this.newFeedback[name] = type === 'checkbox' ? checked : value;
    }

    handleCancel() {
        this.showModal = false;
    }

    // Open modal and save recordId
    openDeleteModal(event) {
        // this.recordIdToDelete = event.target.dataset.id;
        this.recordIdToDelete = event.currentTarget.dataset.id;
        console.log('selectedRecord Id for delete: '+this.recordIdToDelete);
        this.isModalOpen = true;
    }

    // Close modal without action
    closeModal() {
        this.isModalOpen = false;
        this.recordIdToDelete = null;
    }

    // Confirm delete and call Apex method
    confirmDelete() {
        this.isSpinner = true;
        deleteFeedbackRelease({ recordId: this.recordIdToDelete })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record deleted successfully',
                        variant: 'success'
                    })
                );
                this.isModalOpen = false;
                this.recordIdToDelete = null;                
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => {
                    this.isSpinner = false;
                    return refreshApex(this.wiredData);
                }, 300); 
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
                this.isModalOpen = false;
                this.recordIdToDelete = null;
            });
    }

    // async handleSaveNew() {
    //     try {
    //         const result = await insertFeedbackRelease({ feedback: this.newFeedback });
        
    //         if (result === 'exists') {
    //           this.dispatchEvent(new ShowToastEvent({
    //             title: 'Duplicate Found',
    //             message: 'Feedback Release already exists.',
    //             variant: 'warning'
    //           }));
    //         //  return refreshApex(this.wiredFeedbacksResult);
    //         } else {
    //           this.dispatchEvent(new ShowToastEvent({
    //             title: 'Success',
    //             message: 'Feedback Release created.',
    //             variant: 'success'
    //           }));
    //           this.showModal = false;
    //           return refreshApex(this.wiredFeedbacksResult);
    //         }
            
    //       } catch (error) {
    //         this.dispatchEvent(new ShowToastEvent({
    //           title: 'Error',
    //           message: error.body ? error.body.message : error.message,
    //           variant: 'error'
    //         }));
    //          return; // <== Return here as well
    //       }
    // }

    // async handleSave(event) {
    //     const updatedFields = event.detail.draftValues;
      
    //     try {
    //       await Promise.all(updatedFields.map(row => updateFeedbackRelease({ feedback: row })));
    //       this.dispatchEvent(new ShowToastEvent({ title: 'Updated', message: 'Record(s) updated.', variant: 'success' }));
    //       this.draftValues = [];
    //       return refreshApex(this.wiredFeedbacksResult);
    //     } catch (err) {
    //       console.error(err);
    //        // <== Fix: return here
    //        return null;
    //     }
        
    //   }
    // async handleRowAction(event) {
    //     const action = event.detail.action.name;
    //     const row = event.detail.row;

    //     if (action === 'delete') {
    //         await deleteFeedbackRelease({ recordId: row.Id });
    //         this.dispatchEvent(new ShowToastEvent({ title: 'Deleted', message: 'Record deleted.', variant: 'success' }));
    //         return refreshApex(this.wiredFeedbacks);
    //     }
    // }
}