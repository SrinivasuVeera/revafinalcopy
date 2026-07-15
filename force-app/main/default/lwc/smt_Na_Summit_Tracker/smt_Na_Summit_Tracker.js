import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from '@salesforce/apex';
import { CloseActionScreenEvent } from "lightning/actions";
import { loadStyle } from "lightning/platformResourceLoader";
import getSummitTracker from '@salesforce/apex/smt_Summit_Tracker_Controller.getSummitTracker';
import getSummitSectionRecords from '@salesforce/apex/smt_Summit_Tracker_Controller.getSummitSectionRecords';
import modal from "@salesforce/resourceUrl/custommodalcss";


export default class Smt_Na_Summit_Tracker extends LightningElement {
   @api recordId;
   showSummitTracker;
   showSections;
   showUnAvailabilityOfSummitTracker;
   summitTrackerId;
   semester;
   summitSectionRecords;
   summitSectionId;
   wiredSummitSectionData;
   wiredSummitTrackerData;
   summitTrackers;
   isSpinner;
   sectionName;
   summitTypeAcademic = false;

   connectedCallback() {
    loadStyle(this, modal);
   }
   closeAction() {
      this.dispatchEvent(new CloseActionScreenEvent());
   }

   @wire(getSummitTracker, {
      schoolId: '$recordId'
   })
   getSummitTracker(result) {

      this.wiredSummitTrackerData = result;
      if (result.data) {

         if (result.data.length == 0) {
            this.showUnAvailabilityOfSummitTracker = true;
            return;
         }
         this.summitTrackers = result.data.map(summitTracker => {
            let weightageAchieved = summitTracker.smt_Total_Weightage_Achieved__c || 0;

            let badgeStyle = weightageAchieved > 90 ? 'background: #8bda56;min-width: 40%; max-width:60%;display: flex; justify-content: center; color: black;' :
               weightageAchieved > 70 ? 'background: #ffa750;min-width: 40%; max-width:60%;display: flex; justify-content: center; color: black;' :
               'background: #ff5050;min-width: 40%; max-width:60%;display: flex; justify-content: center; color: white;'

            weightageAchieved += ' %';

            return {
               ...summitTracker,
               badgeStyle,
               weightageAchieved
            }
         });

         if (!this.showSummitTracker) {
            this.showSummitTracker = true;
         }

      } else if (result.error) {

         console.error('Error when fetching summit trackers ' + result.error);
         this.showToastNotification('Error when fetching summit trackers', result.error.body.message, 'error');
      }
   }
   handleGetSections(event) {
      this.summitTrackerId = event.target.dataset.id;
      this.showSections = true;
      this.showSummitTracker = false;
   }

   @wire(getSummitSectionRecords, {
      summitTrackerId: '$summitTrackerId'
   })
   getSummitSectionRecords(result) {
      this.isSpinner = false;
      this.wiredSummitSectionData = result;
      if (result.data) {
         this.isSpinner = false;
         this.summitSectionRecords = result.data.map(summitSection => {
            let isOddandEvenSeparated = summitSection.Name == 'Academics' || summitSection.Name == 'Feedback From Stakeholders' || summitSection.Name == 'SLCM';
            let weightage = summitSection.smt_Weightage__c ? summitSection.smt_Weightage__c + ' %' : '0 %';
            let percentageCompleted = summitSection.smt_Target_Achieved_With_Weightage__c || 0;
            let actualPercentageCompleted = (percentageCompleted / (summitSection.smt_Weightage__c || 0)) * 100;
            let badgeStyle = actualPercentageCompleted > 90 ? 'background: #8bda56;min-width: 40%; max-width:60%;display: flex; justify-content: center; color: black;' :
               actualPercentageCompleted > 70 ? 'background: #ffa750;min-width: 40%; max-width:60%;display: flex; justify-content: center; color: black;' :
               'background: #ff5050;min-width: 40%; max-width:60%;display: flex; justify-content: center; color: white;'
            percentageCompleted += ' %';
            return {
               ...summitSection,
               badgeStyle,
               percentageCompleted,
               weightage,
               isOddandEvenSeparated
            }
         });
         this.showSections = true;
         this.showSummitTracker = false;
      } else if (result.error) {
         this.isSpinner = false;
         console.error(result.error);
         this.showToastNotification('Error Occured When Fetching Sections', result.error.body.message, 'error');
      }
   }
   handleBackClick() {
      this.showSections = false;
      this.showSummitTracker = true;
      return refreshApex(this.wiredSummitTrackerData);
   }
   showToastNotification(title, message, variant) {
      const evt = new ShowToastEvent({
         title,
         message,
         variant
      });
      this.dispatchEvent(evt);
   }

   handleGetParticulars(event) {
      this.semester = event.target.dataset.semester;
      this.summitSectionId = event.target.dataset.id;
      this.sectionName = event.target.dataset.sectionname;
      
      this.showParticulars = true;
      this.showSections = false;

   }

   handleClickBackFromParticulars() {
      this.showParticulars = false;
      this.showSections = true;
      return refreshApex(this.wiredSummitSectionData);
   }

}