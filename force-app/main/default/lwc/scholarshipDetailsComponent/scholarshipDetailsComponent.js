import { LightningElement, wire, api, track } from 'lwc';
import getScholarshipMaster from '@salesforce/apex/AdmissionsProcessUtility.getScholarshipMaster';
import getSelectedSubCategory from '@salesforce/apex/AdmissionsProcessUtility.getSelectedSubCategory';
import getApplicationRelatedRecords from '@salesforce/apex/AdmissionsProcessUtility.getApplicationRelatedRecords';


export default class ScholarshipDetailsComponentPoc extends LightningElement {
    @track columns = [];  
   
    

    @api recordId;
    @api selectedSchool;
    @api program;
    @api tenthMarks;
    @api twelfthMarks;
    @api programType;
    @api type;
    @api ugMarks;
    @api applicableForAllYears;
    @api selectedCategory = '';
    @api selectedSubCategory = '';
    @api selectedCategoryother = '';
    @api selectedSubCategoryother = '';
    @api getNumberOfYears;
    

    @track records = [];
    showModal = true;
    rowSelected = false;
    selectedRows = [];
    enteredDiscount;
    scholarshipComData;
    data;
    error;
    errorMessage = '';
    programTypePg;
    selectedScholarshipId = '';
    scholarshipDocsRec = '';
    SelectSubCategory = '';
    category = [];
    Sub_Category = [];
    categoryOther=[];
    Sub_CategoryOther =[];
    @track scholarshipSlabData = [];
    scholarshipCategory = new Map();
        // Add these fields to your data model
    @track enteredDiscount2ndYear;
    @track enteredDiscount3rdYear;
    @track enteredDiscount4thYear;
    @track enteredDiscount5thYear;
    @track selectedRowId;
    @track isOthersCategory = false;
    

    //Get Scholarship data based on the Program type and type
    @wire(getScholarshipMaster, {type: '$type', programType: '$programType'}) 
    wiredScholarshipMaster({ data, error }) {
        if (data) {
            this.scholarshipComData = data;

            data.forEach(item => {
                if (!this.scholarshipCategory.has(item.Category__c)) {
                    this.scholarshipCategory.set(item.Category__c, new Set());
                }
                this.scholarshipCategory.get(item.Category__c).add(item.Sub_Category__c);
            });
            this.scholarshipCategoryOptions();
            this.currentProgramType();
        }

        if (error) {
            console.log('error', error);
        }
    }
    //Creating Category options
    scholarshipCategoryOptions() {
        this.category = [];
        this.category.push({
            value: '',
            label: 'Select a category'
        });
        for (const [categories, subCategory] of this.scholarshipCategory) {
            this.category.push({
                value: categories,
                label: categories
            });
        };
    }
    //Creating Sub-category ooptions
    scholarshipSubCategoryOptions() {
        this.Sub_Category = [];
        this.Sub_Category.push({
            value: '',
            label: 'Select a Sub category'
        });
        for (const subCategory of this.scholarshipCategory.get(this.selectedCategory)) {
            this.Sub_Category.push({
                value: subCategory,
                label: subCategory
            });
        };
    }
    // Creating Sub-category Others options
    scholarshipSubCategoryOtherOptions() {
        this.Sub_CategoryOther = [];
        this.Sub_CategoryOther.push({
            value: '',
            label: 'Select a Sub category'
        });
        for (const subCategory of this.scholarshipCategory.get(this.selectedCategoryother)) {
            this.Sub_CategoryOther.push({
                value: subCategory,
                label: subCategory
            });
        }
    }
    
    
    //store selected category
    onCategoryChange(event) {
        this.selectedCategory = event.target.value;
        this.scholarshipSubCategoryOptions();
        this.selectedSubCategory = null;   
        this.resetSelections();
        this.isOthersCategory = this.selectedCategory === 'Others';
        if (this.selectedCategory === 'Others' || this.selectedCategory === 'REVA CET Scholarship') {
          this.selectedSubCategory = 'Manual';
          this.queryRecords();
          console.log('Records: ', JSON.stringify(this.records));
          this.selectedRows = [this.records[0].Id];
          this.rowSelected = true;
          console.log(JSON.stringify(this.selectedRows));
        }
    }
    //Store Selected sub-category
    onsubCategoryChange(event) {
        this.selectedSubCategory = event.target.value;
        this.resetSelections();
        this.queryRecords();
    }

