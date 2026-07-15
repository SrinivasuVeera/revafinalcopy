import { LightningElement, wire,track } from 'lwc';
import getPincodeDetails from '@salesforce/apex/PincodeDetails.getPincodeDetails';

const cols = [
   
    {
        fieldName: 'Post_Office__c',
        label: 'Post Office'
    },
    {
        fieldName: 'District__c',
        label: 'District'
    },
    {
        fieldName: 'State__c',
        label: 'State'
    },
    {
        fieldName: 'City__c',
        label: 'City'
    }
];

export default class PincodeDetails extends LightningElement {
    pinCode = '';
    error = '';
    postOfficeList = [];
    selectedPostOfficeId = '';
    selectedPostOffice = {};
    cols = cols;
    showTable = false;

    @wire(getPincodeDetails, {
        pincode: '$pinCode'
    })
    wiredPincodeDetails({error,data}) {
        console.log('In wiredPincodeDetails', data);
        if (data) {
            this.postOfficeList = data;
        } else if (error) {
            console.log(error);
        }
    }

    pincodeEntered(event) {
        const searchString = event.target.value;
        this.variable == searchString.length;
        if (searchString.length === 6) {
          this.showTable = true;
          this.clearOutputJson();
          this.pinCode = searchString;
        } else {
            this.showTable = false;
            this.clearOutputJson();
        }
    }

    clearOutputJson() {
      this.selectedPostOfficeId = '';
      this.selectedPostOffice = {};
      this.informOmniScript();
    }

    postOfficeSelected(event) {
        this.selectedPostOfficeId = event.detail.pk;
            this.selectedPostOffice = this.postOfficeList.find((postOffice) => {
                return (postOffice.Id == this.selectedPostOfficeId);
            })
            console.log(this.selectedPostOffice); 
            this.informOmniScript();
    }

    informOmniScript() {
        console.log('came to informOmniScript()');
        if (Object.keys(this.selectedPostOffice).length == 0) {
            this.selectedPostOffice = {
                'State__c': null,
                'Post_Office__c': null, 
                'Id': null,
                'District__c': null,
                'Pincode__c': null,
                'City__c': null
            }
        }
        const omniAggregateEvent = 'omniaggregate';
        const data = {
            postOffice : this.selectedPostOffice
        };
        const detail = {
            data,
            elementId: 'addressPostOffice'
        }
        const myEvent = new CustomEvent(omniAggregateEvent, {
            bubbles: true,
            cancelable: true,
            composed: true,
            detail: detail,
        });
        console.log(myEvent);
        this.dispatchEvent(myEvent);
    }
}