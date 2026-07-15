import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from '@salesforce/apex';
import getSummitParticularsMetadata from '@salesforce/apex/smt_Summit_Tracker_Controller.getSummitParticularsMetadata';
import createSummitParticular from '@salesforce/apex/smt_Summit_Tracker_Controller.createSummitParticular';
import getAllSummitParticulars from '@salesforce/apex/smt_Summit_Tracker_Controller.getAllSummitParticulars';

import updateAllSummitParticular from '@salesforce/apex/smt_Summit_Tracker_Controller.updateAllSummitParticular';

import getMonthWiseSummitParticulars from '@salesforce/apex/smt_Summit_Tracker_Controller.getAllSummitMonthWiseParticulars';
import createSummitParticularMonthly from '@salesforce/apex/smt_Summit_Tracker_Controller.createSummitParticularMonthly';
import updateAllSummitParticularMonthly from '@salesforce/apex/smt_Summit_Tracker_Controller.updateAllSummitParticularMonthly';

export default class Smt_Na_Create_Summit_Particulars extends LightningElement {

    @api summitSectionLabel ;
    @api summitSectionId;
    @api buttonLabel;
    @api keyCount = 0;
    @api semesterOneTimeline;
    @api semesterTwoTimeline;
    @api schoolName;

    isSpinner;
    //+++++++++++++++++++++++++++++++++++++++++++++++++++      
    
    monthsDataVal = [];
    @track
    changedSummitParticular;    
    modalButtonLabel;// update or insert button display
    summitParticularId;
    // wiredData;
    @track 
    isEnterMonthlyButtonDisabled = false; // show 'Enter Monthly' button by default
    isUpdateButtonDisabled = false; 
    isUpdateParticularsButtonVisible = true;
    isShowParticulars = false;
    // Set default TIMELINE for all Particulars
    defaultParticularTimeline = '2026-11-30'; 
    //+++++++++++++++++++++++++++++++++++++++++++++++++++

    @track summitParticulars = [];
    @track summitParticularsMonthWise = [];
    selectedParticularObj;
    summitParticularsFlag = false;
    // New implementation
    @track particulars = [];
    @track savedParticulars = [];
    @track showSavedTablePartcular = false;

    rowId = 0;
    isNAParticularCreated = false;
    createParticular = false;

    connectedCallback() {
        if (this.buttonLabel == 'Create Particulars') {
        //    this.getSummitParticularsMetadata();
            this.isEnterMonthlyButtonDisabled = true; // disable 'Enter Monthly' button
            this.createParticular = true;
            // this.summitParticulars = [];
            
        } else if (this.buttonLabel == 'Update Particulars') {                                    
            this.isUpdateButtonDisabled = false;
            this.isUpdateParticularsButtonVisible = false;
            this.getAllSummitParticulars();
            // Monthwise Particulars
            this.getMonthWiseSummitParticulars();
            this.summitParticularsFlag = true;
        }
        this.getMonthWiseData();
        console.log('Selected Section Id :'+this.summitSectionId);
    }

    getSummitParticularsMetadata() {
        getSummitParticularsMetadata({ summitSectionLabel: this.summitSectionLabel, keyCount: this.keyCount })
            .then(result => {
                let sNo = 0;
                this.summitParticulars = result.map(summitParticular => {
                    sNo++;
                    let timeline = (summitParticular.MasterLabel.endsWith('Odd') ||
                        summitParticular.MasterLabel.endsWith('OS') ||
                        summitParticular.MasterLabel.endsWith('Odd Sem')) ?
                        this.semesterTwoTimeline :
                        this.semesterOneTimeline;
                    return {
                        id: sNo,
                        summitParticularName: summitParticular.MasterLabel,
                        timeline : this.defaultParticularTimeline,
                        target: 0,
                        targetText: '',
                        isTargetApplicable: true, // set default value
                        isEvidenceApplicable: true,  // set default value
                    };
                    
                }
                );
            })
            .catch(error => {
                console.error('Error when fetching summit particular metadata ', error);
                this.showToastNotification('Error when fetching summit particular metadata ', error.body.message, 'error');
            });
    }
    getAllSummitParticulars() {
        console.log('this.summitSectionId getAllSummitParticulars() : '+this.summitSectionId);
        getAllSummitParticulars({ summitSectionId: this.summitSectionId, keyCount: this.keyCount })
            .then(result => {                             
                let sNo = 0;
                this.summitParticulars = [];
                this.summitParticulars = result.map(summitParticular => {
                    sNo++;                                      
                    
                    return {
                        id: sNo,
                        summitParticularName: summitParticular.Name,
                        timeline: summitParticular.smt_Timeline__c || new Date(),
                        target: summitParticular.smt_Target__c,
                        targetText: summitParticular.smt_Target_Text__c,
                        isTargetApplicable: summitParticular.smt_Is_Target_Applicable__c,
                        isEvidenceApplicable: summitParticular.smt_Is_Evidence_Applicable__c,
                        summitParticularId: summitParticular.Id,
                    };

                });
                this.isShowParticulars = this.summitParticulars.length > 0 ? true : false;           
            })
            .catch(error => {
                console.error('Error when fetching summit particular records ', error);
                this.showToastNotification('Error when fetching summit particular records ', error.body.message, 'error');
            });
    }

