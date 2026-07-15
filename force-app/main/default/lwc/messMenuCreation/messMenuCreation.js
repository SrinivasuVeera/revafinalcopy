import { LightningElement, wire, track } from 'lwc';
import getPicklistValues from '@salesforce/apex/PicklistValuesController.getPicklistValues';
import insertMenuRecords from '@salesforce/apex/PicklistValuesController.insertMenuRecords';
import LightningConfirm from 'lightning/confirm';
import getMealTimings from '@salesforce/apex/PicklistValuesController.getMealTimings'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MultiMenuComponent extends LightningElement {
    @track picklistValues =  {"Breakfast": [], "Lunch" : [], "Snacks":[], "Dinner":[]};
    @track filteredPicklistValues = {"Breakfast": ['Dosa'], "Lunch" : [], "Snacks":[], "Dinner":[]};

    @track mealDates = [];
    @track isRendered = false; 


     @track selectedValues = {
        Breakfast: { items: [], startTime: '', endTime: '' },
        Lunch: { items: [], startTime: '', endTime: '' },
        Snacks: { items: [], startTime: '', endTime: '' },
        Dinner: { items: [], startTime: '', endTime: '' }
    };
    renderParent;
    isSpinner;
    @track searchKeys = {
        Breakfast: '',
        Lunch: '',
        Snacks: '',
        Dinner: ''
    };
    
    @track mealDates = [];
    menuTypes = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];
    

    @wire(getPicklistValues, { objectName: 'Reva_Mess_Menu__c', fieldName: 'Mess_Items__c' })
    wiredPicklistValues({ error, data }) {
        if (data) {
            console.log('Data ' + JSON.stringify(data));
            const newPicklistValues = { ...this.picklistValues };
            const newFilteredValues = { ...this.filteredPicklistValues };
            this.menuTypes.forEach(menu => {
                newPicklistValues[menu] = data;
                newFilteredValues[menu] = data;
            });
            this.picklistValues = newPicklistValues;
            this.filteredPicklistValues = newFilteredValues;
            this.renderParent = true;
        } else if (error) {
            this.showToast('Error when fetching picklist', error.body.message, 'error');
        }
    }


    // handleDateChange(event) {
    //     const newDate = event.target.value;
    //     const selectedDate = new Date(newDate);
    //     const today = new Date();
    //     today.setHours(0, 0, 0, 0); // Ensure comparison without time part
    
    //     const maxDate = new Date();
    //     console.log("maxDate",maxDate);
    //     console.log("today",today);
    //     console.log("selectedDate",selectedDate);
    //     maxDate.setDate(today.getDate() + 14);
    
    //     if (selectedDate <= today || selectedDate > maxDate) {
    //         this.showToast('Error', 'Selected date must be within the next 15 days, including today.', 'error');
    //         event.target.value = ''; 
    //         return;
    //     }
    
    //     if (!this.mealDates.includes(newDate)) {
    //         this.mealDates = [...this.mealDates, newDate];
    //         event.target.value = '';
    //     } else {
    //         this.showToast('Error', 'The selected date is already added.', 'error');
    //     }
    // }
    
    handleDateChange(event) {
        const newDate = event.target.value;
        if (!this.mealDates.includes(newDate)) {
            this.mealDates = [...this.mealDates, newDate];
            event.target.value = '';
        }
        else {
            this.showToast('Error', 'The selected date is already added.', 'error');
        }
    }

    removeDate(event) {
        const removedDate = event.target.dataset.id;
        this.mealDates = this.mealDates.filter(date => date !== removedDate);
       
    }

  
   
    handleSelectionChange(event) {
        const { menuType, selectedItems, startTime, endTime } = event.detail;
        this.selectedValues = {
            ...this.selectedValues,
            [menuType]: { items: selectedItems, startTime, endTime }
        };
    }

  
    // handleSave() {
    //     const today = new Date().setDate(new Date().getDate() - 1);

    //     if (this.mealDates.length === 0) {
    //         this.showToast('Error', 'Please select at least one date before saving the mess menu.', 'error');
    //         return;
    //     }

    //     const pastDates = this.mealDates.filter(date => new Date(date) < today);
    //     if (pastDates.length > 0) {
    //         this.showToast('Error', 'Meal menu cannot be created for past dates.', 'error');
    //         return;
    //     }

    //     const menuRecords = [];
    //     let incompleteMenus = [];

    //     this.mealDates.forEach(date => {
    //         this.menuTypes.forEach(menu => {
    //             const { items, startTime, endTime } = this.selectedValues[menu];
    //             if (items.length && startTime && endTime) {
    //                 menuRecords.push({
    //                     type: menu,
    //                     menuItems: items,
    //                     startTime,
    //                     endTime,
    //                     mealDate: date
    //                 });
    //             } else {
    //                 incompleteMenus.push(menu);
    //             }
    //         });
    //     });

    //     if (incompleteMenus.length > 0) {
    //         const incompleteMenuTypes = incompleteMenus.join(', ');
    //         this.showConfirmModal(incompleteMenuTypes, menuRecords);
    //     } else {
    //         this.saveRecords(menuRecords);
    //     }
        
    // }

    handleSave() {
        const today = new Date().setDate(new Date().getDate() - 1);
    
        if (this.mealDates.length === 0) {
            this.showToast('Error', 'Please select at least one date before saving the mess menu.', 'error');
            return;
        }
    
        const pastDates = this.mealDates.filter(date => new Date(date) < today);
        if (pastDates.length > 0) {
            this.showToast('Error', 'Meal menu cannot be created for past dates.', 'error');
            return;
        }
    
        const menuRecords = [];
        let incompleteMenus = [];
    
        this.mealDates.forEach(date => {
            this.menuTypes.forEach(menu => {
                const { items, startTime, endTime } = this.selectedValues[menu];
                if (items.length && startTime && endTime) {
                    menuRecords.push({
                        type: menu,
                        menuItems: items,
                        startTime,
                        endTime,
                        mealDate: date
                    });
                } else {
                    incompleteMenus.push(menu);
                }
            });
        });
    
        if (menuRecords.length > 0) {
            if (incompleteMenus.length > 0) {
                const incompleteMenuTypes = incompleteMenus.join(', ');
                this.showConfirmModal(incompleteMenuTypes, menuRecords);
            } else {
                this.saveRecords(menuRecords);
            }
        } else {
            this.showToast('Error', 'Please complete all required fields for at least one menu type before saving.', 'error');
        }
    }
    
    async showConfirmModal(incompleteMenuTypes, menuRecords) {
        const result = await LightningConfirm.open({
            message: `The following menus were not considered for saving as some fields are not filled out: ${incompleteMenuTypes}. Do you want to proceed?`,
            variant: 'headerless',
            label: 'Confirm',
            header: 'Save Confirm',
            type: 'success',
        });
        if (result) {
            this.saveRecords(menuRecords);
        }
    }
    
 
    saveRecords(menuRecords) {
        this.isSpinner = true;
        insertMenuRecords({ jsonString:JSON.stringify(menuRecords) })
            .then(() => {
                this.showToast('Success', 'Records saved successfully', 'success');
               // this.resetValues();
                window.location.reload();
            })
            .catch(error => {
                console.error('Error when saving mess menus ' + error.body.message);
                this.showToast('Error', 'An error occurred while saving records', error.body.message, 'error');
            })
            .finally(() => {
                this.isSpinner = false;
            });
    }

    resetValues() {
        const childElement = this.template.querySelector('c-menu-item-selector');
        console.log('Child Element ' + childElement);
        if (childElement) {
            childElement.resetValues();
        }
        this.selectedValues = {
            Breakfast: { items: [], startTime: '', endTime: '' },
            Lunch: { items: [], startTime: '', endTime: '' },
            Snacks: { items: [], startTime: '', endTime: '' },
            Dinner: { items: [], startTime: '', endTime: '' }
        };
    }
    
    async showConfirmModal(incompleteMenuTypes, menuRecords) {
    const result = await LightningConfirm.open({
        message: `The following menus were not considered for saving as some fields are not filled out: ${incompleteMenuTypes}. Do you want to proceed?`,
        variant: 'headerless',
        label: 'Confirm',
        header: 'Save Confirm', 
        type: 'success', 
    });
    if (result) {
        this.saveRecords(menuRecords);
    } 
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(event);
    }


