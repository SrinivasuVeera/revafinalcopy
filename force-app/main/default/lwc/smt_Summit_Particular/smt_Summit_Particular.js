import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getSummitParticulars from '@salesforce/apex/smt_Summit_Tracker_Controller.getSummitParticulars';
import updateSummitParticular from '@salesforce/apex/smt_Summit_Tracker_Controller.updateSummitParticular';


export default class Smt_Summit_Particular extends LightningElement {

   @api summitSectionId;
   @api semester;
   @track summitParticulars = [];
   @api sectionName;
   showParticulars;
   showNoParticularsMessage;
   wiredData;
   isSpinner;
// *******************************
   showMonthParticulars = false;
   summitParticularId;   
   summitParticularName;
// *******************************

   @wire(getSummitParticulars, {
      summitSectionId: '$summitSectionId',
      semester : '$semester'
   })
   getSummitParticulars(result) {
      this.wiredData = result;
      console.log('Smt_Summit_Particular Section Id:' + this.summitSectionId);
      console.log('Smt_Summit_Particular Semester :', this.semester);
      if (result.data) {
         this.isSpinner = false;
         if (result.data.length == 0) {
            this.showNoParticularsMessage = true;
            return;
         }
         this.showParticulars = true;
         let sNo = 0;
         let currentDate = new Date();
         this.summitParticulars = result.data.map(summitParticular => {
            sNo++;
            console.log('Summit Particular Id :'+summitParticular.Id);
            let timeLine = summitParticular.smt_Timeline__c || '';
            let dueDate = summitParticular.smt_Timeline__c ? new Date(summitParticular.smt_Timeline__c) : '';
            dueDate = dueDate ? dueDate.setDate(dueDate.getDate() + 1) : '';
            
            let isSaveButtonDisabled = !dueDate ? false : dueDate <= currentDate;
            let isAchievedInputDisabled = !summitParticular.smt_Is_Target_Applicable__c;
            let isEvidenceInputDisabled = !summitParticular.smt_Is_Evidence_Applicable__c;

            let achievedValue = !summitParticular.smt_Is_Target_Applicable__c ? 'N/A' :
               summitParticular.smt_Achieved__c ? summitParticular.smt_Achieved__c : '';

            let evidenceValue = !summitParticular.smt_Is_Evidence_Applicable__c ? 'N/A' :
               summitParticular.smt_Evidence_To_Be_Attached__c ? summitParticular.smt_Evidence_To_Be_Attached__c : '';

            let percentageAchieved = summitParticular.smt_Actual_Percentage_Achieved__c || 0;
            let badgeStyle = percentageAchieved > 90 ? 'background: #8bda56;min-width: 40%; max-width:60%;display: flex; justify-content: center; color: black;' :
               percentageAchieved > 70 ? 'background: #ffa750;min-width: 40%; max-width:60%;display: flex; justify-content: center; color: white;' :
               'background: #ff5050;min-width: 40%; max-width:60%;display: flex; justify-content: center; color: white;'
            percentageAchieved += ' %';
            let showUrl = summitParticular.smt_Is_Evidence_Applicable__c && evidenceValue != 'N/A' && evidenceValue;
            let summitParticularName = summitParticular.Name || '';
            // let target = !summitParticular.smt_Is_Target_Applicable__c ? 'N/A' : summitParticular.smt_Target_Text__c ? summitParticular.smt_Target_Text__c : '';
             let target = !summitParticular.smt_Is_Target_Applicable__c ? 'N/A' : summitParticular.smt_Target__c ? summitParticular.smt_Target__c : '';          
            
            return {
               id: summitParticular.Id,
               sNo,
               achievedValue,
               evidenceValue,
               badgeStyle,
               timeLine,
               summitParticularName,
               target,
               isEvidenceInputDisabled,
               isAchievedInputDisabled,
               percentageAchieved,
               isSaveButtonDisabled,
               showUrl,
               
            }
         })
      } else if (result.error) {
         console.error('Error when fetching summit particulars ' + result.error);
         this.showToastNotification('Error when fetching summit particulars', result.error.body.message, 'error');
      }
   }
    
   handleInputChange(event) {
      let inputTag = event.target;
      let sNo = event.target.dataset.sno;
      let fieldName = event.target.dataset.field;
      if (fieldName == 'achievedValue' && isNaN(event.target.value)) {
         inputTag.setCustomValidity('Please enter a valid value');
      } else if (fieldName == 'achievedValue' && !isNaN(event.target.value)) {
         inputTag.setCustomValidity('');
      }
      inputTag.reportValidity();
      let summitParticular = this.summitParticulars.find(summitParticular => summitParticular.sNo == sNo);
      if (summitParticular) {
         summitParticular[fieldName] = event.target.value;
      }
   }
    
   handleSaveParticular(event) {
      this.isSpinner = true;
      let sNo = event.target.dataset.sno;
      let summitParticular = this.summitParticulars.find(summitParticular => summitParticular.sNo == sNo);
      if (!summitParticular.isEvidenceInputDisabled && !summitParticular.evidenceValue) {
         this.showToastNotification('Value Required', 'Please enter Evidence before save', 'error');
         this.isSpinner = false;
         return;
      }
      if (!summitParticular.isAchievedInputDisabled && !summitParticular.achievedValue) {
         this.showToastNotification('Value Required', 'Please enter Achieved Value before save', 'error');
         this.isSpinner = false;
         return;
      }

      updateSummitParticular({
            jsonData: JSON.stringify(summitParticular)
         })
         .then(result => {
             this.isSpinner = false;
            this.showToastNotification('Summit Particular Saved Successfully', '', 'success');
            return refreshApex(this.wiredData);
         }).catch(error => {
            console.error('Error when saving summit particulars ' + JSON.stringify(error));
            this.showToastNotification('Error when saving summit particulars', error.body.message, 'error');
            this.isSpinner = false;

         })
   }

   handleBackClick() {
      this.dispatchEvent(new CustomEvent('clickback'));
   }
   showToastNotification(title, message, variant) {
      const evt = new ShowToastEvent({
         title,
         message,
         variant
      });
      this.dispatchEvent(evt);
   }

   // ********************************************************

   handleMonthParticular(event){
      this.showMonthParticulars = true;
      this.showParticulars = false;
      let sNo = event.target.dataset.sno;
      let summitParticular = this.summitParticulars.find(summitParticular1 => summitParticular1.sNo == sNo);
      this.summitParticularId = summitParticular.id;
      console.log('summitParticular obj :'+JSON.stringify(summitParticular.id));
      console.log('Selected summitParticularId  : '+this.summitParticularId);
      this.summitParticularName = summitParticular.summitParticularName;
      console.log('Selected summitParticularName  : '+this.summitParticularName);
   }

   handleClickBackFromParticularsMonth() {
      this.showMonthParticulars = false;
      this.showParticulars = true;
      return refreshApex(this.wiredData);
   }   
   
}