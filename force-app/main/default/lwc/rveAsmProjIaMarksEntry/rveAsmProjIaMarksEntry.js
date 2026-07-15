import { LightningElement,track,api,wire } from 'lwc';
import fetchData from '@salesforce/apex/ASM_IAMarksEntry.fetchData';
import saveData from '@salesforce/apex/ASM_IAMarksEntry.saveData';
export default class RveAsmProjIaMarksEntry extends LightningElement {


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


    handleInputChange(event) {
        var marksList = this.studentList;
        for(var i=0;i<marksList.length;i++){
            var iam = marksList[i];
            var soTopic = (iam.iaMark.Selection_of_Topic_Secured_Marks__c != -1 && iam.iaMark.Selection_of_Topic_Secured_Marks__c != undefined && iam.iaMark.Selection_of_Topic_Secured_Marks__c != '' && iam.iaMark.Selection_of_Topic_Secured_Marks__c != null) ? iam.iaMark.Selection_of_Topic_Secured_Marks__c : 0;
            var anySynt = (iam.iaMark.Analysis_and_Synthesis_Secured_Marks__c != -1 && iam.iaMark.Analysis_and_Synthesis_Secured_Marks__c != undefined && iam.iaMark.Analysis_and_Synthesis_Secured_Marks__c != '' && iam.iaMark.Analysis_and_Synthesis_Secured_Marks__c != null) ? iam.iaMark.Analysis_and_Synthesis_Secured_Marks__c : 0;
            var liSrvy = (iam.iaMark.Literature_Survey_Secured_Marks__c != -1 && iam.iaMark.Literature_Survey_Secured_Marks__c != undefined && iam.iaMark.Literature_Survey_Secured_Marks__c != '' && iam.iaMark.Literature_Survey_Secured_Marks__c != null) ? iam.iaMark.Literature_Survey_Secured_Marks__c : 0;
            var ethAtt = (iam.iaMark.Ethical_Attitude_Secured_Marks__c != -1 && iam.iaMark.Ethical_Attitude_Secured_Marks__c != undefined && iam.iaMark.Ethical_Attitude_Secured_Marks__c != '' && iam.iaMark.Ethical_Attitude_Secured_Marks__c != null) ? iam.iaMark.Ethical_Attitude_Secured_Marks__c : 0;
            var indLearn = (iam.iaMark.Independent_Learning_Secured_Marks__c != -1 && iam.iaMark.Independent_Learning_Secured_Marks__c != undefined && iam.iaMark.Independent_Learning_Secured_Marks__c != '' && iam.iaMark.Independent_Learning_Secured_Marks__c != null) ? iam.iaMark.Independent_Learning_Secured_Marks__c : 0;
            var oralPrst = (iam.iaMark.Oral_Presentation_Secured_Marks__c != -1 && iam.iaMark.Oral_Presentation_Secured_Marks__c != undefined && iam.iaMark.Oral_Presentation_Secured_Marks__c != '' && iam.iaMark.Oral_Presentation_Secured_Marks__c != null) ? iam.iaMark.Oral_Presentation_Secured_Marks__c : 0;
            var rptWrt = (iam.iaMark.Report_Writing_Secured_Marks__c != -1 && iam.iaMark.Report_Writing_Secured_Marks__c != undefined && iam.iaMark.Report_Writing_Secured_Marks__c != '' && iam.iaMark.Report_Writing_Secured_Marks__c != null) ? iam.iaMark.Report_Writing_Secured_Marks__c : 0;
            var contLrn = (iam.iaMark.Continuous_Learning_Secured_Marks__c != -1 && iam.iaMark.Continuous_Learning_Secured_Marks__c != undefined && iam.iaMark.Continuous_Learning_Secured_Marks__c != '' && iam.iaMark.Continuous_Learning_Secured_Marks__c != null) ? iam.iaMark.Continuous_Learning_Secured_Marks__c : 0;
            iam.iaMark.Total_Secured_Marks_New__c = parseFloat(soTopic)+parseFloat(anySynt)+parseFloat(liSrvy)+parseFloat(ethAtt)+parseFloat(indLearn)+parseFloat(oralPrst)+parseFloat(rptWrt)+parseFloat(contLrn);
            iam.total = parseFloat(soTopic)+parseFloat(anySynt)+parseFloat(liSrvy)+parseFloat(ethAtt)+parseFloat(indLearn)+parseFloat(oralPrst)+parseFloat(rptWrt)+parseFloat(contLrn);
        }

        this.studentList = marksList;
        console.log('Student List:', JSON.stringify(this.studentList));
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