    // ******************** MONTH WISE *************************

    getMonthWiseSummitParticulars() {        
        getMonthWiseSummitParticulars({ summitSectionId: this.summitSectionId})
            .then(result => {               
                //  let sNo = 0;
                this.summitParticularsMonthWise = [];
                this.summitParticularsMonthWise = result.map(summitParticular => {
                  //  sNo++;                     
                    return {
                        id: summitParticular.Id,
                        summitParticularName: summitParticular.Name,
                        summitSectionId: summitParticular.smt_Summit_Section__c,
                        summitSectionName: summitParticular.smt_Summit_Section__r.Name,
                        monthData:summitParticular.Summit_Particular_Months__r                                              
                    };
                });  
            })
            .catch(error => {             
                console.error('Error when fetching summit particular records ', error);
                this.showToastNotification('Error when fetching summit particular records ', error.body.message, 'error');
            });            
    }

    // *********************************************
    handleParticularChange(event) {
        const id = event.target.dataset.id;
        const label = event.target.dataset.label;
        let value = event.target.value;
        if (label == 'isTargetApplicable' || label == 'isEvidenceApplicable') {
           //  value = event.target.checked;
           value = true;
        }
        const changedSummitParticular = this.summitParticulars.find(summitParticular => summitParticular.id == id);
        if (changedSummitParticular) {
            changedSummitParticular[label] = value;
        }
    }
    handleCreateOrUpdateParticulars(event) {
        if (event.target.dataset.label === 'Create Particulars') {
            this.handleCreateParticulars();
        } else if (event.target.dataset.label === 'Update Particulars') {
            this.handleUpdateParticulars();
        }
    }
    handleUpdateParticulars() {
         if (!this.summitSectionId) {
            this.showToastNotification('No Summit Section Id Available So We Can\'t Proceed Creating Particulars', '', 'info');
            return;
         }
        this.isSpinner = true;
        updateAllSummitParticular({jsonData: JSON.stringify(this.summitParticulars)})
            .then(result => {
                this.showToastNotification('Summit Particular Saved Successfully', '', 'success');
                this.isSpinner = false;
            }).catch(error => {
                console.error('Error when updating summit particulars ' + JSON.stringify(error));
                this.showToastNotification('Error when updating summit particulars', error.body.message, 'error');
                this.isSpinner = false;
        })
        
    }
    handleCreateParticulars() {        
        if (!this.summitSectionId) {
            this.showToastNotification('No Summit Section Id Available So We Can\'t Proceed Creating Particulars', '', 'info');
            return;
        }        
        // console.log('Data Inside createSummitParticular :'+JSON.stringify(this.summitParticulars));
        this.isSpinner = true;
       // createSummitParticular({ jsonData: JSON.stringify(this.summitParticulars), summitSectionId: this.summitSectionId })
       createSummitParticular({ jsonData: JSON.stringify(this.savedParticulars), summitSectionId: this.summitSectionId })
            .then(result => {
                this.showToastNotification('Particulars Created Successfullyyy ', '', 'success');
                this.isSpinner = false;              
            }).catch(error => {
                console.error('Error when creating Particulars :: ' + error.body.message);
                this.showToastNotification('Error When Creating Particulars ::', error.body.message, 'error');
                this.isSpinner = false;
            })
    }