//***************************
@track minDate;
@track maxDate;

connectedCallback() {
    const today = new Date();
    this.minDate = today.toISOString().split('T')[0];
    const maxDateObj = new Date();
    maxDateObj.setDate(today.getDate() + 14);
    this.maxDate = maxDateObj.toISOString().split('T')[0];
}



@track mealTimings;
@track preprocessedMenuTypes = [];
@track renderParent = true; // Ensure this is set based on your logic

menuTypes = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];

@wire(getMealTimings)
wiredMealTimings({ error, data }) {
    if (data) {
        console.log("data11", data);
        this.mealTimings = {
            Breakfast: { startTime: data.BREAKFAST.Start_Time__c, endTime: data.BREAKFAST.End_Time__c},
            Lunch: { startTime: data.LUNCH.Start_Time__c, endTime: data.LUNCH.End_Time__c },
            Snacks: { startTime: data.SNACKS.Start_Time__c, endTime: data.SNACKS.End_Time__c },
            Dinner: { startTime: data.DINNER.Start_Time__c, endTime: data.DINNER.End_Time__c }
        };
        this.preprocessMenuTypes();
    } else if (error) {
        this.showToast('Error', error.body.message, 'error');
    }
}

preprocessMenuTypes() {
    this.preprocessedMenuTypes = this.menuTypes.map(menu => {
        return {
            type: menu,
            startTime: this.mealTimings[menu].startTime,
            endTime: this.mealTimings[menu].endTime
        };
    });
}



}