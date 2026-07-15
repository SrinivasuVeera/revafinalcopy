import { LightningElement, wire, track } from 'lwc';
import Id from '@salesforce/user/Id';

// Import from Apex
import getExamApplicationList from '@salesforce/apex/Rve_ViewExamApplicationController.getExamApplicationList';

export default class Rve_ViewExamApplicationListView extends LightningElement {
    recordId = Id; //user ID
    boolShowSpinner = true;
    showTable = false;
    showSelectedExamApplication = false;
    selectedId;
    @track examApplicationList = [];
    isMobile=false;

    connectedCallback(){
        this.isMobile = window.innerWidth <= 768;
        let userId = this.recordId;
        getExamApplicationList()
        .then(result => {
            let count = 1;
            this.examApplicationList = result.map(item => {
                return {... item, SN: count++}
            })
            this.boolShowSpinner = false;
          //  this.showTable = true;
            console.log('27',JSON.stringify(this.examApplicationList));
            this.showTable = window.innerWidth >= 768;

        })
        .catch(error => {
            console.error('error=> ',error.message);
            this.boolShowSpinner = false;
        })
    }

    openSelectedApplication(event){
        this.selectedId = event.target.dataset.id;
        this.showTable = false;
        this.showSelectedExamApplication = true;
    }

    showListOnBack(){
        this.selectedId = '';
        this.showTable = true;
        this.showSelectedExamApplication = false;
    }
}