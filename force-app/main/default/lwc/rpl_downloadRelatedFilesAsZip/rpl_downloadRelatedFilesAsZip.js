import { LightningElement, api, wire } from 'lwc';
import fetchRelatedFiles from '@salesforce/apex/RPL_DownloadZip.fetchRelatedFiles';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class Rpl_downloadRelatedFilesAsZip extends LightningElement {
    @api recordIds = [];
    @api fileNames = '';
    fileIds = '';
    isLoading= false;

    @wire(fetchRelatedFiles, {recordIds: '$recordIds', fileNames:'$fileNames'}) 
    getRelatedContentDocuments({data, error}){
        this.isLoading = true;
        if(data){
            let fileList = JSON.parse(JSON.stringify(data));
                
                if (fileList !== '') {
                    for (let i in fileList) {
                        this.fileIds += fileList[i] + '/';
                    }
                }
                if (this.fileIds.length > 0) {
                    this.fileIds = this.fileIds.replace(/.$/, '?');
                    const config = {
                        type: 'standard__webPage',
                        attributes: {
                            url: '/sfc/servlet.shepherd/version/download/' + this.fileIds
                        }
                    };
                   
                    window.open('/sfc/servlet.shepherd/version/download/' + this.fileIds, '_blank');
                    this.showToast('success', 'File Download', 'Files Download Successful!');
                } else {
                    this.showToast('error', 'File Download', 'No files to download!');
                }
                this.isLoading = false;
        }else if(error){
             console.error('Error: ', error);
            this.showToast('error', 'File Download', error.body.message);
            this.isLoading = false;
        }
    }

    showToast(variant, title, message) {
        const event = new ShowToastEvent({
            variant: variant,
            title: title,
            message: message
        });
        this.dispatchEvent(event);
    }
}