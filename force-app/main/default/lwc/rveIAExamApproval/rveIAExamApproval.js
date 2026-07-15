import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContacts from '@salesforce/apex/rve_IAExamApproval.getContacts';
import updateContacts from '@salesforce/apex/rve_IAExamApproval.updateContacts';
import { NavigationMixin } from 'lightning/navigation';
export default class RveIAExamApproval extends NavigationMixin(LightningElement) {
    @track contacts = [];
    @track selectedContacts = [];
    @track comments = '';
    @track isVerticalHead = false;
    @track exist_examinationNotification = false;
    selectAllChecked = false;
    showSelectedContacts = false;
    ifContacts = true;
    originalContacts = [];
    searchTerm = '';
    afterSave =false;
    @track isDownloadModalOpen = false;
    //@api notificationId;
    connectedCallback() {
        console.log('Enabled');
    }

    @wire(getContacts)
    wiredContacts({ error, data }) {
        if (data) {
            console.log('data>>',JSON.stringify(data))
            let pendingAmounts = data.pendingAmounts || {}; // Map of ID -> Fee details
            this.originalContacts = data.contacts.map(contact => ({
                ...contact,
                Program_Batch_Name: contact.Program_Batch__r ? contact.Program_Batch__r.Name : '',
                TotalAverageAttendance: contact.Total_average_current_sem_attendance__c
        ? parseFloat(contact.Total_average_current_sem_attendance__c).toFixed(2) // ✅ Format properly
                : '0.00',
                TotalPendingAmount: pendingAmounts[contact.Id] ? pendingAmounts[contact.Id] : '0.00'
            }));
            this.isVerticalHead = data.isVerticalHead;
            this.exist_examinationNotification = data.exist_examinationNotification;
            console.log('this.originalContacts>>',JSON.stringify(this.originalContacts));
            console.log('this.isVerticalHead>>',JSON.stringify(this.isVerticalHead));
            console.log('this.exist_examinationNotification>>',this.exist_examinationNotification);
            this.filterContacts();
        } else if (error) {
            console.error('Error fetching contacts:', error);
        }
    }

    handleSearch(event) {
        this.searchTerm = event.target.value.toLowerCase();
      //  console.log('handlesearch=> '+this.searchTerm)
        this.filterContacts();
        this.selectedContacts = [];
    }

    /*filterContacts() {
        //console.log('44=> '+'filterContacts')
        this.contacts = this.originalContacts.filter(contact =>
            contact.Name.toLowerCase().includes(this.searchTerm) ||
            contact.SRN_Number__c.toLowerCase().includes(this.searchTerm) ||
            contact.Program_Batch_Name.toLowerCase().includes(this.searchTerm) 
          //  contact.TotalPendingAmount.toString().includes(this.searchTerm) ||
          //  contact.TotalAverageAttendance.toString().includes(this.searchTerm)
        );
      //  console.log('contacts>>',JSON.stringify(this.contacts))
    }*/
      /*********************WORKING ONE********************************/


      /*filterContacts() {
    this.contacts = this.originalContacts.filter(contact => {
        const name = contact.Name ? contact.Name.toLowerCase() : '';
        const srn = contact.SRN_Number__c ? contact.SRN_Number__c.toLowerCase() : '';
        const batchName = contact.Program_Batch_Name ? contact.Program_Batch_Name.toLowerCase() : '';
        return name.includes(this.searchTerm) || srn.includes(this.searchTerm) || batchName.includes(this.searchTerm);
    });
}*/