    resetSelections() {
      console.log('In resetSelections()');
      this.records = [];
      this.selectedRows = [];
      this.enteredDiscount = undefined;
      this.enteredDiscount2ndYear = undefined;
      this.enteredDiscount3rdYear = undefined;
      this.enteredDiscount4thYear = undefined;
      this.enteredDiscount5thYear = undefined;
      this.rowSelected = false;
    }
    //Get Scholarship data based on the selected Category and Sub-Category
    queryRecords() {
        //console.log('Data ',this.scholarshipComData);
        this.scholarshipComData.forEach(item => {
            if (item.Category__c === this.selectedCategory && item.Sub_Category__c === this.selectedSubCategory) {
                this.records.push(item);
            }
        });
        // this.columns = this.columns.filter(column => {
        //   return column.fieldName !== 'Discount_Amount__c'&&
        //        column.fieldName !== 'Discount_Amount_2_Year__c' &&
        //        column.fieldName !== 'Discount_Amount_3_Year__c' &&
        //        column.fieldName !== 'Discount_Amount_4_Year__c' &&
        //        column.fieldName !== 'Discount_Amount_5_Year__c';
        // });

        // if (this.discountEditable) {
        // //   this.columns.splice(3, 0, 
        // //     { label: 'Discount Amount', fieldName: 'Discount_Amount__c', type: 'currency', editable: true },
        // //     { label: '2nd Year Amount', fieldName: 'Discount_Amount_2_Year__c', type: 'currency', editable: true },
        // //     { label: '3rd Year Amount', fieldName: 'Discount_Amount_3_Year__c', type: 'currency', editable: true },
        // //     { label: '4th Year Amount', fieldName: 'Discount_Amount_4_Year__c', type: 'currency', editable: true },
        // //     { label: '5th Year Amount', fieldName: 'Discount_Amount_5_Year__c', type: 'currency', editable: true }
        // //     );
        // } else {
        // //   this.columns.splice(3, 0, 
        // //     { label: 'Discount Amount', fieldName: 'Discount_Amount__c' },
        // //     { label: '2nd Year Amount', fieldName: 'Discount_Amount_2_Year__c' },
        // //     { label: '3rd Year Amount', fieldName: 'Discount_Amount_3_Year__c' },
        // //     { label: '4th Year Amount', fieldName: 'Discount_Amount_4_Year__c' },
        // //     { label: '5th Year Amount', fieldName: 'Discount_Amount_5_Year__c' }
        // //     );
        // }
    }
    //Get Selected scholarship details
    handleRowSelection(event) {
      if(event.detail.selectedRows.length > 0) {
        this.rowSelected = true;
      }
    }

    get saveDisabled() {
      console.log(this.rowSelected, this.discountEditable, this.enteredDiscount,this.enteredDiscount2ndYear, this.enteredDiscount3rdYear, this.enteredDiscount4thYear, this.enteredDiscount5thYear);
      return !(this.rowSelected &&
        (!this.discountEditable ||
            (this.discountEditable &&
               ( (this.enteredDiscount !== undefined &&
                this.enteredDiscount !== '' )||
                (this.enteredDiscount2ndYear !== undefined &&
                this.enteredDiscount2ndYear !== '') ||
                (this.enteredDiscount3rdYear !== undefined &&
                this.enteredDiscount3rdYear !== '') ||
                (this.enteredDiscount4thYear !== undefined &&
                this.enteredDiscount4thYear !== '')||
                (this.enteredDiscount5thYear !== undefined &&
                    this.enteredDiscount5thYear !== ''))))
    );
    }

    get discountEditable() {
      return (this.selectedCategory === 'Others' || this.selectedCategory === 'REVA CET Scholarship') &&
              this.selectedSubCategory === 'Manual';
    }

