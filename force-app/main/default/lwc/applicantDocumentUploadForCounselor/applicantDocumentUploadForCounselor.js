import { LightningElement,api,wire,track} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getApplicantId from '@salesforce/apex/ApplicantDocumentUpload.getApplicantId';


export default class ApplicantDocumentUploadForCounselor extends LightningElement {

    @api recordId; // ApplicationID
    @api applicantId;//ContactId
    @track applicant;

    @wire(getRecord, { recordId: '$recordId'})
    getaccountRecord({ data, error }) {
        if (data) {
          this.applicant = data;
          this.processRelatedObjects();
        } else if (error) {
          console.error('ERROR => ', JSON.stringify(error)); // handle error properly
        }
      }

    //return values has id's contact and applicationId
    @wire(getApplicantId,{applicationId:'$recordId'}) 
      wiredContact({data,error}) {
        if (data) {
          this.applicantId = data;
          console.log(data); 
        } else if (error) {
          console.log(error);
        }
      }
}