   filterContacts() {
    this.contacts = this.originalContacts
        .filter(contact => {
            const name = contact.Name ? contact.Name.toLowerCase() : '';
            const srn = contact.SRN_Number__c ? contact.SRN_Number__c.toLowerCase() : '';
            const batch = contact.Program_Batch_Name ? contact.Program_Batch_Name.toLowerCase() : '';
            return name.includes(this.searchTerm) || srn.includes(this.searchTerm) || batch.includes(this.searchTerm);
        })
        .map(contact => ({
            ...contact,
            checked: this.selectedContacts.some(c => c.Id === contact.Id)
        }));

    // Update "Select All" status after filtering
    this.selectAllChecked = this.contacts.length > 0 && this.contacts.every(contact => contact.checked);
}

/************************ *WORKING ONE
    *  handleCheckboxChange(event) {
        const contactId = event.target.dataset.id;
        const checked = event.target.checked;
        if (checked) {
            const selectedContact = this.contacts.find(contact => contact.Id === contactId);
            this.selectedContacts.push({ ...selectedContact });
        } else {
            this.selectedContacts = this.selectedContacts.filter(contact => contact.Id !== contactId);
        }
    }

    selectAllCheckboxChange(event) {
        const checked = event.target.checked;
        this.selectAllChecked = checked;
        if (checked) {
            this.selectedContacts = [...this.contacts];
        } else {
            this.selectedContacts = [];
        }
        this.contacts = this.contacts.map(contact => ({
        ...contact,
        checked: checked
    }));
    }****************************/
    handleCheckboxChange(event) {
    const contactId = event.target.dataset.id;
    const checked = event.target.checked;

    // Update selectedContacts
    if (checked) {
        const selectedContact = this.contacts.find(contact => contact.Id === contactId);
        if (!this.selectedContacts.find(contact => contact.Id === contactId)) {
            this.selectedContacts.push({ ...selectedContact });
        }
    } else {
        this.selectedContacts = this.selectedContacts.filter(contact => contact.Id !== contactId);
    }

    // Update 'checked' status on contact in main list
    this.contacts = this.contacts.map(contact => {
        if (contact.Id === contactId) {
            return { ...contact, checked };
        }
        return contact;
    });

    // Check if all are selected
    const allChecked = this.contacts.length > 0 && this.contacts.every(contact => contact.checked);
    this.selectAllChecked = allChecked;
    }

    selectAllCheckboxChange(event) {
    const checked = event.target.checked;
    this.selectAllChecked = checked;

    // Update all individual contact checkboxes
    this.contacts = this.contacts.map(contact => ({
        ...contact,
        checked
    }));

    // Update selectedContacts list
    this.selectedContacts = checked ? [...this.contacts] : [];
}

    handleNext() {
        this.showSelectedContacts = true;
        this.ifContacts = false;
    }

    /***************Working one 05052025*******************
     * handlePrevious() {
        this.showSelectedContacts = false;
        this.ifContacts = true;
        this.selectedContacts = [];
        this.contacts = this.originalContacts.map(contact => ({
            ...contact,
            checked: this.selectedContacts.some(selectedContact => selectedContact.Id === contact.Id)
        }));
    }***************************************/
    handlePrevious() {
    this.showSelectedContacts = false;
    this.ifContacts = true;

    // Add 'checked' flag to each contact before rendering
    this.contacts = this.originalContacts.map(contact => {
        const isSelected = this.selectedContacts.some(c => c.Id === contact.Id);
        return { ...contact, checked: isSelected };
    });
}


    handleCommentChange(event) {
        const contactId = event.target.dataset.id;
        const comment = event.target.value;
        this.selectedContacts = this.selectedContacts.map(contact => {
            if (contact.Id === contactId) {
                contact.Comment = comment;
            }
            return contact;
        });
    }

    handleSave() {
        this.afterSave=true;
        const updatedContacts = this.selectedContacts.map(contact => ({
            Id: contact.Id,
               Exam_Approval__c: true,
               Date_of_Approval__c: new Date(),
               Description: contact.Comment,
               Checking_Eligibility_for_Exam__c : 'Eligible',
        }));

        updateContacts({ contacts: updatedContacts })
            .then(() => {
                this.showToast('Success', 'Contacts updated successfully', 'success');
            })
            .catch(error => {
                this.showToast('Error', 'Error updating contacts', 'error');
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
        window.location.reload();
        this.showSelectedContacts = false;
        this.ifContacts = true;
        this.selectedContacts = [];
    }

     get isNextButtonDisabled() {
        console.log(this.selectedContacts.length+' '+this.isVerticalHead);
        return this.selectedContacts.length === 0 || this.isVerticalHead!=true;
    }

    handleDownloadClick() {
        this.refs.downloadModal.openModal();
    }

    isContactSelected(contactId) {
    return this.selectedContacts.some(contact => contact.Id === contactId);
}
}