import { LightningElement, wire, api } from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
import CONTACT_ID from '@salesforce/schema/User.ContactId';
import USER_ID from '@salesforce/user/Id';
import COLOR_CODE_PERCENTAGE from '@salesforce/schema/Contact.Rpl_Color_Code_Percentage__c';
import ATTENDANCE_PERCENTAGE from '@salesforce/schema/Contact.Rpl_Training_Attendance_Percentage__c';
import ASSESSMENT_PERCENTAGE from '@salesforce/schema/Contact.Rpl_Training_Assessment_Percentage__c';
export default class Rpl_RevaTrainingModule extends LightningElement {
    contactId;
    wiredContact;
    isSpinner;
    colorCodePercentage;
    attendancePercentage;
    assesssmentPercentage;
    colorCodePercentageClass;
    attendancePercentageClass;
    assesssmentPercentageClass;
    isTrainingMaterial = true;
    isTrainingModule = true;
    isAttendance ;
    isAssessment;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [CONTACT_ID]
    })
    userec(result) {
        //this.isSpinner = true;
        console.log('Inside Contact Wire');
        this.wiredContact = result;
        if (result.error) {
            this.error =result.error;
            console.error('Error', result.error);
             this.isSpinner = false;
        } else if (result.data) {
            this.contactId = result.data.fields[CONTACT_ID.fieldApiName].value;           
        }
    }

    @wire(getRecord, {recordId: '$contactId', fields : [COLOR_CODE_PERCENTAGE, ATTENDANCE_PERCENTAGE, ASSESSMENT_PERCENTAGE]})
    wiredPercentages(result){
        if(result.data){
            console.log('Training Module Data ' + JSON.stringify(result.data));
            this.colorCodePercentage = result.data.fields.Rpl_Color_Code_Percentage__c.value ? result.data.fields.Rpl_Color_Code_Percentage__c.value : 0;
            this.colorCodePercentageClass = this.colorCodePercentage && this.colorCodePercentage >= 90 ? 'green' : this.colorCodePercentage > 70 && this.colorCodePercentage  < 89 ? 'yellow' : 'red'; 
            this.colorCodePercentage += ' %';

            this.attendancePercentage = result.data.fields.Rpl_Training_Attendance_Percentage__c.value ? result.data.fields.Rpl_Training_Attendance_Percentage__c.value : 0;
            this.attendancePercentageClass = this.attendancePercentage && this.attendancePercentage >= 90 ? 'green' : this.attendancePercentage > 70 && this.attendancePercentage < 89 ? 'yellow' : 'red';
            this.attendancePercentage += ' %';

            this.assesssmentPercentage = result.data.fields.Rpl_Training_Assessment_Percentage__c.value ?  result.data.fields.Rpl_Training_Assessment_Percentage__c.value : 0;
            this.assesssmentPercentageClass = this.assesssmentPercentage && this.assesssmentPercentage >= 90 ? 'green' : this.assesssmentPercentage > 70 && this.assesssmentPercentage < 89 ? 'yellow' : 'red';
            this.assesssmentPercentage += ' %';


        }else if(result.error){
            console.log("Error " + result.error);
        }
    }
     handleStepClick(event) {
        const stepNumber = event.target.dataset.step;
        if(stepNumber == 3){
            this.isTrainingMaterial = true;
            this.isAttendance = false;
            this.isAssessment = false;
            this.updateStyles(stepNumber, 'training-tab');

        }else if(stepNumber ==4){
             this.isTrainingMaterial = false;
            this.isAttendance = true;
            this.isAssessment = false;
            this.updateStyles(stepNumber, 'training-tab');
        } else if(stepNumber == 5){
             this.isTrainingMaterial = false;
            this.isAttendance = false;
            this.isAssessment = true;
            this.updateStyles(stepNumber, 'training-tab');
        }else if(stepNumber == 1){
             this.isTrainingModule = true;
             this.updateStyles(stepNumber, 'tab-header');
        }else if(stepNumber == 2){
             this.isTrainingModule = false;
             this.updateStyles(stepNumber, 'tab-header');
        }
     }

        updateStyles(stepNumber, className) {
        const tabs = this.template.querySelectorAll(`.${className}`);
        tabs.forEach(tab => {
            const tabStepNumber = tab.dataset.step;
            //console.log(tabStepNumber);
            if (tabStepNumber != stepNumber) {
                tab.style.backgroundColor = '#FEF3EA';
                tab.style.color = 'black';
            } else {
                tab.style.color = 'white';
                tab.style.backgroundColor = '#F57F26';

            }
        })
    }
}