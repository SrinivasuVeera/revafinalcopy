import { LightningElement, api, track } from 'lwc';

export default class CustomCombobox extends LightningElement {

    @api label       = '';
    @api name        = '';
    @api placeholder = 'Select an option';
    @api required    = false;
    @api disabled    = false;

    @track isOpen   = false;
    @track optList  = [];
    @track selLabel = '';

    _val = '';

    @api
    get value() { return this._val; }
    set value(v) {
        this._val = v || '';
        this._buildList();
    }

    @api
    get options() { return this.optList; }
    set options(o) {
        this.optList = o ? JSON.parse(JSON.stringify(o)) : [];
        this._buildList();
    }

    _buildList() {
        if (!this.optList || !this.optList.length) return;
        this.optList = this.optList.map(o => ({
            ...o,
            isSelected: o.value === this._val,
            cls: 'slds-media slds-listbox__option slds-listbox__option_plain slds-media_small' +
                 (o.value === this._val ? ' slds-is-selected' : '')
        }));
        const found = this.optList.find(o => o.value === this._val);
        this.selLabel = found ? found.label : '';
    }

    get dropClass() {
        return this.isOpen ? 'slds-form-element slds-is-open' : 'slds-form-element';
    }

    toggleDropdown() {
        if (this.disabled) return;
        this.isOpen = !this.isOpen;
        if (this.isOpen) {
            setTimeout(() => {
                const fn = (e) => {
                    if (!this.template.contains(e.target)) {
                        this.isOpen = false;
                        document.removeEventListener('click', fn);
                    }
                };
                document.addEventListener('click', fn);
            }, 0);
        }
    }

    handleSelect(e) {
        e.stopPropagation();
        this._val = e.currentTarget.dataset.value;
        this._buildList();
        this.isOpen = false;
        this.dispatchEvent(new CustomEvent('change', {
            detail: { value: this._val }, bubbles: true, composed: true
        }));
    }
}