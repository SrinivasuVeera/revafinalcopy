import { LightningElement, api, wire} from 'lwc';
import getCasesWithAppointments from '@salesforce/apex/rewaCaseController.getCasesWithAppointments';


export default class RevaSWappointmentDetailView extends (LightningElement) {
    @api recordId;
    casesWithAppointments;
    

    @wire(getCasesWithAppointments, { contactId: '$recordId' })
    wiredCasesWithAppointments({ data, error }) {
        if (data) {
            this.casesWithAppointments = data;
        } else if (error) {
           
            console.error('Error fetching data:', error);
        }
       // console.log('recordId--->'+recordId);
    }
}