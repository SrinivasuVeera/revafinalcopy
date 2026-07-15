import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord } from 'lightning/uiRecordApi';

import createSummitTracker from '@salesforce/apex/smt_Summit_Tracker_Controller.createSummitTracker';
import getSummitSectionsMetadata from '@salesforce/apex/smt_Summit_Tracker_Controller.getSummitSectionsMetadata';
import createSummitSections from '@salesforce/apex/smt_Summit_Tracker_Controller.createSummitSections';
import getSummitSectionRecords from '@salesforce/apex/smt_Summit_Tracker_Controller.getSummitSectionRecords';
import getSummitTracker from '@salesforce/apex/smt_Summit_Tracker_Controller.getSummitTracker';
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Account.Name';

export default class Smt_Na_Create_Summit_Sections extends LightningElement {

    isSummitTracker = true;
    isSummitSectionCreation = false;
    showParticulars = false;
    showSummitSectionCreatedRecords = false;
    showExistingSummitTrackerRecords = false;
    showUnAvailabilityOfSummitTracker = false;
    summitTrackerName;
    @track summitSections = [];
    summitTrackerBatch;
    summitTrackerId;
    schoolId;
    isSpinner;
    summitSectionRecords;
    selectedSectionName;
    selectedSectionId;
    summitTrackers;
    wiredData;
    buttonLabel;
    keyCount = 0;
    semesterOneTimeline;
    semesterTwoTimeline;
    accountName;

    isNACreated = false;
    weightageAchievedDummy = 0;
    badgeStyleDummy;
    summitYearDummy = '2026';
    trackerNameDummy = 'Summit 11';
    NA_showExistingSummitTrackerRecords = false;
    Category = 'NON_ACADEMIC';

 //   @track sections = [];
    @track savedSections = []; // 🔹 stores final created sections
    @track showViewTable = false;

    @track particulars = [];
    @track savedParticulars = [];
    @track showSavedTablePartcular = false;

    rowId = 0;
    isNAParticularCreated = false;

    //departmentId;
    departmentName;

    connectedCallback() {     
        // eslint-disable-next-line no-constant-condition
        this.badgeStyleDummy = 0 > 90 ?  'background: #8bda56;min-width: 40%; max-width:60%; display: flex; justify-content: center; color: black;':
        // eslint-disable-next-line no-constant-condition
        0 > 70 ? 'background: #ffa750;min-width: 40%; max-width:60%; display: flex; justify-content: center; color: black;'
            : 'background: #ff5050;min-width: 40%; max-width:60%; display: flex; justify-content: center; color: white;'
    }

