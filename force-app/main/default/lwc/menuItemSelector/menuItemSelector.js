import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class MenuItemSelector extends LightningElement {
    @api menuType;
    @api picklistValuesFromParent = {};

    searchKey = '';
    @track picklistValues = [];
    @track filteredPicklistValues = [];
    @track selectedValues = [];

    @api startTime;
    @api endTime;

    @track highlightIndex = -1;

     connectedCallback() {
        this.picklistValues = this.picklistValuesFromParent[this.menuType] || [];
     }

     // SEARCH HANDLER 
     handleSearch(event) {
        this.searchKey = event.target.value.toLowerCase();

        if (this.searchKey) {
            this.filteredPicklistValues = this.picklistValues
                .filter(v => v.toLowerCase().includes(this.searchKey))
                .map(v => ({
                    label: v,
                    cls: 'option-item'
                }));
        } else {
            this.filteredPicklistValues = [];
        }

        this.highlightIndex = -1;

        /* keyboard navigation
        setTimeout(() => {
            const wrap = this.template.querySelector('.keyboard-wrapper');
            if (wrap) wrap.focus();
        }, 0);*/
     }

     // KEYBOARD CONTROL 
     handleKeyDown(event) {
        if (!this.filteredPicklistValues.length) return;

        if (event.key === 'ArrowDown') {
            event.preventDefault();
            event.stopPropagation();
            this.highlightIndex =
                (this.highlightIndex + 1) % this.filteredPicklistValues.length;
            this.updateOptionClasses();
            this.scrollHighlightedItem();
        }

        if (event.key === 'ArrowUp') {
            event.preventDefault();
            event.stopPropagation();
            this.highlightIndex =
                (this.highlightIndex - 1 + this.filteredPicklistValues.length)
                % this.filteredPicklistValues.length;
            this.updateOptionClasses();
            this.scrollHighlightedItem();
        }

        if (event.key === 'Enter') {
            event.preventDefault();
            if (this.highlightIndex >= 0) {
                const selectedLabel =
                    this.filteredPicklistValues[this.highlightIndex].label;

                this.selectValue(selectedLabel);
            }
        }
     }
     //SCROLL ITEM INTO VIEW 
     scrollHighlightedItem() {
        const container = this.template.querySelector('.options-container');
        const element =
            container?.querySelector(`[data-index="${this.highlightIndex}"]`);

        if (element) {
            element.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
        }
     }

     // UPDATE HIGHLIGHT CLASSES 
     updateOptionClasses() {
        this.filteredPicklistValues = this.filteredPicklistValues.map((item, i) => {
            return {
                ...item,
                cls: `option-item${this.highlightIndex === i ? ' highlight' : ''}`
            };
        });
     }

     // CLICK SELECT 
     handleSelect(event) {
        const value = event.currentTarget.dataset.value;
        this.selectValue(value);
     }

      //  SELECT LOGIC 
      selectValue(value) {
        if (!this.selectedValues.includes(value)) {
            this.selectedValues = [...this.selectedValues, value];
            this.dispatchSelectionChangeEvent();
        }
        this.clearSearch();
      }

     handleStartTimeChange(event) {
        this.startTime = event.target.value;
        if (this.validateTimes()) {
            this.dispatchSelectionChangeEvent();
        }
     }

     handleEndTimeChange(event) {
        this.endTime = event.target.value;
        if (this.validateTimes()) {
            this.dispatchSelectionChangeEvent();
        }
      }

      validateTimes() {
        if (this.startTime && this.endTime && this.endTime <= this.startTime) {
            this.showToast('Error', 'End time should be greater than Start time', 'error');
            return false;
        }
        return true;
      }

     // SEND SELECTED VALUES TO PARENT 
      dispatchSelectionChangeEvent() {
        this.dispatchEvent(new CustomEvent('selectionchange', {
            detail: {
                menuType: this.menuType,
                selectedItems: this.selectedValues,
                startTime: this.startTime,
                endTime: this.endTime
            }
        }));
      }

        handleRemove(event) {
        const value = event.currentTarget.dataset.value;
        this.selectedValues = this.selectedValues.filter(v => v !== value);
        this.dispatchSelectionChangeEvent();
       }

      clearSearch() {
        this.searchKey = '';
        this.filteredPicklistValues = [];
        this.highlightIndex = -1;
       }

     @api
      resetValues() {
        this.selectedValues = [];
        this.startTime = '';
        this.endTime = '';
        this.clearSearch();
     }

      showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
      }
   }