     showToastNotification(title, message,  variant) {
        const evt = new ShowToastEvent({
        title,message,variant
        });
        this.dispatchEvent(evt);
     }
    
    handleBackClick(event) {
        this.dispatchEvent(new CustomEvent('clickback'));
    }

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    isModalOpen = false;
    // Method to open the modal
    openModal() {
        this.isModalOpen = true;             
    }  

    monthModel(event){        
        this.isModalOpen = true; 
        const id = event.target.dataset.id;        
        this.summitParticularId = event.target.dataset.id;        
        this.changedSummitParticular = this.summitParticulars.find(summitParticular => summitParticular.summitParticularId == id);          
        this.selectedParticularObj = this.summitParticularsMonthWise.find(summitParticular => summitParticular.id == id)
        console.log('Section Id :'+this.summitSectionId);
        console.log('Particular Id :'+this.summitParticularId);

        if(this.selectedParticularObj.monthData != null){
            // update modal button to Update
            this.modalButtonLabel = 'Update Particulars';            
            const monthDataArraySelectedParticular = this.selectedParticularObj.monthData;

            this.monthsDataVal.forEach(month => {                
                const serverItem = monthDataArraySelectedParticular.find(item => item.Name === month.Name);
                // If a matching server response is found, update the localArray's fields
                if (serverItem) {
                    month.Id = serverItem.Id;
                    month.target = serverItem.smt_Target__c;
                    month.targetText = serverItem.smt_Target_Text__c;
                    month.timeline = serverItem.smt_Timeline__c;
                    month.isTargetApplicable = serverItem.smt_Is_Target_Applicable__c;
                    month.isEvidenceApplicable = serverItem.smt_Is_Evidence_Applicable__c;
                    month.summitParticularId = serverItem.Summit_Particular__c; 
                    month.commentText = serverItem.smt_Comments__c;                               
                }else{
                    month.target = "0";
                    month.targetText = null;
                    month.timeline = null;
                    month.isTargetApplicable = true;
                    month.isEvidenceApplicable = true;
                    month.summitParticularId = serverItem.Summit_Particular__c;
                    month.commentText = null; 
                }

            });
        }else{
            this.modalButtonLabel = 'Create Particulars';            
            this.monthsDataVal = [];
            this.getMonthWiseData();
        }      
    }

    // Month wise particulars button click handling
    handleCreateOrUpdateMonthWiseParticulars(event) {
        if (event.target.dataset.label === 'Create Particulars') {
            this.handleCreateMonthlyParticulars();
        } else if (event.target.dataset.label === 'Update Particulars') {
            this.handleUpdateMonthlyParticulars();         
        }
    }

    // Create a list of Month Array with default values
    getMonthWiseData(){
        const monthArray = [
            "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November"
        ];
        
        // Get the current year dynamically
    const currentYear = new Date().getFullYear();

    // Set a default date for each month (the 25th day of the current year for each month)
    const monthDates = {
        "January": `${currentYear}-01-25`,
        "February": `${currentYear}-02-25`,
        "March": `${currentYear}-03-25`,
        "April": `${currentYear}-04-25`,
        "May": `${currentYear}-05-25`,
        "June": `${currentYear}-06-25`,
        "July": `${currentYear}-07-25`,
        "August": `${currentYear}-08-25`,
        "September": `${currentYear}-09-25`,
        "October": `${currentYear}-10-25`,
        "November": `${currentYear}-11-25`
    };
        
        monthArray.forEach(month => {
            this.monthsDataVal.push({
                            "Id" : null,
                            "Name" : month,
                            "timeline" : monthDates[month],
                            "target" : '0',
                            "targetText" : null,
                            "isTargetApplicable" : true,
                            "isEvidenceApplicable" : true,
                            "summitParticularId" : this.summitParticularId,
                            "summitSectionId" : this.summitSectionId,
                            "commentText" : null                           
                });
        });
    }
    // Method to close the modal
    closeModal() {
        this.isModalOpen = false;
    }