    @wire(getRecord, { recordId: '$schoolId', fields: [ACCOUNT_NAME_FIELD] })
    wiredAccount({ error, data }) {
        if (data) {
            this.accountName = data.fields.Name.value;
        } else if (error) {
            console.error('Error retrieving account data', error);
        }
    }


    
    @wire(getSummitTracker, { schoolId: '$schoolId' })
    getSummitTracker(result) {
        this.wiredData = result;
        this.isSpinner = true;
        if (result.data) {
            this.isSpinner = false;
            if (result.data.length == 0) {
                this.showExistingSummitTrackerRecords = false;
                this.showUnAvailabilityOfSummitTracker = true;
                return;
            }
            this.showUnAvailabilityOfSummitTracker = false;
             this.showExistingSummitTrackerRecords = true;
            this.summitTrackers = result.data.map(summitTracker => {
                let weightageAchieved = summitTracker.smt_Total_Weightage_Achieved__c || 0;

                let badgeStyle = weightageAchieved > 90 ?  'background: #8bda56;min-width: 40%; max-width:60%; display: flex; justify-content: center; color: black;':
                    weightageAchieved > 70 ? 'background: #ffa750;min-width: 40%; max-width:60%; display: flex; justify-content: center; color: black;'
                        : 'background: #ff5050;min-width: 40%; max-width:60%; display: flex; justify-content: center; color: white;'
                
                weightageAchieved += ' %';
                             
                return {
                    ...summitTracker,
                    badgeStyle,
                    weightageAchieved
                }
            });

            this.showSummitTracker = true;
        } else if (result.error) {
            this.isSpinner = false;
            console.error('Error when fetching summit trackers ' + result.error);
            this.showToastNotification('Error when fetching summit trackers', result.error.body.message, 'error');
        }
        this.isSpinner = false;
    }
    handleSemesterOneTimelineChange(event) {
        this.semesterOneTimeline = event.target.value;
    }
    handleSemesterTwoTimelineChange() {
        this.semesterTwoTimeline = event.target.value;
    }
    handleTrackerNameChange(event) {
        this.summitTrackerName = event.target.value;
    }
    handleBatchChange(event) {
        this.summitTrackerBatch = event.target.value;
    }
    async handleCreateSmtTracker(event) {
        this.showUnAvailabilityOfSummitTracker = false;
        this.showExistingSummitTrackerRecords = false;
        this.showSummitSectionCreatedRecords = false;
        if (!this.schoolId || !this.summitTrackerName || !this.summitTrackerBatch) {
            this.showToastNotification('Please Fill All Values', 'Fill School,Summmit Tracker Name and Batch', 'info');
            return;
        }
        this.isSpinner = true;
        try {
            this.summitTrackerId = await createSummitTracker({
                summitTrackerName: this.summitTrackerName,
                schoolId: this.schoolId,
                batch: this.summitTrackerBatch,
                category : this.Category
            });
            this.showToastNotification('Summit Tacker Created Successfully NON_ACADEMIC', `Id : ${this.summitTrackerId}`, 'success');
          //  this.getSummitSectionsMetadata();
            this.isNACreated = true; 
           
        } catch (error) {
            console.error(JSON.stringify(error));
            this.showToastNotification('Error Creating Record', error.body.message, 'error');
        }
        finally {
            this.isSpinner = false;
        }        
    }

    handleCreateSmtTrackerNA(event){    
        this.isNACreated = true;        
    }

    handleSchoolSelect(event) {
        this.schoolId = event.target.value;
        console.log('this.schoolId : '+this.schoolId);
        this.isSummitSectionCreation = false;
        this.showSummitSectionCreatedRecords = false;
        this.showParticulars = false;
    }

    getSummitSectionsMetadata() {
        getSummitSectionsMetadata()
            .then(data => {
                let sNo = 0;
                this.summitSections = data.map(summitSection => {
                    sNo++;
                    return {
                        id: sNo,
                        sectionName: summitSection.MasterLabel,
                        weightage: summitSection.smt_Weightage__c || 0,
                    }
                })
                
            }).catch(error => {
                console.error('Error when fetching summit sections ' + error);
            })
        //this.isSummitTracker = false;
        this.isSummitSectionCreation = true;
    }
   

  

    handleSectionValueChange(event) {
        const fieldName = event.target.dataset.fieldName;
        const id = event.target.dataset.id;
        const changedSummitSection = this.summitSections.find(summitSection => summitSection.id == id);
        if (changedSummitSection) {
             changedSummitSection[fieldName] = event.target.value;
        }        
    }
    
    handleCreateSections() {
        this.isSpinner = true;
        // if (!this.summitTrackerId) {
        //     this.showToastNotification('Summit Tracker Record Is Not Created', 'Try creating the summit tracker record and then try creating summit section', 'info');
        // } else {
            // createSummitSections({ jsonData: JSON.stringify(this.summitSections) , summitTrackerId: this.summitTrackerId})
                createSummitSections({ jsonData: JSON.stringify(this.savedSections) , summitTrackerId: this.summitTrackerId})
                .then(result => {
                    this.isSpinner = true;
                    this.showToastNotification('Summit Section Records Created Successfully', '', 'success');
                    //this.isSummitTracker = false;
                    this.isSummitSectionCreation = false;
                    this.showSummitSectionCreatedRecords = true;
                    this.getSummitSectionRecords();
                }).catch(error => {
                this.isSpinner = false;
                console.error(error);
                 this.showToastNotification('Error Occured When Creating Sections', error.body.message, 'error');
            })
    //    }

    }

