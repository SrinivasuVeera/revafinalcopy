import { LightningElement,wire,api,track } from 'lwc';
import fetchData from '@salesforce/apex/ASM_StudentResultView.fetchData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Rve_StudentResultView extends LightningElement {
    @api summaryId;
    @api semName;
    Spinner = true;
    @track showDetailView =false;
    connectedCallback() {
        this.doInit();
    }

    async doInit() {
        try {
            const result = await fetchData({ summaryId: this.summaryId });
            if (result) {
                this.resultDataList = result.list_Results;
                this.summaryRec = result.summaryRec;
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
    toggleDetail(event){
        this.showDetailView=!this.showDetailView;

    }
}