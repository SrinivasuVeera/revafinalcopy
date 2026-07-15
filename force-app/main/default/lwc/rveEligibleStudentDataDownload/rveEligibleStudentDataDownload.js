import { LightningElement, track, api } from 'lwc';
import getUserSchools from '@salesforce/apex/RVEEligibleStudentDownloadController.getUserSchools';
import getProgramBatches from '@salesforce/apex/RVEEligibleStudentDownloadController.getProgramBatches';
import getSemesters from '@salesforce/apex/RVEEligibleStudentDownloadController.getSemesters';
import getFilteredStudents from '@salesforce/apex/RVEEligibleStudentDownloadController.getFilteredStudents';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class RveEligibleStudentDataDownload extends LightningElement {
    @track isOpen = false;
    @track schoolOptions = [];
    @track programBatchOptions = [];
    @track semesterOptions = [];
    @track noRecordsFound = false;
    @track isDownloadEnabled = false;

    selectedSchool;
    selectedBatch;
    selectedSemester;
    selectedEligibility;
    selectedExamType;

    @track students = [];

    eligibilityOptions = [
        { label: 'Eligible', value: 'Eligible' },
        { label: 'Ineligible', value: 'Ineligible' },
        { label: 'Approved by School Director', value: 'Approved by School Director' }
        
    ];

    examTypeOptions =[
        { label: 'Semester', value: 'Semester' },
        { label: 'IA 1', value: 'IA 1' },
        { label: 'IA 2', value: 'IA 2'} 

    ]

    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Email', fieldName: 'Email' },
        { label: 'SRN Number', fieldName: 'SRN_Number__c' }
      /*  { label: 'School', fieldName: 'School__r.Name' },
        
        { label: 'Exam Approval', fieldName: 'Exam_Approval__c' }*/
    ];

    @api openModal() {
        this.isOpen = true;
        this.noRecordsFound = false;
        this.loadSchools();
    }

    handleClose() {
        this.isOpen = false;
        this.students = [];
        this.noRecordsFound = false; 
        this.selectedSchool = null;
        this.selectedBatch = null;
        this.selectedSemester = null;
        this.selectedEligibility = null;
        this.selectedExamType = null;
        this.isDownloadEnabled = false;
        window.location.reload();
    }

    loadSchools() {
        getUserSchools()
            .then(result => {
                this.schoolOptions = result;
            })
            .catch(error => {
                console.error('Error loading schools: ', error);
            });
    }

    /********************/
    
    /*******************/

    handleSchoolChange(event) {
        this.selectedSchool = event.detail.value;
        //this.resetDownload();
        this.selectedBatch = null;
        this.selectedSemester = null;
        this.selectedExamType = null;
    this.selectedEligibility = null;
        this.programBatchOptions = [];
        this.semesterOptions = [];
       // this.resetStudentData();
       this.students = [];
    this.noRecordsFound = false;
    this.isDownloadEnabled = false;

        getProgramBatches({ schoolId: this.selectedSchool })
            .then(result => {
                this.programBatchOptions = result;
            })
            .catch(error => {
                console.error('Error fetching batches: ', error);
            });
    }

    handleBatchChange(event) {
        this.selectedBatch = event.detail.value;
        //this.resetDownload();
        this.selectedSemester = null;
        this.selectedExamType = null;
    this.selectedEligibility = null;
        this.semesterOptions = [];
       // this.resetStudentData();
       this.students = [];
    this.noRecordsFound = false;
    this.isDownloadEnabled = false;

        getSemesters({ programBatchId: this.selectedBatch })
            .then(result => {
                this.semesterOptions = result;
            })
            .catch(error => {
                console.error('Error fetching semesters: ', error);
            });
    }

    handleSemesterChange(event) {
        this.selectedSemester = event.detail.value;
        this.selectedExamType = null;
    this.selectedEligibility = null;
        this.students = [];
    this.noRecordsFound = false;
    this.isDownloadEnabled = false;
        //this.resetStudentData();
       // this.resetDownload();
    }

    handleEligibilityChange(event) {
        this.selectedEligibility = event.detail.value;
        this.students = [];
    this.noRecordsFound = false;
    this.isDownloadEnabled = false;
      // this.resetStudentData();
       // this.resetDownload();
    }

    handleExamTypeChange(event) {
        this.selectedExamType = event.detail.value;
        this.students = [];
    this.noRecordsFound = false;
    this.isDownloadEnabled = false;
       // this.resetStudentData();
       // this.resetDownload();
    }


    fetchStudents() {
        if (this.selectedSchool && this.selectedBatch && this.selectedSemester && this.selectedEligibility && this.selectedExamType) {
            getFilteredStudents({
                schoolId: this.selectedSchool,
                programBatchId: this.selectedBatch,
                semesterId: this.selectedSemester,
                eligibility: this.selectedEligibility,
                examType: this.selectedExamType

            })
                .then(result => {
                    this.students = result;
                    this.noRecordsFound = result.length === 0;
                    this.isDownloadEnabled = result.length > 0; // newly added
                })
                .catch(error => {
                    console.error('Error fetching students: ', error);
                    // this.isDownloadEnabled = false;  // newly added
                });
        } else {
            //alert('Please select all filters.');
           // this.isDownloadEnabled = false; // newly added
           this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Missing Filters',
                    message: 'Please select all filters before fetching students.',
                    variant: 'error',
                    mode: 'dismissable'
                })
            );
        }
    }

   /* downloadCSV() {
        if (!this.students.length) {
            alert('No student data to download.');
            return;
        }

        let csv = 'Name,Email,School,Semester,Exam Approval\n';
        this.students.forEach(row => {
            csv += `${row.Name},${row.Email},${row.School__r?.Name || ''},${row.Active_Semester__r?.Name || ''},${row.Exam_Approval__c || ''}\n`;
        });

        const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = 'EligibleStudents.csv';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }*/
    downloadPDF() {
        console.log('Selected Values:', JSON.stringify({
    schoolId: this.selectedSchool,
    batchId: this.selectedBatch,
    semesterId: this.selectedSemester,
    eligibility: this.selectedEligibility,
    examType: this.selectedExamType
}));
    this.isDownloadEnabled = false;
    const url = `/apex/DownloadEligibleStudentsPDFPage?schoolId=${this.selectedSchool}&batchId=${this.selectedBatch}&semesterId=${this.selectedSemester}&eligibility=${this.selectedEligibility}&examType=${this.selectedExamType}`;
    window.open(url, '_blank');
}

    get isBatchDisabled() {
        return this.programBatchOptions.length === 0;
    }

    get isSemesterDisabled() {
        return this.semesterOptions.length === 0;
    }

    get isExamTypeDisabled() {
       // return this.examTypeOptions.length === 0;
           return !(this.selectedSchool && this.selectedBatch && this.selectedSemester);

    }

    get isExamEligibleDisabled() {
        //return this.eligibilityOptions.length === 0;
            return !(this.selectedSchool && this.selectedBatch && this.selectedSemester && this.selectedExamType);

    }
    get isDownloadDisabled() {
    return !this.isDownloadEnabled;
   }
    /*resetFetchedData() {
    this.students = [];
    this.noRecordsFound = false;
    this.isDownloadEnabled = false;
}*/
   

}