    getSummitSectionRecords() {
        getSummitSectionRecords({ summitTrackerId: this.summitTrackerId , keyCount : this.keyCount})
            .then(result => {
                this.summitSectionRecords = result.map(summitSection => {
                    let isSummitParticularCreateDisabled = summitSection.smt_No_Of_Particulars_Without_Condition__c > 0 ? true : false;
                    let isSummitParticularUpdateDisabled = !isSummitParticularCreateDisabled;
                    return {
                        ...summitSection,
                        isSummitParticularCreateDisabled,
                        isSummitParticularUpdateDisabled

                    }
                });
            })
            .catch(error => {
                console.error(error);
                 this.showToastNotification('Error Occured When Fetching Sections', error.body.message, 'error');
            })
        this.isSpinner = false;
    }

      handleGetSections(event) {
          this.summitTrackerId = event.target.dataset.id; 
          this.getSummitSectionRecords();  
          this.showSummitSectionCreatedRecords = true;
    }
      
    handleGetParticulars(event) {
        const sectionName = event.target.dataset.sectionName;
        const sectionId = event.target.dataset.id;
        this.selectedSectionId = sectionId;
        this.selectedSectionName = sectionName;
        this.keyCount++;
        this.showParticulars = true;
        this.showSummitSectionCreatedRecords = false;
        this.buttonLabel = 'Create Particulars';        
    }

    handleUpdateParticulars(event) {
        const sectionName = event.target.dataset.sectionName;
        const sectionId = event.target.dataset.id;
        this.selectedSectionId = sectionId;
        this.selectedSectionName = sectionName;
        this.keyCount++;
        this.showParticulars = true;
        this.showSummitSectionCreatedRecords = false;
        this.buttonLabel = 'Update Particulars';
    }


     showToastNotification(title, message,  variant) {
        const evt = new ShowToastEvent({
        title,message,variant
        });
        this.dispatchEvent(evt);
     }
    handleClickBackFromChild() {
        this.keyCount++;
        this.getSummitSectionRecords();
        this.showSummitSectionCreatedRecords = true;
        this.showParticulars = false;
    }

    //*************** NA Section Ceation *********************/
    @track sections = [];
    sectionId = 0;
    remainingWeightage = 100;

    addSection() {
        this.sections = [
            ...this.sections,
            {
                id: ++this.sectionId,
                srNo: this.sections.length + 1,
                name: '',
                weightage: ''
            }
        ];
    }

    handleChange(event) {
        const id = event.target.dataset.id;
        const field = event.target.dataset.field;
        const value = event.target.value;

        this.sections = this.sections.map(section => {
            if (section.id == id) {
                return { ...section, [field]: value };
            }
            return section;
        });

        this.calculateRemainingWeightage();
    }

    deleteRow(event) {
        const id = event.target.dataset.id;
        this.sections = this.sections.filter(section => section.id != id);
        this.recalculateSerialNumbers();
        this.calculateRemainingWeightage();
    }

    recalculateSerialNumbers() {
        this.sections = this.sections.map((section, index) => {
            return { ...section, srNo: index + 1 };
        });
    }

    calculateRemainingWeightage() {
        let total = 0;
        this.sections.forEach(section => {
            total += Number(section.weightage || 0);
        });
        this.remainingWeightage = 100 - total;
    }

    // createSection() {
    //     let totalWeightage = 0;
    //     let isValid = true;

    //     this.sections.forEach(section => {
    //         if (!section.name || section.weightage === '') {
    //             isValid = false;
    //         }
    //         totalWeightage += Number(section.weightage || 0);
    //     });

    //     if (!isValid) {
    //         this.showToast('Error', 'Section Name and Weightage are required', 'error');
    //         return;
    //     }