    handleCellChange() {
        const table = this.template.querySelector('lightning-datatable');
        this.enteredDiscount = table.draftValues[0].Discount_Amount__c;
        this.enteredDiscount2ndYear = table.draftValues[0].Discount_Amount_2_Year__c;
        this.enteredDiscount3rdYear = table.draftValues[0].Discount_Amount_3_Year__c;
        this.enteredDiscount4thYear = table.draftValues[0].Discount_Amount_4_Year__c;
        this.enteredDiscount5thYear = table.draftValues[0].Discount_Amount_5_Year__c;
        console.log('Entered Discount: ' + this.enteredDiscount);
        console.log('Entered 2nd Year Discount: ' + this.enteredDiscount2ndYear);
        console.log('Entered 3rd Year Discount: ' + this.enteredDiscount3rdYear);
        console.log('Entered 4th Year Discount: ' + this.enteredDiscount4thYear);
        console.log('Save Disabled: ' + this.saveDisabled);
    }
    onCategoryChangeOther(event) {
        this.selectedCategoryother = event.detail.value;
        this.scholarshipSubCategoryOtherOptions(); 
    }

    onsubCategoryChangeOther(event) {
        this.selectedSubCategoryother = event.detail.value;
    }
    //Save scholarship and send to the parent component
    handleClickSave() {
      console.log('In handleClickSave');
      let selectedRow =  this.template.querySelector("lightning-datatable").getSelectedRows()[0];
      if (this.selectedCategory === 'Others' && !this.selectedSubCategoryother) {
        this.errorMessage = 'Please select a Category & Sub Category.';
        return;
    }else{
        this.errorMessage ='';
    }
    

      const newEvent = new CustomEvent('inputcarryevent', {
          detail: { 
              discountAmount: this.enteredDiscount !== undefined ? this.enteredDiscount : selectedRow.Discount_Amount__c,
              discountAmount2ndYear: this.enteredDiscount2ndYear !== undefined ? this.enteredDiscount2ndYear : selectedRow.Discount_Amount_2_Year__c,
              discountAmount3rdYear: this.enteredDiscount3rdYear !== undefined ? this.enteredDiscount3rdYear : selectedRow.Discount_Amount_3_Year__c,
              discountAmount4thYear: this.enteredDiscount4thYear !== undefined ? this.enteredDiscount4thYear : selectedRow.Discount_Amount_4_Year__c,
              discountAmount5thYear: this.enteredDiscount5thYear !== undefined ? this.enteredDiscount5thYear : selectedRow.Discount_Amount_5_Year__c,  
              ApplicableFor: selectedRow.Applicable_for_All_Years__c,
              discountPercentage: selectedRow.Discount_Percent__c,
              scholarshipDetailsShow: false,
              scholarshipId : selectedRow.Id,
              scholarshipReqDocs : selectedRow.Documents_Required__c,
              selectedScholarCategory: this.selectedCategory,
              selectedScholarSubCategory: this.selectedSubCategory,
              OtherSelectedCategory :this.selectedCategoryother,
              OtherSelectedSubCategory :this.selectedSubCategoryother,
             
          }
      });
      this.dispatchEvent(newEvent);
      this.scholarshipSubCategoryOptions();
      this.showModal = false;
    }
    //close Dialog box
    handleDialogClose() {
        const newEvent = new CustomEvent('inputcarryevent', {
            detail: {
                scholarshipDetailsShow: false,
            }
        });
        this.dispatchEvent(newEvent);
        this.showModal = false;
    }
    //Close by using close button
    handleClickClose() {
        const newEvent = new CustomEvent('inputcarryevent', {
            detail: {
                scholarshipDetailsShow: false,
            }
        });
        this.dispatchEvent(newEvent);
        this.showModal = false;
    }
    //Showing 12th marks and UG marks dynamically
    currentProgramType() {
        if (this.programType == 'UG') {
            this.programTypePg = true;
        }
        if (this.programType == 'PG' || this.programType == 'Ph.D') {
            this.programTypePg = false;
        }
    }

