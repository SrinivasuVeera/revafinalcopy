import { LightningElement, track } from 'lwc';
import getContactDetails from '@salesforce/apex/RevaEntranceExamController.getContactDetails';
import updateExamDetails from '@salesforce/apex/RevaEntranceExamController.updateExamDetails';

export default class RevaEntranceExam extends LightningElement {

    @track applyingRise;
    //@track examDate;
   // @track examType;

    showForm = false;
    showExamFields = false;

    yesNoOptions = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' }
    ];

    /*examDateOptions = [
        { label: '4 April-2026', value: '2026-04-04' },
        { label: '5 April-2026', value: '2026-04-05' }
    ];*/

   /* examTypeOptions = [
        { label: 'Laptop/Desktop with webcam', value: 'Laptop/Desktop with webcam' },
        { label: 'Mobile Based', value: 'Mobile Based' }
    ];*/

    connectedCallback(){
        this.loadContact();
    }

    loadContact(){

        getContactDetails()
        .then(result => {

            if(result.Primary_Application_Submitted__c && !result.Applying_For_REVA_CET__c){
                this.showForm = true;
            }

        })
        .catch(error=>{
            console.error(error);
        });
    }

    handleRiseChange(event){

        this.applyingRise = event.detail.value;

       /* if(this.applyingRise === 'Yes'){
            this.showExamFields = true;
        }else{
            this.showExamFields = false;
        }*/
    }

   /* handleExamDate(event){
        this.examDate = event.detail.value;
    }*/

  /*  handleExamType(event){
        this.examType = event.detail.value;
    }*/

    handleSubmit(){
        if(!this.applyingRise){
            alert('Please select Yes or No');
            return;
        }
          
          /*if(this.applyingRise === 'Yes'){

         if(!this.examDate){

            alert('Please select Exam Date');

            return;
           }
         }*/
        updateExamDetails({
            applyingRise: this.applyingRise,
           // examType: this.examType,
            //examDate: this.examDate
        })
        .then(() => {

            this.showForm = false;

        })
        .catch(error=>{
            console.error(error);
        });

    }

}