    //     if (totalWeightage !== 100) {
    //         this.showToast('Error', 'Weightage must be 100%', 'error');
    //         return;
    //     }

    //     this.showToast('Success', 'Sections created successfully', 'success');
    //     this.NA_showExistingSummitTrackerRecords = true;
    //     this.isNACreated = false;
    // }

    createSection() {
        let totalWeightage = 0;
        let isValid = true;

        let tempArray = [];

        this.sections.forEach(section => {
            if (!section.name || section.weightage === '') {
                isValid = false;
            }

            totalWeightage += Number(section.weightage || 0);

            // id: sNo,
            //             sectionName: summitSection.MasterLabel,
            //             weightage: summitSection.smt_Weightage__c || 0,

            tempArray.push({
                id: section.srNo,
                sectionName: section.name,
                weightage: section.weightage || 0
            });

            // tempArray.push({
            //     srNo: section.srNo,
            //     name: section.name,
            //     weightage: section.weightage
            // });
        });

        if (!isValid) {
            this.showToast('Error', 'Section Name and Weightage are required', 'error');
            return;
        }

        if (totalWeightage !== 100) {
            this.showToast('Error', 'Weightage must be 100%', 'error');
            return;
        }

        // ✅ Store values in array
        this.savedSections = tempArray;
        this.showViewTable = false;
        
        this.showExistingSummitTrackerRecords = false;
        this.isNACreated = false;
        
        this.showToast('Success', 'Sections created successfully', 'success');
        this.handleCreateSections();
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }

    handleView() {
        this.showViewTable = true;
    }

    /**************** Particulars creation *************** */

    addRow() {
        this.particulars = [
            ...this.particulars,
            {
                id: ++this.rowId,
                name: '',
                timeline: '',
                target: ''
            }
        ];
    }

    handleChange1(event) {
        const rowId = parseInt(event.target.dataset.id, 10);
        const field = event.target.dataset.field;
        const value = event.target.value;

        this.particulars = this.particulars.map(row => {
            if (row.id === rowId) {
                return { ...row, [field]: value };
            }
            return row;
        });
    }

    removeRow(event) {
        const rowId = parseInt(event.target.dataset.id, 10);
        this.particulars = this.particulars.filter(row => row.id !== rowId);
    }

    createParticulars() {
        const inputs = this.template.querySelectorAll('lightning-input');
        let isValid = true;

        inputs.forEach(input => {
            if (!input.checkValidity()) {
                input.reportValidity();
                isValid = false;
            }
        });

        if (!isValid) {
            this.showToast('Error', 'Please fill all required fields.', 'error');
            return;
        }

        // ✅ Store data as array of objects
        this.savedParticulars = this.particulars.map(row => ({
            name: row.name,
            timeline: row.timeline,
            target: row.target
        }));

        this.showToast(
            'Success',
            'Particulars created successfully!',
            'success'
        );

        // Optional: clear input table
        // this.particulars = [];
        this.showSavedTablePartcular = false;
    }

    viewParticulars() {
        if (this.savedParticulars.length === 0) {
            this.showToast('Info', 'No particulars available to view.', 'info');
            return;
        }
        this.showSavedTablePartcular = true;
    }

    // eslint-disable-next-line no-dupe-class-members
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
    
    handleNAGetParticulars(event){
        // this.isNAParticularCreated = true;
        this.showParticulars = true;
        
        const sectionName = event.target.dataset.sectionName;
        const sectionId = event.target.dataset.id;
        this.selectedSectionId = sectionId;
        this.selectedSectionName = sectionName;
        this.keyCount++;
        this.showParticulars = true;
        this.showSummitSectionCreatedRecords = false;
        this.buttonLabel = 'Create Particulars'; 
    }

    handleDepartmentChange(event) {
        this.schoolId = event.detail.recordId;
        this.departmentName = event.detail.recordName;
        
        // console.log('Selected Department:', this.departmentId, this.departmentName);
    }
}