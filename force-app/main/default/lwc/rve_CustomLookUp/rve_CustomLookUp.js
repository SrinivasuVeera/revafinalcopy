import { LightningElement, api, wire } from 'lwc';
import getLookupValues from '@salesforce/apex/rve_InvigilatorAssignmentController.getProfessors';
export default class Rve_CustomLookUp extends LightningElement {
    displayLabelField = 'Name';
    @api iconName = 'standard:user';
    @api indexValue;
    searchRecordList = [];
    spinnerShow = false;
    error = '';
    searchKeyWord='';
    noRecordFound = false;
    selectedRecordLabel='';
    handleKeyChange(event){
       
        //const keywordVal=event.target.value;
        this.searchKeyWord=event.target.value;
        if(this.searchKeyWord.length>=2){
            this.getProfessors();
        }
        
        
    }
    getProfessors(){
        this.spinnerShow = true;
        let container = this.template.querySelector('.custom-lookup-container');
        container.classList.add('slds-is-open');
        getLookupValues({ searchKeyWord: this.searchKeyWord })
           .then(result=>{
            this.users = result.map(professors => ({
                label: professors.Name,
                value: professors.Id
            }));
        
            this.spinnerShow = false;
            this.searchRecordList = JSON.parse(JSON.stringify(result))
           })
           .catch(error=>{
           });
    }
    fireLookupUpdateEvent(value,label) {
        const oEvent = new CustomEvent('professorid',
            {
                detail: {
                    indexval:this.indexValue,
                    selectedRecord: value,
                    selectedRecordName : label

                }
            }
        );
        this.dispatchEvent(oEvent);
    }
    handleClickOnInputBox(event) {
        let container = this.template.querySelector('.custom-lookup-container');
        container.classList.add('slds-is-open');
        this.spinnerShow = true;
    }
    handleSelectionRecord(event) {
        var recid = event.target.getAttribute('data-recid');
        let container = this.template.querySelector('.custom-lookup-container');
        container.classList.remove('slds-is-open');
        this.selectedRecord = this.searchRecordList.find(data => data.Id === recid);
        this.selectedRecordLabel = this.selectedRecord.Name;//this.selectedRecord[this.displayLabelField];
        this.selectionRecordHelper();
        this.fireLookupUpdateEvent(recid,this.selectedRecordLabel);
    }
    selectionRecordHelper() {
        let custom_lookup_pill_container = this.template.querySelector('.custom-lookup-pill');
        custom_lookup_pill_container.classList.remove('slds-hide');
        custom_lookup_pill_container.classList.add('slds-show');
        let search_input_container_container = this.template.querySelector('.search-input-container');
        search_input_container_container.classList.remove('slds-show');
        search_input_container_container.classList.add('slds-hide');
    }

    
    clearSelection() {
        let custom_lookup_pill_container = this.template.querySelector('.custom-lookup-pill');
        custom_lookup_pill_container.classList.remove('slds-show');
        custom_lookup_pill_container.classList.add('slds-hide');
        let search_input_container_container = this.template.querySelector('.search-input-container');
        search_input_container_container.classList.remove('slds-hide');
        search_input_container_container.classList.add('slds-show');
        this.fireLookupUpdateEvent(undefined);
        this.clearSelectionHelper();

    }
    clearSelectionHelper() {

        this.selectedRecord = {};
        this.selectedRecordLabel = '';
        this.searchKeyWord = '';
        this.searchRecordList = [];
    }

}