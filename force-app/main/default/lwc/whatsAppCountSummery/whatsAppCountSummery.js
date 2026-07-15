import { LightningElement, track, wire, api } from 'lwc';
import getBatchData from '@salesforce/apex/WhatsAppMsgTriggeredSummery.getWhatsAppTriggerCount';
import getBatchCompletedDate from '@salesforce/apex/WhatsAppMsgTriggeredSummery.getWhatsAppTriggerDate';
import getFeePaidCount from '@salesforce/apex/WhatsAppMsgTriggeredSummery.getApplicationFeePaidCount';
import getListStatusChange from '@salesforce/apex/WhatsAppMsgTriggeredSummery.getLatestStatusChangeList';
import getPAFpaidCount from '@salesforce/apex/WhatsAppMsgTriggeredSummery.getProvisionalAdmissionFeePaid';

export default class WhatsAppCountSummery extends LightningElement {

    @api 
    batchDateTime;

    batch1_count;
    batch2_count;
    batch3_count;
    batchPAFPendingCount;

    batch1_completedDate;
    // batch2_completedDate;
    // batch3_completedDate;

    formattedDate;
    totalCounts;

    // getPAFpaidCountValue;   
    getPAFpaidCountData = 0; 
    isLoading = true;

    feePaidCount;
    countStartedToOther;
    countIncompleteToOther;


    @wire(getBatchData)
    batchCount({ error, data }) {
        if (data) {            
            this.batch1_count = data[0];
            this.batch2_count = data[1];
            this.batch3_count = data[2];
            this.batchPAFPendingCount = data[3];
            this.totalCounts = data[0] + data[1] + data[2] + data[3];
            console.log('Batch Count >> '+data);           
        } else if (error) {
            console.log('Gotch error while fetching batch count :' + error);
        }
    }

    @wire(getBatchCompletedDate)
    batchCompletedDate({error, data}) {
        if (data) {      
            
            console.log('Batch Completed Date >> '+JSON.stringify(data.CompletedDate));               

            // const recItem = data.filter(info => {
            //     return info;
            // })[0].CompletedDate;

            // console.log('Completed Date : '+recItem)
            // console.log('Format Date : '+this.formatDate(recItem));
            // const inputDate = "2024-04-29T17:31:27.000Z";
            
            // this.formatDate(recItem);
           this.batchDateTime = data.CompletedDate;
           this.isLoading = false;
           this.formatDate(data.CompletedDate);
           console.log('formattedDate: '+this.formattedDate);

        } else if (error) {
            this.isLoading = false;
            console.log('Gotch error while fetching batch Completed dates :' + error);
        }
    }

    @wire(getFeePaidCount,{ lastBatchRanDateTime: '$batchDateTime'})
    feePaidCount({error, data}){
        if(data){
            console.log('Fee Paid Count : '+data);
            this.feePaidCount = data;
        } else if(error){
            console.log('Got error while fetching feePaidCount' + error);
        }
    }

    @wire(getPAFpaidCount,{ lastBatchRanDateTime: '$batchDateTime'})
    getPAFpaidCountValue({error, data}){
        if(data){
            console.log('PAF Paid Count : '+data);
            this.getPAFpaidCountData = data;
        } else if(error){
            console.log('Got error while fetching PAF Count' + error);
        }
    }

    @wire(getListStatusChange, {lastBatchRanDateTime : '$batchDateTime'})
    statusChange({error, data}){
        if(data){
            console.log('Status Change  : '+JSON.stringify(data));
            const listIncompleteStatus = data.filter(rec => {
                return rec.OldValue === 'Started' && rec.NewValue === 'Incomplete'
            })
            this.countStartedToOther = listIncompleteStatus.length;
            console.log('After status Incomplete filteration  : '+listIncompleteStatus.length);

            const listSubmittedStatus = data.filter(record => {
                return (record.OldValue === 'Incomplete' && (record.NewValue === 'Submitted' || record.NewValue === 'In Review' || record.NewValue === 'Awaiting Documents' || record.NewValue === 'Interested' || record.NewValue ==='Admit'))                
            })
            this.countIncompleteToOther = listSubmittedStatus.length;
            console.log('After status Submit filteration  : '+listSubmittedStatus.length);

        }else if(error){
            console.log('Got error while fetching Status Change' + error);
        }
    }
   
    formatDate(inputDate) {  
        let dateObj = new Date(inputDate);
            let options = {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit',
                hour12: false,
                timeZone: 'Asia/Kolkata' // Indian Standard Time (IST)
            };
            this.formattedDate = dateObj.toLocaleString('en-IN', options);
    }
}