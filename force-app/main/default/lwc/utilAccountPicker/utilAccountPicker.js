import { LightningElement, api, track } from 'lwc';
import searchAccounts from '@salesforce/apex/smt_Summit_Tracker_Controller.searchAccounts';

const DELAY = 300;

export default class UtilAccountPicker extends LightningElement {
    @api label;
    @api placeholder = 'Search...';
    @api departmentType; // ACADEMIC | NON_ACADEMIC

    @track records = [];
    @track selectedRecord;

    searchKey = '';
    showDropdown = false;
    delayTimeout;

    get comboboxClass() {
        return `slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ${
            this.showDropdown ? 'slds-is-open' : ''
        }`;
    }

    handleKeyUp(event) {
        this.searchKey = event.target.value;
        clearTimeout(this.delayTimeout);

        if (this.searchKey.length < 2) {
            this.records = [];
            this.showDropdown = false;
            return;
        }

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            this.search();
        }, DELAY);
    }

    search() {
        console.log('Selected departmentType :'+this.departmentType);
        searchAccounts({
            searchKey: this.searchKey,
            departmentType: this.departmentType
        })
        .then(result => {
            this.records = result.map(r => ({
                ...r,
                highlightedName: this.highlightMatch(r.Name)
            }));
            this.showDropdown = this.records.length > 0;
        })
        .catch(error => console.error(error));
    }

    highlightMatch(text) {
        const regex = new RegExp(`(${this.searchKey})`, 'gi');
        return text.replace(regex, '<strong>$1</strong>');
    }

    handleSelect(event) {
        const { id, name } = event.currentTarget.dataset;

        this.selectedRecord = { id, name };
        this.showDropdown = false;

        this.dispatchEvent(
            new CustomEvent('recordchange', {
                detail: {
                    recordId: id,
                    recordName: name
                }
            })
        );
    }

    handleRemove() {
        this.selectedRecord = null;
    }
}