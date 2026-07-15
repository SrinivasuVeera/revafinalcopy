import { LightningElement, api, wire } from 'lwc';
import getCaseTeamMembers from '@salesforce/apex/CaseTeamController.getCaseTeamMembers';
import deleteCaseTeamMembers from '@salesforce/apex/CaseTeamController.deleteCaseTeamMembers';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // Import ShowToastEvent

export default class CaseTeamManager extends LightningElement {
    @api recordId; 
    caseTeamMembers; 
    wiredResult;
    error; 
    

    @wire(getCaseTeamMembers, { caseId: '$recordId' })
    wiredCaseTeamMembers(result) {
        this.wiredResult = result;
        if (result.data) {
            this.caseTeamMembers = result.data.map(member => ({
                ...member,
                selected: false // Add a 'selected' property for checkbox state
            }));
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error.body.message;
            this.caseTeamMembers = undefined;
        }
    }
    
    handleCheckboxChange(event) {
        const memberId = event.target.dataset.id;
        this.caseTeamMembers = this.caseTeamMembers.map(member => {
            if (member.memberId === memberId) {
                return { ...member, selected: event.target.checked };
            }
            return member;
        });
    }
   
    handleLoginAsUser(event) {
    const loginUrl = event.target.dataset.url; // get URL from button
    console.log('Login URL:', loginUrl);
    if (loginUrl) {
        window.open(loginUrl, '_blank');
    }else {
        console.warn('No login URL found in dataset.'); // optional: log a warning if URL missing
    }
    
}

    handleSelectAll(event) {
        const isChecked = event.target.checked;
        this.caseTeamMembers = this.caseTeamMembers.map(member => ({
            ...member,
            selected: isChecked // Set all to true if checked, false if unchecked
        }));
    }
    
    async handleDelete() {
        const selectedIds = this.caseTeamMembers
            .filter(member => member.selected)
            .map(member => member.memberId);

        if (selectedIds.length === 0) {
            this.error = 'Please select at least one case team member to delete.';
            return;
        }

        try {
            await deleteCaseTeamMembers({ memberIds: selectedIds });
            // Dispatch success toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Selected case team members deleted successfully.',
                    variant: 'success'
                })
            );
            this.error = undefined;
            return refreshApex(this.wiredResult);
        } catch (error) {
            this.error = error.body.message;
        }
    }
}