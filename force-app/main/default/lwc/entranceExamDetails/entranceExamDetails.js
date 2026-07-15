import { LightningElement, track, api, wire } from 'lwc';
import createEntranceExamRecord from '@salesforce/apex/EntranceExamController.createEntranceExamRecord';
import getExamNameOptions from '@salesforce/apex/EntranceExamController.getExamNameOptions';
import getStateExamNameOptions from '@salesforce/apex/EntranceExamController.getStateExamNameOptions';
import getStateOptions from '@salesforce/apex/EntranceExamController.getStateOptions';
import updateEntranceExamField from '@salesforce/apex/EntranceExamController.updateEntranceExamField';
import entranceExamRecords from '@salesforce/apex/EntranceExamController.EntranceExamRecords';
import getSavedEntranceExams from '@salesforce/apex/EntranceExamController.getSavedEntranceExams';
import getAllotedCategoryOptions from '@salesforce/apex/EntranceExamController.getAllotedCategoryOptions';
import deleteEntranceExamRecord from '@salesforce/apex/EntranceExamController.deleteEntranceExamRecord';
import getStateByExamName from '@salesforce/apex/EntranceExamController.getStateByExamName';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EntranceExamDetails extends LightningElement {
    @api recordId; // The ID of the associated Applicant__c record
    @track isCheckboxChecked = false;
    @track isCheckboxCheckedState = false;
    @track nationalExams = []; // List for National exams
    @track stateExams = []; // List for State exams
    @track examNameOptions = [];
    @track StateexamNameOptions = [];
    @track stateOptions = []; // List to store state options
    @track allotegCat = [];
    @track selectedState = ''; // Selected state (used for state dropdown)
    @track isNoneChecked = false;
    @track isChecked = false;
    @track checkbox = false ;
    @track isSaved = false;
    @track newNationalExams = []; 
    @track newStateExams = [];

    connectedCallback() {
        this.addInitialNationalExam(); // Add an initial exam entry
        this.loadSavedEntranceExams();
    }

    @wire(entranceExamRecords)
    wiredRecords({ error, data }) {
        if (data !== undefined) {
            console.log('Entrance Exam Checkbox Value:', data);
            if (data) {
              this.checkbox = true;
              this.isCheckboxChecked = false; // Uncheck National
              this.isCheckboxCheckedState = false; // Uncheck State
              this.nationalExams = []; // Clear National exams
              this.stateExams = []; // Clear State exams
              this.isSaved = true;
            } else {
                this.isNoneChecked = false;
                console.log('No Entrance Exam record found.');
              
            }
            this.informOmniScript();
        } else if (error) {
            console.error('Error fetching Entrance Exam record:', error);
            this.error = error.body.message;
        }
    }
    


    @wire(getExamNameOptions)
    wiredExamOptions({ error, data }) {
        if (data) {
            this.examNameOptions = data.map(option => ({ label: option, value: option }));
        } else if (error) {
            this.showToast('Error', 'Failed to fetch national exam names', 'error');
        }
    }

    @wire(getStateExamNameOptions)
    wiredStateExamOptions({ error, data }) {
        if (data) {
            this.StateexamNameOptions = data.map(option => ({ label: option, value: option }));
        } else if (error) {
            this.showToast('Error', 'Failed to fetch state exam names', 'error');
        }
    }

    //  @wire(getStateOptions) // Wire service to fetch states
    // wiredStateOptions({ error, data }) {
    //     if (data) {
    //         this.stateOptions = data.map(option => ({ label: option, value: option }));
    //     } else if (error) {
    //         this.showToast('Error', 'Failed to fetch states', 'error');
    //     }
    // }
    @wire(getAllotedCategoryOptions)
    wiredCategoryOptions({ error, data }) {
        if (data) {
            this.allotegCat = data.map(option => ({ label: option, value: option }));
        } else if (error) {
            this.showToast('Error', 'Failed to fetch categories', 'error');
        }
    }
    handleCheckboxChange(event) {
        this.isCheckboxChecked = event.target.checked;
        if (this.isCheckboxChecked && this.nationalExams.length === 0) {
            this.addInitialNationalExam();
            this.isSaved = false;
            this.checkbox = false;
            this.informOmniScript();
        }
        
    }

    handleCheckboxChangeState(event) {
        this.isCheckboxCheckedState = event.target.checked;
        if (this.isCheckboxCheckedState && this.stateExams.length === 0) {
            this.addInitialStateExam();
            this.isSaved = false;
            this.checkbox = false;
            this.informOmniScript();
        }
    }

    addInitialNationalExam() {
        this.nationalExams.push({ id: this.generateUniqueId(), examName: '', rank: '', rollNo: '' ,totalMarks: '', scoredMarks: '',allotegCat: '',examType: 'National',state : this.selectedState});
    }

    addInitialStateExam() {
        this.stateExams.push({ id: this.generateUniqueId(), examName: '', rank: '', rollNo: '',totalMarks: '', scoredMarks: '' ,allotegCat: '', examType: 'State',state : this.selectedState });
    }

   handleAddNationalExam() {
    const newExam = { id: this.generateUniqueId(), examName: '', rank: '', rollNo: '', totalMarks: '', scoredMarks: '',allotegCat: '', examType: 'National', state: '' };
    this.nationalExams.push(newExam);
    this.newNationalExams.push(newExam); // Add to newNationalExams
    this.isSaved = false; // Enable Save button
    this.isSaved = false;
    this.checkbox = false;
    this.informOmniScript();
}

handleAddStateExam() {
    const newExam = { id: this.generateUniqueId(), examName: '', rank: '', rollNo: '',totalMarks: '', scoredMarks: '',allotegCat: '', examType: 'State', state: '' };
    this.stateExams.push(newExam);
    this.newStateExams.push(newExam); // Add to newStateExams
    this.isSaved = false; // Enable Save button
    this.isSaved = false;
    this.checkbox = false;
    this.informOmniScript();
}


    handleRemoveExam(event) {
        const examId = event.target.dataset.id;
        this.nationalExams = this.nationalExams.filter(exam => exam.id !== examId);
       
        deleteEntranceExamRecord({ examId })
        .then(() => {
            this.nationalExams = this.nationalExams.filter(exam => exam.id !== examId);
            this.showToast('Success', 'Exam record deleted successfully', 'success');
        })
        .catch((error) => {
           // this.showToast('Error', error.body.message, 'error');
        });
    }

    handleRemoveExamState(event) {
        const examId = event.target.dataset.id;
        this.stateExams = this.stateExams.filter(exam => exam.id !== examId);
    
        deleteEntranceExamRecord({ examId })
        .then(() => {
            this.stateExams = this.stateExams.filter(exam => exam.id !== examId);
            this.showToast('Success', 'Exam record deleted successfully', 'success');
        })
        .catch((error) => {
          //  this.showToast('Error', error.body.message, 'error');
        });
    }

    handleExamChange(event) {
        const { name, value } = event.target;
        const examId = event.target.dataset.id;
        this.nationalExams = this.nationalExams.map(exam => {
            if (exam.id === examId) {
                if (name === 'examName' && this.isDuplicateExamName(value, 'National')) {
                    this.showToast('Error', 'Duplicate exam names are not allowed', 'error');
                    return exam; // Revert change
                }
                return { ...exam, [name]: value };
            }
            return exam;
        });
    }

    handleExamChangeState(event) {
        const { name, value } = event.target;
        const examId = event.target.dataset.id;
        this.stateExams = this.stateExams.map(exam => {
            if (exam.id === examId) {
                if (name === 'examName' && this.isDuplicateExamName(value, 'State')) {
                    this.showToast('Error', 'Duplicate exam names are not allowed', 'error');
                    return exam; // Revert change
                }
                return { ...exam, [name]: value };
            }
            return exam;
        });
        if (name === 'examName') {
            this.fetchStateForExam(value, examId);
        }
    }

    fetchStateForExam(examName, examId) {
        getStateByExamName({ examName })  // Assuming you have an Apex method that fetches state by exam name
            .then((state) => {
                console.log('state:'+state);
                this.stateExams = this.stateExams.map(exam => {
                    if (exam.id === examId) {
                        return { ...exam, state: state }; // Update the state field
                    }
                    return exam;
                });
            })
            .catch((error) => {
                this.showToast('Error', 'Failed to fetch state for selected exam', 'error');
            });
    }
    
    handleSave() {
        if (!this.isNoneChecked && !this.isCheckboxChecked && !this.isCheckboxCheckedState) {
            this.showToast('Error', 'Please select any one option', 'error');
            return;
        }
    
        if (this.isNoneChecked) {
            createEntranceExamRecord({ exams: [] })
                .then(() => {
                    this.showToast('Success', 'Entrance Exam records created successfully', 'success');
                    this.loadSavedEntranceExams(); // Refresh data after save
                })
                .catch((error) => {
                    this.showToast('Error', error.body.message, 'error');
                });
        } else {
            let examsToSave = [];
            if (this.isCheckboxChecked) examsToSave = this.nationalExams;
            if (this.isCheckboxCheckedState) examsToSave = [...examsToSave, ...this.stateExams];
           

            const examNames = examsToSave.map(exam => exam.examName);
            const duplicates = examNames.filter((name, index) => examNames.indexOf(name) !== index);
            if (duplicates.length > 0) {
                this.showToast('Error', 'Duplicate exam names found. Please ensure all exam names are unique.', 'error');
                return;
            }
            // Validate that all fields are filled, and State is mandatory for state exams
            const isValid = examsToSave.every((exam) => {
                if (!exam.examName || !exam.rollNo) {
                    return false; // Basic fields validation
                }
                if (exam.examType === 'State' && !exam.state) {
                    return false; // State field validation for State exams
                }
                return true;
            });
    
            if (!isValid) {
                this.showToast('Error', 'Duplicate exam names found or Please fill all the required fields', 'error');
                return;
            }
    
            // Save data to server
            createEntranceExamRecord({ applicantId: this.recordId, exams: examsToSave })
                .then(() => {
                    this.showToast('Success', 'Entrance Exam records created successfully', 'success');
                    this.loadSavedEntranceExams(); // Refresh data after save
                    this.isSaved = true; // Disable Save button
                    this.newNationalExams = []; // Clear newly added exams
                    this.newStateExams = [];
                })
                .catch((error) => {
                    this.showToast('Error', error.body.message, 'error');
                });       
        }
        this.checkbox = true;
        this.informOmniScript();
    }
    

    generateUniqueId() {
        return Math.random().toString(36).substring(2, 15) + Date.now().toString(36);
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(event);
    }

    handleNoneCheckboxChange(event) {
        this.isNoneChecked = event.target.checked;
        if (this.isNoneChecked) {
            this.isCheckboxChecked = false;
            this.isCheckboxCheckedState = false;
            this.nationalExams = [];
            this.stateExams = [];
            this.isSaved = true;
            this.checkbox = true;
           
          
            updateEntranceExamField({ 
                entranceExamValue: true // "None" means Entrance Exam is not applicable
            })
            .then(() => {
               // this.showToast('Success', 'Entrance Exam field updated successfully', 'success');
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
        }else{
            this.isSaved = false;
            this.checkbox = false;
            updateEntranceExamField({ 
                entranceExamValue: false // "None" means Entrance Exam is not applicable
            })
        }
        this.informOmniScript();
    }

      loadSavedEntranceExams() {
        getSavedEntranceExams({ applicantId: this.recordId })
            .then((data) => {
                if (data) {
                    this.nationalExams = [];
                    this.stateExams = [];
                    data.forEach((exam) => {
                        const examRecord = {
                            id: exam.Id,
                            examName: exam.Name,
                            rank: exam.Rank__c,
                            rollNo: exam.Roll_No__c,
                            state: exam.State__c,
                            totalMarks: exam.Total_Marks__c,
                            scoredMarks: exam.Scored_Marks__c,
                            allotegCat: exam.Allotted_Category__c
                        };
                        if (exam.Exam_Type__c === 'National') {
                            this.nationalExams.push(examRecord);
                            this.isSaved = true;
                            this.isChecked=true;
                        } else if (exam.Exam_Type__c === 'State') {
                            this.stateExams.push(examRecord);
                            this.isSaved = true;
                            this.isChecked=true;
                        } 
                    });
                    this.isCheckboxChecked = this.nationalExams.length > 0; 
                    this.isCheckboxCheckedState = this.stateExams.length > 0;
                    this.informOmniScript();
                }
            })
            .catch((error) => {
                this.showToast('Error', 'Failed to load saved exams', 'error');
                console.error('Error fetching saved exams:', error);
            });
    }
    

informOmniScript() {
    let photoUploaded = false;
    console.log(' this.isSaved:', this.isSaved);
    console.log('this.checkbox:', this.checkbox);

    if (this.isSaved === true || this.checkbox === true) {
        photoUploaded = true;
    }

    console.log('photoUploaded:', photoUploaded);

    const omniAggregateEvent = 'omniaggregate';
    const data = photoUploaded;
    const detail = {
        data,
        elementId: 'photoUploaded'
    };
    const myEvent = new CustomEvent(omniAggregateEvent, {
        bubbles: true,
        cancelable: true,
        composed: true,
        detail: detail,
    });
    console.log('photoUploaded:', JSON.stringify(detail));
    this.dispatchEvent(myEvent);
}
isDuplicateExamName(examName, examType) {
    const allExams = examType === 'National' ? this.nationalExams : this.stateExams;
    return allExams.filter(exam => exam.examName === examName).length > 0;
}
}