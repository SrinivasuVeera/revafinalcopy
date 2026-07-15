import { LightningElement,api, track, wire} from 'lwc';
import Id from '@salesforce/user/Id';

//1. Import the method "createRecord" which is a named import
import { createRecord } from "lightning/uiRecordApi";

//2. Import the reference to Object and Fields
import EXAM_APPLICATION_OBJECT from "@salesforce/schema/Rve_Exam_Application__c";

import getExamDetails from "@salesforce/apex/Reva_ExamApplication_Ctrl.getExamDetails";
import insertRecords from "@salesforce/apex/Reva_ExamApplication_Ctrl.insertRecords";
export default class RevaExamApplication extends LightningElement {
    @api notificationId;
    
    @track courses = [];
    @track backlogs = [];
    @track feeMetaData = [];
    @track feeDetails = [];
    @track currentContactDetails = {};
    backlogFee = 1;
    totalAmount = 0;
    showLoader = true;
    alertMsg = '';
    showAlertMsg = false;

    readyForPayment = false;

    connectedCallback(){
        this.showLoader = true;
        getExamDetails()
        .then(result => {
            console.log('result wrap : ',result);
            this.feeMetaData = result.feeDetails;

            let count = 1;
            this.courses = result.courses;
            this.courses = this.courses.map(item => {
                return {... item, selected : true, readonly : true, SN: count++}
            })
            
            count = 1;
            this.backlogs = result.backlogs;
            this.backlogs = this.backlogs.map(item => {
                return {... item, selected : false, readonly : false, SN: count++}
            })

            // Fee Details
            this.currentContactDetails = result.contactDetails;
            let contactDetails = result.contactDetails;
            let examFeeType = (contactDetails != undefined && contactDetails.Primary_Academic_Program__r && contactDetails.Primary_Academic_Program__r.Program_Type__c) ? (contactDetails.Primary_Academic_Program__r.Program_Type__c == 'PG' ? 'PG_Exam_Fee' : (contactDetails.Primary_Academic_Program__r.Program_Type__c == 'UG' ? 'UG_Exam_Fee' : '')) : '';
            const convFeeObj = result.feeDetails.find(obj => obj.DeveloperName == 'Convocation_Fee');
            const examFeeObj = result.feeDetails.find(obj => obj.DeveloperName == examFeeType);
            console.log('ExamFeeObj=> '+examFeeObj);
            const examFeeAmount = examFeeObj != undefined && examFeeObj.Amount__c != undefined ? parseFloat(examFeeObj.Amount__c) : 0;
            const convFeeAmount = convFeeObj != undefined && convFeeObj.Amount__c != undefined ? parseFloat(convFeeObj.Amount__c) : 0;
            
            this.feeDetails.push({SN: 1, FeeHead : 'Exam Fee', Amount : examFeeAmount});
            this.feeDetails.push({SN: 2, FeeHead : 'Backlog Fee', Amount : 0});
            if(result.isFinalYearStudent){
                this.feeDetails.push({SN: 3, FeeHead : 'Convocation Fee', Amount : convFeeAmount});
            }
            const backlogFeeObj = result.feeDetails.find(obj => obj.DeveloperName == 'Backlog_Fee');
            this.backlogFee     = backlogFeeObj.Amount__c;
            this.getTotalAmount();
            this.showLoader = false;
        })
        .catch(error => {
            console.log('error : ',error);
            this.showLoader = false;
        })
    }

    getTotalAmount(){
        this.totalAmount = this.feeDetails.reduce((accumulator, object) => {
            return accumulator + object.Amount;
        }, 0);
    }

    handleSelect(event){
        this.showLoader = true;
        let chacked = event.target.checked;
        let selectedId = event.currentTarget.dataset.id;
        console.log('chacked : ',chacked);
        console.log('selectedId : ',selectedId);
        this.backlogs = this.backlogs.map(item => {
            if(item.Id == selectedId){
                return {... item, selected : chacked}
            }
            return {... item}
        })

        
        const selectedBacklogs = this.backlogs.filter(obj => obj.selected == true);
        const backlogFeeAmount = parseFloat(this.backlogFee) * parseFloat(selectedBacklogs.length);
        this.feeDetails = this.feeDetails.map(item => {
            if(item.SN == 2){
                return {... item, Amount : backlogFeeAmount};
            }
            return {... item};
        })

        this.getTotalAmount();
        this.showLoader = false;

        console.log('this.feeDetails : ',this.feeDetails);
    }

    handleCancel(){
        this.dispatchEvent(new CustomEvent("cancel"));
    }

    handleApply(){
        this.showLoader = true;
        let examApplicationObj = {};
        // console.log('this.currentContactDetails.Active_Semester__r.Name : ',this.currentContactDetails.Active_Semester__r.Name);
        // console.log('this.currentContactDetails.Name : ',this.currentContactDetails.Name);
        examApplicationObj.Name = this.currentContactDetails.Active_Semester__r.Name +'-'+ this.currentContactDetails.Name; //Semester + Student
        examApplicationObj.Rve_Amount__c = this.totalAmount;
        examApplicationObj.Rve_Applied_Date__c = new Date();
        examApplicationObj.Rve_Exam_Notification__c = this.notificationId;
        examApplicationObj.Rve_Status__c = 'Pending fees';
        examApplicationObj.Rve_Student__c = this.currentContactDetails.Id;
        examApplicationObj.Rve_Registration_Number__c = this.currentContactDetails?.SRN_Number__c;
        examApplicationObj.Rve_Application_Number__c = this.currentContactDetails?.Application_Number__c;

        let lineItemObjs = [];
        this.courses.forEach(course => {
            let obj = {};
            // obj.Rve_Exam_Application__c = result.id;
            obj.Rve_Subject__c  = course.hed__Course_Offering__r.hed__Course__r.Name;
            obj.Rve_Semester__c = this.currentContactDetails.Active_Semester__r.Name;
            obj.Course_Code__c  = course.hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c;
            
            lineItemObjs.push(obj);
        })

        this.backlogs.forEach(backlog => {
            if(backlog.selected == true){
                let obj = {};
                // obj.Rve_Exam_Application__c = result.id;
                obj.Rve_Subject__c  = backlog.hed__Course_Offering__r.hed__Course__r.Name;
                obj.Rve_Semester__c = this.currentContactDetails.Active_Semester__r.Name;
                obj.Course_Code__c  = backlog.hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c;
                
                lineItemObjs.push(obj);
            }
        })

        insertRecords({examApplication :examApplicationObj, lineItemObjs :lineItemObjs})
        .then(response => {
            console.log('response : ',response);
            this.alertMsg = response ? 'Exam Application has been Created Successfully. Click OK to Complete Payment' : 'Failed, Try Again.'; 
            this.showAlertMsg = true;
            this.showLoader = false;
            this.readyForPayment = response;
        })
        .catch(error => {
            console.log('error : ',error);
            this.showLoader = false;
        })        
    }

    handleOkay(){
        this.showAlertMsg = false;
    }
}