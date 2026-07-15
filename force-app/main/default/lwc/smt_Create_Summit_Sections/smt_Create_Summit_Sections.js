import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord } from 'lightning/uiRecordApi';

import createSummitTracker from '@salesforce/apex/smt_Summit_Tracker_Controller.createSummitTracker';
import getSummitSectionsMetadata from '@salesforce/apex/smt_Summit_Tracker_Controller.getSummitSectionsMetadata';
import createSummitSections from '@salesforce/apex/smt_Summit_Tracker_Controller.createSummitSections';
import getSummitSectionRecords from '@salesforce/apex/smt_Summit_Tracker_Controller.getSummitSectionRecords';
import getSummitTracker from '@salesforce/apex/smt_Summit_Tracker_Controller.getSummitTracker';
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Account.Name';

export default class Smt_Create_Summit_Sections extends LightningElement {

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
    departmentName;
    Category = 'ACADEMIC';

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
            this.showToastNotification('Summit Tacker Created Successfully ACADEMIC', `Id : ${this.summitTrackerId}`, 'success');
            this.getSummitSectionsMetadata();
           
        } catch (error) {
            console.error(JSON.stringify(error));
            this.showToastNotification('Error Creating Record', error.body.message, 'error');
        }
        finally {
            this.isSpinner = false;
        }        
    }
    handleSchoolSelect(event) {
        this.schoolId = event.target.value;
        this.isSummitSectionCreation = false;
        this.showSummitSectionCreatedRecords = false;
        this.showParticulars = false;
        console.log('this.schoolId 123 : '+this.schoolId);
    }

    getSummitSectionsMetadata() {
        getSummitSectionsMetadata()
            .then(data => {
                let sNo = 0;
                // this.summitSections = data.map(summitSection => {
                //     sNo++;
                //     return {
                //         id: sNo,
                //         sectionName: summitSection.MasterLabel,
                //         weightage: summitSection.smt_Weightage__c || 0,
                //         sectionTypeName : summitSection.Summit_Section_Type__r.Summit_Type_Name__c, 
                //     }
                // })
                this.summitSections = data
                .filter(summitSection => summitSection.MasterLabel !== 'Outreach')
                .map(summitSection => {
                    sNo++;
                    return {
                        id: sNo,
                        sectionName: summitSection.MasterLabel,
                        weightage: summitSection.smt_Weightage__c || 0,                     
                    }
                });
                
                console.log('SummitSectionsMetadata : '+JSON.stringify(this.summitSections));
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
        if (!this.summitTrackerId) {
            this.showToastNotification('Summit Tracker Record Is Not Created', 'Try creating the summit tracker record and then try creating summit section', 'info');
        } else {
            createSummitSections({ jsonData: JSON.stringify(this.summitSections) , summitTrackerId: this.summitTrackerId})
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
        }

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

    handleDepartmentChange(event) {
        this.schoolId = event.detail.recordId;
        this.departmentName = event.detail.recordName;
        
        // console.log('Selected Department:', this.departmentId, this.departmentName);
    }
}