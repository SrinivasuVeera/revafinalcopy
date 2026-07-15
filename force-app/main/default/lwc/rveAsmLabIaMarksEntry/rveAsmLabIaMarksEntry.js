import { LightningElement,track,api,wire } from 'lwc';
import fetchData from '@salesforce/apex/ASM_IAMarksEntry.fetchData';
import saveData from '@salesforce/apex/ASM_IAMarksEntry.saveData';
export default class RveAsmLabIaMarksEntry extends LightningElement {

    @api profId;
    @track crsConnection = {};
    @track studentList = [];
    @api iaType = '';
    @api courseName;
    @api sectionName;
    @track showSpinner = false;
    hasStudents = false;

    @wire(fetchData, { prfConId: '$profId' , iaType: $iaType })
            wiredData({ error, data }) {
                if (data) {
                    this.hasStudents=true;
                    console.log('Data:', JSON.stringify(data));
                    console.log('Data:', JSON.stringify(data.list_marksWpr));
                    this.studentList = data.list_marksWpr;
                    console.log('Student List:', JSON.stringify(this.studentList));
                }
            }
    
    handleInputchange(event) {
        var marksList = this.studentList;
        // alert(JSON.stringify(marksList));
         for(var i=0;i<marksList.length;i++){
             var iam = marksList[i];
             var knldg = (iam.iaMark.Knowledge_of_Exercise_Secured_Marks__c != -1 && iam.iaMark.Knowledge_of_Exercise_Secured_Marks__c != undefined && iam.iaMark.Knowledge_of_Exercise_Secured_Marks__c != '' && iam.iaMark.Knowledge_of_Exercise_Secured_Marks__c != null) ? iam.iaMark.Knowledge_of_Exercise_Secured_Marks__c : 0;
             var exec = (iam.iaMark.Execution_of_Exercise_Secured_Marks__c != -1 && iam.iaMark.Execution_of_Exercise_Secured_Marks__c != undefined && iam.iaMark.Execution_of_Exercise_Secured_Marks__c != '' && iam.iaMark.Execution_of_Exercise_Secured_Marks__c != null) ? iam.iaMark.Execution_of_Exercise_Secured_Marks__c : 0;
             var desc = (iam.iaMark.Description_of_Experiment_Secured_Mark__c != -1 && iam.iaMark.Description_of_Experiment_Secured_Mark__c != undefined && iam.iaMark.Description_of_Experiment_Secured_Mark__c != '' && iam.iaMark.Description_of_Experiment_Secured_Mark__c != null) ? iam.iaMark.Description_of_Experiment_Secured_Mark__c : 0;
             var viva = (iam.iaMark.Viva_Voce_Practical_Secured_Marks__c != -1 && iam.iaMark.Viva_Voce_Practical_Secured_Marks__c != undefined && iam.iaMark.Viva_Voce_Practical_Secured_Marks__c != '' && iam.iaMark.Viva_Voce_Practical_Secured_Marks__c != null) ? iam.iaMark.Viva_Voce_Practical_Secured_Marks__c : 0;
             var punc = (iam.iaMark.Punctuality_Secured_Marks__c != -1 && iam.iaMark.Punctuality_Secured_Marks__c != undefined && iam.iaMark.Punctuality_Secured_Marks__c != '' && iam.iaMark.Punctuality_Secured_Marks__c != null) ? iam.iaMark.Punctuality_Secured_Marks__c : 0;
             var result = (iam.iaMark.Results_Secured_Marks__c != -1 && iam.iaMark.Results_Secured_Marks__c != undefined && iam.iaMark.Results_Secured_Marks__c != '' && iam.iaMark.Results_Secured_Marks__c != null) ? iam.iaMark.Results_Secured_Marks__c : 0;
             iam.iaMark.Total_Secured_Marks_New__c = parseFloat(knldg)+parseFloat(exec)+parseFloat(desc)+parseFloat(viva)+parseFloat(punc)+parseFloat(result);
             iam.total = parseFloat(knldg)+parseFloat(exec)+parseFloat(desc)+parseFloat(viva)+parseFloat(punc)+parseFloat(result);
         }
            this.studentList = marksList;

    }

    saveIaMarks() {
            this.isLoading = true;
    
            const allInputs = [...this.template.querySelectorAll('lightning-input')];
            const allValid = allInputs.reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
    
            if (!allValid) {
                this.showToast('Error', 'Please check below messages..', 'error');
                this.isLoading = false;
                return;
            }
    
            const finalList = this.studentList
                .map(item => item.iaMark)
                .filter(mark => mark); // You can add more checks here if needed
    
            if (finalList.length === 0) {
                this.showToast('Error', 'Enter marks for at least one Student', 'error');
                this.isLoading = false;
                return;
            }
    
            saveData({ list_IaMarks: finalList })
                .then(() => {
                    this.showToast('Success', 'IA Marks updated successfully', 'success');
                    this.dispatchEvent(new CustomEvent('refresh')); // Optional
                })
                .catch(error => {
                    this.showToast('Failed', error.body.message, 'error');
                })
                .finally(() => {
                    this.isLoading = false;
                });
        }

        backToList() {
            this.dispatchEvent(new CustomEvent('backtolist'));
        }

}