public with sharing class RoomAllocationWhatsAppNotifications {
    @InvocableMethod(label='Student Room Allocation Notification' description='Send Room Allocation WhatsApp Notifications to student')
    public static void sendRoomAllotedWhatsAppNotification(List<String> recordIds) {
        // Ensure that recordIds is not empty
        if (recordIds != null && !recordIds.isEmpty()) {
            // Make the callout asynchronously
            makeRoomAllocationCallout(recordIds);
            makeRoomAllocationCalloutParents(recordIds);
        } else {
            System.debug('Record IDs list is empty or null');
        }
    }

    @Future(callout=true)
    public static void makeRoomAllocationCallout(List<String> recordIds) {
        // Fetch the related record data
        List<Reva_Hostel_Request__c> requiredFields = [
            SELECT Hostel_Room_Request_For__r.Name, Hostel_Room_Request_For__r.MobilePhone,Reva_Hostel_Room__r.Name, Reva_Hostel_Room__r.Block__c, Student_Fee__r.Amount__c, Student_Fee__r.Amount_Paid__c, Student_Fee__r.Amount_Pending__c, Student_Fee__r.Due_Date__c, Status__c, Hostel_Room_Request_For__r.Parent_Name__c, Hostel_Room_Request_For__r.RH_Parent_Phone_Number__c 
            FROM Reva_Hostel_Request__c
            WHERE Id IN :recordIds
            LIMIT 1
        ];
        // Check if related record is found
        if (!requiredFields.isEmpty() && !String.isBlank(requiredFields[0].Hostel_Room_Request_For__r.MobilePhone)) {
            Reva_Hostel_Request__c requiredField = requiredFields[0];

            // Create WhatsAppNotification instance
            Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
            System.debug('requiredField: '+ requiredField.Status__c);
            /*if (requiredField.Status__c == 'Approved') {
                // When Warden Approved the room allocation
                notification1.templateId = 'roomallocation_student';
            } */
            if (requiredField.Status__c == 'Room Allotted') {
                // When Warden Approved the room allocation
                notification1.templateId = 'roomallocation_student';
            
            } else if (requiredField.Status__c == Null) {
                //When Hostel Registeration is Successful
                notification1.templateId = 'hostelregistrationconfirmation_student';
                
            }

            // Fetch keys from custom metadata based on templateId
            List<WhatsApp_Notification_Template__mdt> templateMetadata = [
                SELECT Template_Field__c, Template_ID__c
                FROM WhatsApp_Notification_Template__mdt
                WHERE Template_ID__c = :notification1.templateId
            ];
        System.debug('templateMetadata: ' + templateMetadata);
            // Populate the params map dynamically
            notification1.params = new Map<String, String>();
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                // Split values based on comma and add each as a separate key
                String[] keys = metadata.Template_Field__c.split(',');
                for (String key : keys) {
                    // You can set dynamic values for each key based on the related record
                    if (key.trim() == 'studentname') {
                        notification1.params.put(key.trim(), requiredField.Hostel_Room_Request_For__r.Name);
                    } else if (key.trim() == 'roomnumber') {
                        notification1.params.put(key.trim(), requiredField.Reva_Hostel_Room__r.Name != null ? requiredField.Reva_Hostel_Room__r.Name : ' ');
                    }else if (key.trim() == 'blockname') {
                        notification1.params.put(key.trim(), requiredField.Reva_Hostel_Room__r.Block__c != null ? requiredField.Reva_Hostel_Room__r.Block__c : ' ');
                    } else if (key.trim() == 'totalamount') {
                        notification1.params.put(key.trim() , requiredField.Student_Fee__r.Amount__c != null? String.valueOf(requiredField.Student_Fee__r.Amount__c) : ' ');
                    } else if (key.trim() == 'amountpaid') {
                        if (notification1.templateId == 'hostelregistrationconfirmation_student') {
                            notification1.params.put(key.trim(), requiredField.Student_Fee__r.Amount_Paid__c != null ? String.valueOf(requiredField.Student_Fee__r.Amount_Paid__c) : ' ');
                        } else if (notification1.templateId == 'roomallocation_student') {
                            notification1.params.put(key.trim() + '  ', requiredField.Student_Fee__r.Amount_Paid__c != null ? String.valueOf(requiredField.Student_Fee__r.Amount_Paid__c) : ' ');
                        }

                    } else if (key.trim() == 'amountpending') {
                        notification1.params.put(key.trim() + ' ', requiredField.Student_Fee__r.Amount_Pending__c != null ? String.valueOf(requiredField.Student_Fee__r.Amount_Pending__c) : ' ' );
                    } else if (key.trim() == 'duedate') {
                        notification1.params.put(key.trim() + ' ', requiredField.Student_Fee__r.Due_Date__c != null ? String.valueOf(requiredField.Student_Fee__r.Due_Date__c) : ' ');
                    }
                }
            }
			
            // Create list of notifications
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};

            // Create map of phone numbers to notifications
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
           // phoneNumbersToNotifications.put(requiredField.Hostel_Room_Request_For__r.MobilePhone, notifications);
             if(requiredField.Hostel_Room_Request_For__r.MobilePhone !=null){
                    String plusRemoved = requiredField.Hostel_Room_Request_For__r.MobilePhone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                     phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                
                   } 
            
            // Send notifications
            System.debug('phoneNumbersToNotifications'+ phoneNumbersToNotifications);
            HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
            System.debug('WhatsApp notification response: ' + response);
        } else {
            System.debug('No related record found for the provided ID');
        }
    }
    

    
     @Future(callout=true)
    public static void makeRoomAllocationCalloutParents(List<String> recordIds) {
        // Fetch the related record data
        List<Reva_Hostel_Request__c> requiredFields = [
            SELECT Hostel_Room_Request_For__r.Name, Hostel_Room_Request_For__r.MobilePhone,Reva_Hostel_Room__r.Name,Hostel_Room_Request_For__r.Father__r.Name,Hostel_Room_Request_For__r.Father__r.MobilePhone, Reva_Hostel_Room__r.Block__c, Student_Fee__r.Amount__c, Student_Fee__r.Amount_Paid__c, Student_Fee__r.Amount_Pending__c, Student_Fee__r.Due_Date__c, Status__c, Hostel_Room_Request_For__r.Parent_Name__c, Hostel_Room_Request_For__r.RH_Parent_Phone_Number__c 
            FROM Reva_Hostel_Request__c
            WHERE Id IN :recordIds
            LIMIT 1
        ];
        if (!requiredFields.isEmpty() && !String.isBlank(requiredFields[0].Hostel_Room_Request_For__r.MobilePhone)) {
            Reva_Hostel_Request__c requiredField = requiredFields[0];

            // Create WhatsAppNotification instance
            Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
            System.debug('requiredField: '+ requiredField.Status__c);
            /*if (requiredField.Status__c == 'Approved') {
                // When Warden Approved the room allocation
                notification1.templateId = 'roomallocation_student';
            } */
            if (requiredField.Status__c == 'Room Allotted') {
                // When Warden Approved the room allocation
                notification1.templateId = 'hostel_room_allocation_parent';
            } else if (requiredField.Status__c == Null) {
                //When Hostel Registeration is Successful
              
                notification1.templateId = 'hostel_registration_confirmation_prnt_copy';
            }

            // Fetch keys from custom metadata based on templateId
            List<WhatsApp_Notification_Template__mdt> templateMetadata = [
                SELECT Template_Field__c, Template_ID__c
                FROM WhatsApp_Notification_Template__mdt
                WHERE Template_ID__c = :notification1.templateId
            ];
        System.debug('templateMetadata: ' + templateMetadata);
            // Populate the params map dynamically
            notification1.params = new Map<String, String>();
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                // Split values based on comma and add each as a separate key
                String[] keys = metadata.Template_Field__c.split(',');
                for (String key : keys) {
                    // You can set dynamic values for each key based on the related record
                    if (key.trim() == 'studentname') {
                        notification1.params.put(key.trim(), requiredField.Hostel_Room_Request_For__r.Name);
                    }else if (key.trim() == 'amount') {
                        notification1.params.put(key.trim(), requiredField.Student_Fee__r.Amount__c != null ? String.valueOf(requiredField.Student_Fee__r.Amount__c) : ' ');
                    }else if (key.trim() == 'parent_name') {
                        notification1.params.put(key.trim(), requiredField.Hostel_Room_Request_For__r.Father__r.Name != null ? requiredField.Hostel_Room_Request_For__r.Father__r.Name : ' ');
                    }else if (key.trim() == 'Parent_name') {
                        notification1.params.put(key.trim(), requiredField.Hostel_Room_Request_For__r.Father__r.Name != null ? requiredField.Hostel_Room_Request_For__r.Father__r.Name : ' ');
                    } else if (key.trim() == 'room_number') {
                        notification1.params.put(key.trim(),  requiredField.Reva_Hostel_Room__r.Name != null ? requiredField.Reva_Hostel_Room__r.Name : ' ');
                    }else if (key.trim() == 'block_name') {
                        notification1.params.put(key.trim(), requiredField.Reva_Hostel_Room__r.Block__c != null ? requiredField.Reva_Hostel_Room__r.Block__c : ' ');
                    } else if (key.trim() == 'total_amount') {
                        notification1.params.put(key.trim() , requiredField.Student_Fee__r.Amount__c != null? String.valueOf(requiredField.Student_Fee__r.Amount__c) : ' ');
                    } else if (key == 'amount_paid') {
                      /*  if (notification1.templateId == 'hostelregistrationconfirmation_student') {
                            notification1.params.put(key.trim(), requiredField.Student_Fee__r.Amount_Paid__c != null ? String.valueOf(requiredField.Student_Fee__r.Amount_Paid__c) : ' ');
                        } else if (notification1.templateId == 'roomallocation_student') {
                            notification1.params.put(key.trim() + '  ', requiredField.Student_Fee__r.Amount_Paid__c != null ? String.valueOf(requiredField.Student_Fee__r.Amount_Paid__c) : ' ');
                        }*/
                     notification1.params.put(key.trim() , requiredField.Student_Fee__r.Amount_Paid__c != null ? String.valueOf(requiredField.Student_Fee__r.Amount_Paid__c) : 'AMOUNT DATA NOT FOUND');
                    } else if (key == 'amount_pending') {
                        notification1.params.put(key.trim(), requiredField.Student_Fee__r.Amount_Pending__c != null ? String.valueOf(requiredField.Student_Fee__r.Amount_Pending__c) : 'AMOUNT DATA NOT FOUND ' );
                    } else if (key == 'due_date') {
                        notification1.params.put(key.trim(), requiredField.Student_Fee__r.Due_Date__c != null ? String.valueOf(requiredField.Student_Fee__r.Due_Date__c) : 'DUE NOT FOUND ');
                    }
                }
            }
			
            // Create list of notifications
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};

            // Create map of phone numbers to notifications
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
             if(requiredField.Hostel_Room_Request_For__r.Father__r.MobilePhone!=null){
                    String plusRemoved = requiredField.Hostel_Room_Request_For__r.Father__r.MobilePhone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
        phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                   } 
            
            // Send notifications
            System.debug('phoneNumbersToNotifications'+ phoneNumbersToNotifications);
            HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
            System.debug('WhatsApp notification response: ' + response);
        } else {
            System.debug('No related record found for the provided ID');
        }
    }
}