    connectedCallback(){
        console.log('inside child connected callback '+this.getNumberOfYears);
        if(this.getNumberOfYears == 1){
            this.columns = [
                { label: 'Category', fieldName: 'Category__c' },
                { label: 'Sub Category', fieldName: 'Sub_Category__c' },
                { label: 'Scholarship type', fieldName: 'Scholarship_Type__c'},
                { label: 'Discount Amount', fieldName: 'Discount_Amount__c', type: 'currency', editable: true },
                { label: 'Discount Percent', fieldName: 'Discount_Percent__c' },    
                { label: 'Applicable for All Years', fieldName: 'Applicable_for_All_Years__c', type: 'boolean'}
            ];
        } if(this.getNumberOfYears == 2){
            this.columns = [
                { label: 'Category', fieldName: 'Category__c' },
                { label: 'Sub Category', fieldName: 'Sub_Category__c' },
                { label: 'Scholarship type', fieldName: 'Scholarship_Type__c'},
                { label: 'Discount Amount', fieldName: 'Discount_Amount__c', type: 'currency', editable: true },
                { label: '2nd Year', fieldName: 'Discount_Amount_2_Year__c', type: 'currency', editable: true },
                { label: 'Discount Percent', fieldName: 'Discount_Percent__c' },    
                { label: 'Applicable for All Years', fieldName: 'Applicable_for_All_Years__c', type: 'boolean'}
            ];
        }  else if(this.getNumberOfYears == 3){
            this.columns = [
                { label: 'Category', fieldName: 'Category__c' },
                { label: 'Sub Category', fieldName: 'Sub_Category__c' },
                { label: 'Scholarship type', fieldName: 'Scholarship_Type__c'},
                { label: 'Discount Amount', fieldName: 'Discount_Amount__c', type: 'currency', editable: true },
                { label: '2nd Year', fieldName: 'Discount_Amount_2_Year__c', type: 'currency', editable: true },
                { label: '3rd Year', fieldName: 'Discount_Amount_3_Year__c', type: 'currency', editable: true  },
                { label: 'Discount Percent', fieldName: 'Discount_Percent__c' },    
                { label: 'Applicable for All Years', fieldName: 'Applicable_for_All_Years__c', type: 'boolean'}
            ];
        } else if(this.getNumberOfYears == 4){
            this.columns = [
                { label: 'Category', fieldName: 'Category__c' },
                { label: 'Sub Category', fieldName: 'Sub_Category__c' },
                { label: 'Scholarship type', fieldName: 'Scholarship_Type__c'},
                { label: 'Discount Amount', fieldName: 'Discount_Amount__c', type: 'currency', editable: true },
                { label: '2nd Year', fieldName: 'Discount_Amount_2_Year__c', type: 'currency', editable: true },
                { label: '3rd Year', fieldName: 'Discount_Amount_3_Year__c', type: 'currency', editable: true  },
                { label: '4th Year', fieldName: 'Discount_Amount_4_Year__c', type: 'currency', editable: true },
                { label: 'Discount Percent', fieldName: 'Discount_Percent__c' },    
                { label: 'Applicable for All Years', fieldName: 'Applicable_for_All_Years__c', type: 'boolean'}
            ];
        } else if(this.getNumberOfYears == 5){
            this.columns = [
                { label: 'Category', fieldName: 'Category__c' },
                { label: 'Sub Category', fieldName: 'Sub_Category__c' },
                { label: 'Scholarship type', fieldName: 'Scholarship_Type__c'},
                { label: 'Discount Amount', fieldName: 'Discount_Amount__c', type: 'currency', editable: true },
                { label: '2nd Year', fieldName: 'Discount_Amount_2_Year__c', type: 'currency', editable: true },
                { label: '3rd Year', fieldName: 'Discount_Amount_3_Year__c', type: 'currency', editable: true  },
                { label: '4th Year', fieldName: 'Discount_Amount_4_Year__c', type: 'currency', editable: true },
                { label: '5th Year', fieldName: 'Discount_Amount_5_Year__c', type: 'currency', editable: true  },
                { label: 'Discount Percent', fieldName: 'Discount_Percent__c' },    
                { label: 'Applicable for All Years', fieldName: 'Applicable_for_All_Years__c', type: 'boolean'}
            ];
        }
       
    }

    renderedCallback() {
        console.log('inside child renderedCallback '+this.getNumberOfYears);
    }
}