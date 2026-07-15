import { LightningElement, api, track, wire } from 'lwc';
import fetchData from '@salesforce/apex/ASM_IAMarksEntry.fetchData';
import saveData from '@salesforce/apex/ASM_IAMarksEntry.saveData';
export default class RveAsmIaMarksEntry extends LightningElement {
    @api profId;
    @track crsConnection;
    @track studentList = [];
    @api iaType = '';
    @api courseName;
    @api sectionName;
    theoryMax
    seminarMax
    quizMax
    @track showSpinner = false;
    hasStudents = false;

    @wire(fetchData, { prfConId: '$profId' , iaType: 'IA2' })
    wiredData({ error, data }) {
        if (data) {
            this.hasStudents=true;
            console.log('Course:', JSON.stringify(data.list_marksWpr[0].crsConn.hed__Course_Offering__r.hed__Course__r));
            this.theoryMax = data.list_marksWpr[0].crsConn.hed__Course_Offering__r.hed__Course__r.Theory_Maximum_Marks__c;
            this.seminarMax = data.list_marksWpr[0].crsConn.hed__Course_Offering__r.hed__Course__r.Seminar_Maximum_Marks__c;
            this.quizMax = data.list_marksWpr[0].crsConn.hed__Course_Offering__r.hed__Course__r.Quiz_Maximum_Marks__c;
            console.log('Data:', JSON.stringify(data.list_marksWpr));
            this.studentList = data.list_marksWpr;
            console.log('Student List:', JSON.stringify(this.studentList));
        }
    }

    connectedCallback() {
        this.initComponent();
    }

    initComponent() {
        this.showSpinner = true;
        // Load crsConnection, iaType, and studentList from Apex (not included here)
        // After data is loaded:
        this.showSpinner = false;
    }

    handleInputChange(event) {
       
        const field = event.target.dataset.field;
        console.log('Field:', field);
        const crsid = event.target.dataset.id;
        console.log('ID:', crsid);
        const crsindex = event.target.dataset.index;
        console.log('index:', crsindex);
        const value = parseFloat(event.target.value);
        console.log('Value:', value);
        let updatedList = this.studentList.map(option => {
            if (option.iaMark.Course_Connection__c === crsid) {
                let updatedIaMark;
                // Clone the iaMark object to avoid mutation issues
                if(field === 'Seminar_Secured_Marks__c') {
                     updatedIaMark = { ...option.iaMark, Seminar_Secured_Marks__c: isNaN(value) ? 0 : value };

                }
                if(field === 'Theory_Secured_Marks__c'){
                     updatedIaMark = { ...option.iaMark, Theory_Secured_Marks__c: isNaN(value) ? 0 : value };

                }
                if(field === 'Quiz_Secured_marks__c'){

                 updatedIaMark = { ...option.iaMark, Quiz_Secured_marks__c: isNaN(value) ? 0 : value };
                }
                
                return {
                    ...option,
                    iaMark: updatedIaMark
                };
            }
            return option;
        });
        
        this.studentList = updatedList;
        
     //   this.studentList = [...this.studentList];
        console.log('Student List after change:', JSON.stringify(this.studentList));
        this.calcTotal(crsindex);
    }

    calcTotal(index) {
        const iaMark = this.studentList[index].iaMark;
        const total = 
            (parseFloat(iaMark.Theory_Secured_Marks__c) || 0) +
            (parseFloat(iaMark.Seminar_Secured_Marks__c) || 0) +
            (parseFloat(iaMark.Quiz_Secured_marks__c) || 0);

        this.studentList[index].iaMark.Total_Secured_Marks_New__c = total;
    }

    async saveIaMarks() {
        this.showSpinner = true;
        try {
            let IaMarksList = this.studentList.map(item => item.iaMark);
            console.log('IaMarksList:', JSON.stringify(IaMarksList));
            console.log('IaMarksList:', typeof IaMarksList);
            await saveData({
                list_IaMarks: IaMarksList
            });
            // Show success toast
            this.dispatchEvent(new CustomEvent('toast', {
                detail: { message: 'Marks updated successfully', type: 'success' }
            }));
        } catch (error) {
            console.error('Error updating marks:', error.message);
            this.dispatchEvent(new CustomEvent('toast', {
                detail: { message: 'Failed to update marks '+error.message, type: 'error' }
            }));
        } finally {
            this.showSpinner = false;
        }
    }

    backToList() {
        this.dispatchEvent(new CustomEvent('backtolist'));
    }
}