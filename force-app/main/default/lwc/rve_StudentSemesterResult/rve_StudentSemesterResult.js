import { LightningElement } from 'lwc';
import fetchData from '@salesforce/apex/ASM_StdResultListView.fetchData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Rve_StudentSemesterResult extends LightningElement {

    resultList;
    isSelected = false;
    selectedId = '';
    semName = '';
    Spinner = false;
    isResultList=false;

    connectedCallback() {
        this.doInit();
    }

    async doInit() {
        this.Spinner = true;
        try {
            const result = await fetchData();
            if (result) {
                console.log('result=> '+JSON.stringify(result));
                this.resultList = result;
                if(this.resultList.length>0)
                {
                   this.isResultList = true;
                }
                console.log('resultlist=> '+this.resultList);
                this.Spinner = false;
            } else {
                this.Spinner = false;
                this.showToast('dismissible', 'Failed', result.getError()[0].message, 'error');
            }
        } catch (error) {
            this.Spinner = false;
            this.showToast('dismissible', 'Failed', error.message, 'error');
        }
    }

    selectResult(event) {
        const resList = this.resultList;
        const index = event.target.dataset.id;

        this.selectedId = resList[index].Id;
        this.semName = resList[index].hed__Term__r.Name;
        this.isSelected = true;
    }

    goBack() {
        this.selectedId = '';
        this.semName = '';
        this.isSelected = false;
    }

    showToast(mode, title, message, type) {
        const evt = new ShowToastEvent({
            mode: mode,
            title: title,
            message: message,
            variant: type,
            duration: '2000'
        });
        this.dispatchEvent(evt);
    }
}