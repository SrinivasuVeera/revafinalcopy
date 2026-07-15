import { LightningElement,track,wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import REVA_LOGO_IMAGE from "@salesforce/resourceUrl/REVA_LOGO";
import examNotification from "@salesforce/apex/Reva_ExamApplication_Ctrl.getExamNotificationDetails";
import examApplicationEligibility from "@salesforce/apex/Reva_ExamApplication_Ctrl.examApplicationEligibility";
import getExamDetails from "@salesforce/apex/Reva_ExamApplication_Ctrl.getExamDetails";
export default class RevaNotification extends LightningElement {
     REVA_LOGO = REVA_LOGO_IMAGE;
     fillapplication = false;
     showNotification = true;
     @track notification = {
          Rve_Semester__r : ''
     };
     showLoader = true;
     notificationId;
     isNotEligible = true;
     wireNotificationDataRef;
     _wiredApplicationData;
     _wiredgetFeeDetailsData;
     examMonthYear = '';
     examPeriod = '';
     penaltyStartDate = '';
     penaltyEndDate = '';
     @track feeDetails = {
          ApplicationFee : 0,
          ArreasFee : 0
     };
     showNotificationPage = false;

     @wire(examNotification)
     wireNotificationData(result) {
          this.wireNotificationDataRef = result;
          const { data, error } = result;
          if (data && data.length > 0) {
               console.log('data : ',data);
               this.notification = data[0];
               this.notificationId = data[0].Id;
               const date = new Date(data[0].Rve_Start_Date__c);  // 2023-11-10
               // Date.getYear() returns a value that is the result of subtracting 1900 from the year that contains.
               this.examMonthYear = date.toLocaleString('default', { month: 'long' }) +' '+ (parseFloat(date.getYear())+1900);
               this.examPeriod = (parseFloat(date.getYear())+1900-1) +'-'+ (parseFloat(date.getYear())+1900) // If date is 2023-11-10 then period will be 2022-2023
               const endDate = new Date(data[0].Rve_End_Date__c);
               this.penaltyStartDate = this.addDays(endDate,1);
               this.penaltyEndDate = this.addDays(endDate,2);
               console.log('endDate : ',endDate);
               this.showNotificationPage = true;
          } else if (error) {
               console.error(error);
          }
          else {
               this.showNotificationPage = false;
          }
          this.showLoader = false;
     }

     @wire(getExamDetails)
     wiregetFeeDetailsData(result) {
          this._wiredgetFeeDetailsData = result;
          const { data, error } = result;
          if (data) {
               console.log('getFeeDetails : ',data);
               let contactDetails = data.contactDetails;
               let examFeeType = (contactDetails != undefined && contactDetails.Primary_Academic_Program__r && contactDetails.Primary_Academic_Program__r.Program_Type__c) ? (contactDetails.Primary_Academic_Program__r.Program_Type__c == 'PG' ? 'PG_Exam_Fee' : (contactDetails.Primary_Academic_Program__r.Program_Type__c == 'UG' ? 'UG_Exam_Fee' : '')) : '';
               const examFeeObj = data.feeDetails.find(obj => obj.DeveloperName == examFeeType);
               const ArreasFeeObj = data.feeDetails.find(obj => obj.DeveloperName == 'Backlog_Fee');
               this.feeDetails.ApplicationFee = examFeeObj != undefined && examFeeObj.Amount__c != undefined ? parseFloat(examFeeObj.Amount__c) : 0;
               this.feeDetails.ArreasFee = ArreasFeeObj != undefined && ArreasFeeObj.Amount__c != undefined ? parseFloat(ArreasFeeObj.Amount__c) : 0;
          }
          else if(error){
               console.error(error);
          }
     }

     @wire(examApplicationEligibility)
     wireNexamApplicationEligibilityData(result) {
          this._wiredApplicationData = result;
          const { data, error } = result;
          if (error) {
               console.error(error);
          }
          else {
               this.isNotEligible = data;
               console.log('isNotEligible : ',this.isNotEligible);
          }
     }

     connectedCallback(){
          console.log('connectedCallback called');
          this.refreshApexData();
     }

     addDays(oldDate, days){
          var date = new Date(oldDate);
          date.setDate(date.getDate() + days);
          return date;
     }

     refreshApexData(){
          console.log('refreshApexData called');
          // refreshApex(this.wireNotificationDataRef);
          return refreshApex(this._wiredApplicationData);
     }
     
     handleClick(){
          this.fillapplication  = true;
          this.showNotification = false;
     }
     
     hideApplicationForm(){
          this.refreshApexData();
          this.fillapplication  = false;
          this.showNotification = true;
     }
     
}