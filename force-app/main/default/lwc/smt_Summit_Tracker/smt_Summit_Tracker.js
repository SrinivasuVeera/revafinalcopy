import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from '@salesforce/apex';
import { CloseActionScreenEvent } from "lightning/actions";
import { loadStyle } from "lightning/platformResourceLoader";
import getSummitTracker from '@salesforce/apex/smt_Summit_Tracker_Controller.getSummitTracker';
import getSummitSectionRecords from '@salesforce/apex/smt_Summit_Tracker_Controller.getSummitSectionRecords';
import modal from "@salesforce/resourceUrl/custommodalcss";


export default class Smt_Summit_Tracker extends LightningElement {
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
   summitTypeAcademic = true;

   categoryMap = {
      S1: 'Admissions, Academics and Digital Initiative',
      S2: 'Research, Innovation and Development',
      S3: 'Student Development, Industry and Alumni Engagement',
      S4: 'Resource Advancement',
      S5: 'Best Practices',
      S6: 'Infrastructure and Support Facilities'
   };

   orderedPrefixes = ['S1', 'S2', 'S3', 'S4', 'S5', 'S6'];

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

   // @wire(getSummitSectionRecords, {
   //    summitTrackerId: '$summitTrackerId'
   // })
   // getSummitSectionRecords(result) {
   //    this.isSpinner = false;
   //    this.wiredSummitSectionData = result;
   //    if (result.data) {
   //       this.isSpinner = false;
   //       this.summitSectionRecords = result.data.map(summitSection => {
   //          let isOddandEvenSeparated = summitSection.Name == 'Academics' || summitSection.Name == 'Feedback From Stakeholders' || summitSection.Name == 'SLCM';
   //          let weightage = summitSection.smt_Weightage__c ? summitSection.smt_Weightage__c + ' %' : '0 %';
   //          let percentageCompleted = summitSection.smt_Target_Achieved_With_Weightage__c || 0;
   //          let actualPercentageCompleted = (percentageCompleted / (summitSection.smt_Weightage__c || 0)) * 100;
   //          let badgeStyle = actualPercentageCompleted > 90 ? 'background: #8bda56;min-width: 40%; max-width:60%;display: flex; justify-content: center; color: black;' :
   //             actualPercentageCompleted > 70 ? 'background: #ffa750;min-width: 40%; max-width:60%;display: flex; justify-content: center; color: black;' :
   //             'background: #ff5050;min-width: 40%; max-width:60%;display: flex; justify-content: center; color: white;'
   //          percentageCompleted += ' %';
   //          return {
   //             ...summitSection,
   //             badgeStyle,
   //             percentageCompleted,
   //             weightage,
   //             isOddandEvenSeparated
   //          }
   //       });
   //       this.showSections = true;
   //       this.showSummitTracker = false;
   //    } else if (result.error) {
   //       this.isSpinner = false;
   //       console.error(result.error);
   //       this.showToastNotification('Error Occured When Fetching Sections', result.error.body.message, 'error');
   //    }
   // }

      @wire(getSummitSectionRecords, {
      summitTrackerId: '$summitTrackerId'
      })
   getSummitSectionRecords(result) {
      this.isSpinner = false;
      this.wiredSummitSectionData = result;

      if (result.data) {
         const grouped = {};

         // 1️⃣ First map your existing logic
         // eslint-disable-next-line no-unused-vars
         const processedRecords = result.data.map(summitSection => {

            let isOddandEvenSeparated =
               summitSection.Name === 'Academics' ||
               summitSection.Name === 'Feedback From Stakeholders' ||
               summitSection.Name === 'SLCM';

            let weightage = summitSection.smt_Weightage__c
               ? summitSection.smt_Weightage__c + ' %'
               : '0 %';

            let percentageCompleted =
               summitSection.smt_Target_Achieved_With_Weightage__c || 0;

            let actualPercentageCompleted =
               (percentageCompleted / (summitSection.smt_Weightage__c || 1)) * 100;

            let badgeStyle =
               actualPercentageCompleted > 90
                  ? 'background:#8bda56;min-width:40%;max-width:60%;display:flex;justify-content:center;color:black;'
                  : actualPercentageCompleted > 70
                     ? 'background:#ffa750;min-width:40%;max-width:60%;display:flex;justify-content:center;color:black;'
                     : 'background:#ff5050;min-width:40%;max-width:60%;display:flex;justify-content:center;color:white;';

            percentageCompleted += ' %';

            // 🔹 Extract Prefix (S1, S2, etc.)
            const prefix = summitSection.Name?.includes('_')
               ? summitSection.Name.split('_')[0]
               : 'Other';

            const category = this.categoryMap[prefix] || 'Other';

            const updatedRecord = {
               ...summitSection,
               badgeStyle,
               percentageCompleted,
               weightage,
               isOddandEvenSeparated,
               categoryName: category
            };

            if (!grouped[category]) {
               grouped[category] = [];
            }

            grouped[category].push(updatedRecord);

            return updatedRecord;
         });

         // 2️⃣ Enforce Strict S1 → S6 Order
         const finalData = [];

         this.orderedPrefixes.forEach(prefix => {
            const category = this.categoryMap[prefix];

             if (grouped[category]) {

               grouped[category].forEach((record, index) => {

                  const isFirst = index === 0;
                  const isLast = index === grouped[category].length - 1;

                  finalData.push({
                     ...record,
                     showCategory: isFirst,
                     rowSpan: isFirst ? grouped[category].length : 0,
                     rowClass: isLast
                        ? 'slds-border_bottom slds-border_bottom_thick'
                        : ''
                  });

               });
            }
         });

         // 3️⃣ Add Other at End
         // eslint-disable-next-line dot-notation
         if (grouped['Other']) {

            // eslint-disable-next-line dot-notation
            grouped['Other'].forEach((record, index) => {

               const isFirst = index === 0;
               // eslint-disable-next-line dot-notation
               const isLast = index === grouped['Other'].length - 1;

               finalData.push({
                  ...record,
                  showCategory: isFirst,
                  // eslint-disable-next-line dot-notation
                  rowSpan: isFirst ? grouped['Other'].length : 0,
                  rowClass: isLast
                     ? 'slds-border_bottom slds-border_bottom_thick'
                     : ''
               });

            });
         }

         this.summitSectionRecords = finalData;

         this.showSections = true;
         this.showSummitTracker = false;

      } else if (result.error) {
         this.isSpinner = false;
         console.error(result.error);
         this.showToastNotification(
            'Error Occured When Fetching Sections',
            result.error.body.message,
            'error'
         );
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