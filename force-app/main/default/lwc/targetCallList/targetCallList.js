import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCallList from '@salesforce/apex/KnowlarityUtils.getCallList';
import { refreshApex } from '@salesforce/apex';
import Id from '@salesforce/user/Id';


const columns = [
  { label: 'Name', fieldName: 'name' },
  { label: 'Type', fieldName: 'objType'},
  { label: 'Score', fieldName: 'score' },
  { label: 'Lead Status / Fees Paid', fieldName: 'remarks' },
];

export default class TargetCallList extends NavigationMixin(LightningElement) {
  callList = [];
  callListResult;
  columns = columns;
  selectedRecord;
  selectedRows = [];
  userId = Id;
  buttonType ='All';

  @wire (getCallList,({ownerId :'$userId', buttonType : '$buttonType'}))
  wiredCallList(result) {
    this.callListResult = result;
    if (result.data) {
      this.callList = result.data;
      console.log(result.data);
    } else if (result.error) {
      console.log(result.error);
    }
  } 

  //On the click of the row in the datatable, this button will refresh the table and navigate to the standard record Page in view mode
  navigateToRecord(event) {
    refreshApex(this.callListResult);
    this.selectedRows = event.detail.selectedRows;
    console.log(this.selectedRows);
    this.selectedRecord = this.selectedRows[0].recordId;
    console.log(this.selectedRecord);
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.selectedRecord,
            actionName: 'view'
        }
    });
  }

  //On the click of any buttons in the button group, the relevant data is showed in teh datatable
  handleClick(event) {
    const buttonLabel = event.target.label;
    switch(buttonLabel){
      case "All" :
        this.buttonType ='All';
        refreshApex(this.callListResult);
        getCallList({ownerId : this.userId, buttonType : this.buttonType}); break;
      case "Paid": 
        this.buttonType = 'Paid';
        refreshApex(this.callListResult);
        getCallList({ownerId : this.userId, buttonType : this.buttonType}); break;
      case "Unpaid": 
        this.buttonType = 'Unpaid';
        refreshApex(this.callListResult);
        getCallList({ownerId : this.userId, buttonType : this.buttonType});  break;
    }
 
}

}