import { LightningElement, api, track } from 'lwc';
import getExampleTimeTable from '@salesforce/apex/Rve_ViewExamApplicationController.getExampleTimeTable';
import USER_ID from '@salesforce/user/Id';

export default class Rve_SemesterTimeTable extends LightningElement {
    @track userId = USER_ID;
    @track examData = [];
    @track hasPracticalData = false;
    @track hasTheoryData = false;

    connectedCallback() {
        this.loadExamData();
    }

    loadExamData() {
        getExampleTimeTable({ userId: this.userId })
            .then(result => {
                console.log('result=> '+JSON.stringify(result));
                this.examData = result.map(item => ({
                    ...item,
                    // Convert start and end times to 12-hour IST format
                    //Rve_Start_Time__c: this.formatMillisecondsTo12HourIST(item.Rve_Start_Time__c)? this.formatMillisecondsTo12HourIST(item.Rve_Start_Time__c):NULL,
                    Rve_Start_Time__c: item.Rve_Start_Time__c ? this.formatMillisecondsTo12HourIST(item.Rve_Start_Time__c) : '',
                    Rve_End_Time__c: item.Rve_End_Time__c?this.formatMillisecondsTo12HourIST(item.Rve_End_Time__c):'',
                    Rve_QP_Code__c : item.Rve_QP_Code__c
                }));
                this.hasPracticalData = this.examData.some(item => item.Rve_Batch__c);
                this.hasTheoryData = this.examData.some(item => item.Rve_QP_Code__c);
             
            })
            .catch(error => {
            });
    }

    formatMillisecondsTo12HourIST(ConvertTime){
      let hours1 = Math.floor(ConvertTime / (1000 * 60 * 60));
                        let minutes1 = Math.floor((ConvertTime % (1000 * 60 * 60)) / (1000 * 60));
                        let seconds1 = Math.floor((ConvertTime % (1000 * 60)) / 1000);
                   
                        // Add leading zeros if necessary
                        hours1 = (hours1 < 10) ? "0" + hours1 : hours1;
                        minutes1 = (minutes1 < 10) ? "0" + minutes1 : minutes1;
                        seconds1 = (seconds1 < 10) ? "0" + seconds1 : seconds1;
                   
                        // Add AM or PM based on hours
                        let ampm1 = (hours1 >= 12) ? "PM" : "AM";
                        hours1 = (hours1 % 12 === 0) ? 12 : hours1 % 12; // Convert 0 to 12 for 12-hour format
                   
                        // Construct the formatted time string
                        let formattedStartTime = hours1 + ":" + minutes1 + ":" + seconds1 + " " + ampm1;
                        return formattedStartTime;
    }

  
}