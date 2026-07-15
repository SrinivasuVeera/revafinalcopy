import { LightningElement, track } from 'lwc';
import getUnreadActiveNotifications from '@salesforce/apex/HostelNotification.getUnreadActiveNotifications';
import markNotificationAsRead from '@salesforce/apex/HostelNotification.markNotificationAsRead';
import getCurrentUserName from '@salesforce/apex/HostelNotification.getCurrentUserName';

export default class StudentAnnouncementPopup extends LightningElement {
    @track showAnnouncement = false;
    @track announcementMessage = '';
    @track studentName = 'Admin';
    @track fileName = '';
    @track fileUrl = '';
    @track popupTitle;
    notificationId;

    connectedCallback() {
        getCurrentUserName().then(name => {
            this.studentName = name || 'Admin';
        });

        getUnreadActiveNotifications()
            .then(result => {
                if (result && result.notification) {
                    this.popupTitle = result.title;
                    this.announcementMessage = result.notification.Message__c;
                    this.notificationId = result.notification.Id;
                    this.showAnnouncement = true;
                }

                this.fileUrl = result.fileUrl || '';
                this.fileName = this.fileUrl ? 'Click to View File' : '';
           
    })
            

            .catch(error => {
                console.error('Error fetching notification:', error);
            });
    }

    handleCancel() {
        this.showAnnouncement = false;
    }

    handleMarkAsRead() {
        markNotificationAsRead({ notificationId: this.notificationId })
            .then(() => {
                this.showAnnouncement = false;
            })
            .catch(error => {
                console.error('Error marking notification as read:', error);
            });
    }
}