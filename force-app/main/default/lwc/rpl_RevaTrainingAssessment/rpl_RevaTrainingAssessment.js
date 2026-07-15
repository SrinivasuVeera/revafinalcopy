import { LightningElement, api, track, wire } from 'lwc';
import getAssessmentResultData from '@salesforce/apex/rpl_Placement_Training_Controller.getAssessmentResultData';


export default class Rpl_RevaTrainingAssessment extends LightningElement {
    @api contactId;
    @track transformedData = {};
    @track data = [];
    @track tableData = [];
  showTable;
  showNoAssessment;
  isSpinner = true;

  handleModalClose(){
    this.showTable = false;
  }

  handleCardClick(event){
    this.showTable = true;
           const moduleName = event.currentTarget.dataset.module;
        const selectedObject = this.data.find(module => module.name === moduleName);
        if(selectedObject){
           this.tableData =selectedObject.subjects;
        }
  }

    

    @wire(getAssessmentResultData , {contactId : '$contactId'})
    wiredData({data, error}){
        if(data){
            this.isSpinner = false;
            if(data && data.length == 0){
                this.showNoAssessment = true;
                return
            }
            data.forEach(record => {
                const moduleName = record.Rpl_Training_Module__r.Name;
                const topic = record.Rpl_Topic__c;
                const percentage = record.Rpl_Percentages_Scored__c;
                const examDate = record.Rpl_Assessment_Date__c;
                
                if (!this.transformedData[moduleName]) {
                    this.transformedData[moduleName] = {
                        subjects : [],
                        totalMarks : 0,
                        numberOfAssessment : 0,
                        totalPercentage : 0,
                    };
                }
                let subjectObject = {
                    "topic" : topic,
                    "date" : examDate,
                    "percentage" : percentage,
                }
                this.transformedData[moduleName].totalMarks += percentage;
                this.transformedData[moduleName].numberOfAssessment += 1;
                this.transformedData[moduleName].subjects.push(subjectObject);
                
            });
          
            Object.keys(this.transformedData).forEach(module => {
                const { totalMarks, numberOfAssessment } = this.transformedData[module];
                this.transformedData[module].totalPercentage = totalMarks > 0 ? (totalMarks / numberOfAssessment).toFixed(2) : 0;
            });
          
            this.data = Object.keys(this.transformedData).map(key => {
               
                const percentage = this.transformedData[key].totalPercentage;
                const circumference = 2 * Math.PI * 40;
                const offset = circumference * (1 - percentage / 100);
                let strokeColor = percentage >= 90 ? 'rgb(142, 204, 142)' : percentage >= 70 ? '#ffdb24' : 'rgb(255, 95, 95)';
                let style = `stroke : ${strokeColor}; stroke-dashoffset:${offset}`;

                return {
                    name: key,
                    style,
                    ...this.transformedData[key]
                };
            });
        }else if(error){
            this.isSpinner = false;
           
        }
    }
}