    handleCreateMonthlyParticulars() {
        if (!this.summitSectionId) {
            this.showToastNotification('No Summit Section Id Available So We Can\'t Proceed Creating Particulars', '', 'info');
          //  return;
        }
        else {
            // Validate Monthly particulars data  
            let monthData = this.monthsDataVal.find(month => month.timeline == null);
            if(monthData){
                this.showToastNotification('Value Required', 'Please Enter All Timelines', 'error');            
             //   return;
            }else{
                this.isSpinner = true;
                createSummitParticularMonthly({ jsonData: JSON.stringify(this.monthsDataVal), summitSectionId: this.summitSectionId, summitParticularId: this.summitParticularId })
                .then(result => {
                    this.showToastNotification('Particulars Created Successfully ', '', 'success');
                    this.isSpinner = false;
                }).catch(error => {
                    console.error('Error when creating Particulars Monthly' + error.body.message);
                    this.showToastNotification('Error When Creating Particulars', error.body.message, 'error');
                    this.isSpinner = false;
                })                
                this.closeModal();
            }    
        }
    }

    validateMonthInputs(){
        let monthData = this.monthsDataVal.find(month => month.timeline == null);
        if(monthData){
            this.showToastNotification('Value Required', 'Please Enter All Timelines', 'error');            
            return;
        }
    }

    handleUpdateMonthlyParticulars() {
         if (!this.summitSectionId) {
            this.showToastNotification('No Summit Section Id Available So We Can\'t Proceed Creating Particulars', '', 'info');
            return;
         }
       this.isSpinner = true;
       console.log('summitSectionId : '+this.summitSectionId);
       console.log('summitParticularId : '+this.summitParticularId);
       console.log('Before Update monthsDataVal : '+ JSON.stringify(this.monthsDataVal));
        updateAllSummitParticularMonthly({jsonData: JSON.stringify(this.monthsDataVal), summitSectionId: this.summitSectionId, summitParticularId: this.summitParticularId })
            .then(result => {
                this.showToastNotification('Summit Particular Saved Successfully', '', 'success');
                this.isSpinner = false;        
                this.getAllSummitParticulars();
                this.getMonthWiseSummitParticulars();
             
                 this.getMonthWiseData();
                 this.dispatchEvent(new CustomEvent('clickback'));             
            }).catch(error => {
                console.error('Error when updating monthly summit particulars ' + JSON.stringify(error));
                this.showToastNotification('Error when updating monthly summit particulars', error.body.message, 'error');
                this.isSpinner = false;             
        })        
         this.closeModal();        
    }

    handleMonthlyParticularChange(event) {
        const field = event.target.dataset.label;
        const rowId = event.target.dataset.id;
        const value = event.target.type === "checkbox" ? event.target.checked : event.target.value;

        this.monthsDataVal = this.monthsDataVal.map((month) =>
            (month.Name === rowId ? { ...month, [field]: value } : month)
        );
        console.log('Input Array :'+JSON.stringify(this.monthsDataVal));

        let inputTag = event.target;
        // let sNo = event.target.dataset.sno;
        let fieldName = event.target.dataset.field;
        if (fieldName == 'targetValue' && isNaN(event.target.value)) {
            inputTag.setCustomValidity('Please enter a valid value');
        } else if (fieldName == 'targetValue' && !isNaN(event.target.value)) {
            inputTag.setCustomValidity('');
        }
        inputTag.reportValidity();
    }
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    /**************** New Implementation Particulars Creation ****************/

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
        let sNo = 0;
        // ✅ Store data as array of objects
        /*     this.savedParticulars = this.particulars.map(row => ({            
                    name: row.name,
                    timeline: row.timeline,
                    target: row.target
                })); */

        this.savedParticulars = this.particulars.map(row => ({
                        id: sNo,
                        summitParticularName: row.name,
                        timeline : this.defaultParticularTimeline,
                        target: 0,
                        targetText: '',
                        isTargetApplicable: true, // set default value
                        isEvidenceApplicable: true,  // set default value
        }));

        this.showToast(
            'Success',
            'Particulars created successfully!',
            'success'
        );

        // Optional: clear input table
        // this.particulars = [];
        this.showSavedTablePartcular = false;
        this.createParticular = false;
        this.handleCreateParticulars();
        this.dispatchEvent(new CustomEvent('clickback'));
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
        this.isNAParticularCreated = true;
    }



}