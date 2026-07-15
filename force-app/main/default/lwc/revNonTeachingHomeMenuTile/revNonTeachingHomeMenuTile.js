import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
/* import getStudentFeeRecords from '@salesforce/apex/FEE_StudentPayment_Ctrl.DisplayStudentFeeRecords';
import getMentorMenteeDetails from '@salesforce/apex/SP_FetchStudentDetailsController.getMenteeLatestCase';
import getSupportRequestDetails from '@salesforce/apex/SP_FetchStudentDetailsController.getSupportRequestLatestCase';
import getStudentPortalTileMenuVisibility from '@salesforce/apex/SP_FetchStudentDetailsController.getStudentPortalTileMenuVisibility';
import getNextExamDates from '@salesforce/apex/SP_FetchStudentDetailsController.getNextExamDates';
import getPlacementSummaryDetails from '@salesforce/apex/RPL_StudentRegisterDriveController.getPlacementSummaryDetails'; */

import STUDENTPORTALICONS from '@salesforce/resourceUrl/NTS_Portal_Static_Resources';


const baseImageUrl = `${STUDENTPORTALICONS}/NTS_Portal_Static_Resources/NTS_Icons/`;


export default class revNonTeachingHomeMenuTile extends NavigationMixin(LightningElement) {


    tileVisibility;
    @track menuList = [
        {
            Id: 'Transport',
            headingName: 'TRANSPORT',
            
            url: `${basePath}/revatransport`,
            imageUrl: `${baseImageUrl}transport.png`,
            body: {
                item1: {
                    headingText: 'Route 1',
                    headingValue: 'N/A'
                },
                item2: {
                    headingText: 'Route 2',
                    headingValue: 'N/A'
                }
            }

        },
        {
            Id: 'VehicleRequest',
            headingName: 'VEHICLE REQUEST',
            url: `${basePath}/vehicle-request-page`,
            imageUrl: `${baseImageUrl}transport.png`,
            body: {
                item1: {
                    headingText: 'Support ID',
                    headingValue: 'N/A'
                },
                item2: {
                    headingText: 'Support Status',
                    headingValue: 'N/A'
                }
            }
        },
        {
            Id: 'EventHallBooking',
            headingName: 'EVENT HALL BOOKING',
            url: `${basePath}/event-hall-booking`,
            imageUrl: `${baseImageUrl}event-hall-booking.png`,
            body: {
               item1: {
                headingText: 'Support ID',
                headingValue: 'N/A'
                },
                item2: {
                    headingText: 'Support Status',
                    headingValue: 'N/A'
                }
            }
       },
       {
        Id: 'InfraSupportRequest',
        headingName: 'INFRA SUPPORT REQUEST',
        url: `${basePath}/infra-support-request`,
        imageUrl: `${baseImageUrl}infra-support-request.png`,
        body: {
            item1: {
                headingText: 'Request ID',
                headingValue: 'N/A'
            },
            item2: {
                headingText: 'Infra ID',
                headingValue: 'N/A'
            },
        }

       },
       {
        Id: 'FeesAndPayments',
        headingName: 'FEES AND PAYMENTS',
        url: `${basePath}/non-teaching-staff-fee`,
        imageUrl: `${baseImageUrl}fees-and-payments.png`,
        body: {
            item1: {
                headingText: 'Pending Fee Amount',
                headingValue: 'N/A'
            },
            item2: {
                headingText: 'Paid Fee Amount',
                headingValue: 'N/A'
            },
        }

    },
        {
            Id: 'HostelRequest',
            headingName: 'HOSTEL REQUEST',
            url: `${basePath}/quartersfornonteachingstaff`,
            imageUrl: `${baseImageUrl}hostel-request.png`,
            
            body: {
                item1: {
                    headingText: 'Request ID',
                    headingValue: 'N/A'
                },
                item2: {
                    headingText: 'Hostel ID',
                    headingValue: 'N/A'
                }
            }
        },
        {
            Id: 'HostelSupportRequest',
            headingName: 'HOSTEL SUPPORT REQUEST',
            url: `${basePath}/hostel-support-request`,
            imageUrl: `${baseImageUrl}hostel-support-request.png`,
            body: {
                item1: {
                    headingText: 'Support ID',
                    headingValue: 'N/A'
                },
                item2: {
                    headingText: 'Support Status',
                    headingValue: 'N/A'
                }
            }
        },
        {
            Id: 'Leave Management',
            headingName: 'LEAVE MANAGEMENT',
            
            url: `${basePath}/leavemanagement`,
            imageUrl: `${baseImageUrl}hostel-request.png`,
            body: {
                item1: {
                    headingText: 'Leave 1',
                    headingValue: 'N/A'
                },
                item2: {
                    headingText: 'Leave 2',
                    headingValue: 'N/A'
                }
            }

        },
       /* {
            Id: 'BookMeals',
            headingName: 'BOOK MEALS',

            url: `${basePath}/meal-booking`,
            imageUrl: `${baseImageUrl}book-meals.png`,
            body: {
                item1: {
                    headingText: 'Book Meal',
                    headingValue: 'N/A'
                },
                item2: {
                    headingText: 'Token Number',
                    headingValue: 'N/A'
                },
            }

        },*/
        // {
        //     Id: 'ServiceQuatersRequest',
        //     headingName: 'SERVICE QUATERS REQUEST',
        //     url: `${basePath}/nonteachingstaffservicequartersrequest`,
        //     imageUrl: `${baseImageUrl}service-quaters-request.png`,
        //     body: {
        //         item1: {
        //             headingText: 'Request ID',
        //             headingValue: 'N/A'
        //         },
        //         item2: {
        //             headingText: 'Quaters Status',
        //             headingValue: 'N/A'
        //         },
        //     }

        // },
        // {
        //     Id: 'BookedRoomDetails',
        //     headingName: 'BOOKED ROOM DETAILS',
        //     url: `${basePath}/booked-room-details`,
        //     imageUrl: `${baseImageUrl}booked-room-details.png`,
        //     body: {
        //         item1: {
        //             headingText: 'Room Number',
        //             headingValue: 'N/A'
        //         },
        //         item2: {
        //             headingText: 'Room Request Status',
        //             headingValue: 'N/A'
        //         },
        //     }

        // },
               {
                    Id: 'GuestHouseBooking',
                    headingName: 'GUEST HOUSE BOOKING',
                    url: `${basePath}/guest-house-booking`,
                    imageUrl: `${baseImageUrl}guest-house-booking.png`,
                    body: {
                        item1: {
                            headingText: 'Support ID',
                            headingValue: 'N/A'
                        },
                        item2: {
                            headingText: 'Support Status',
                            headingValue: 'N/A'
                        }
                    }
                },
                  {
                    Id: 'GuestHouseRequest',
                    headingName: 'GUEST HOUSE REQUESTS',
                    url: `${basePath}/guest-house-request`,
                    imageUrl: `${baseImageUrl}guest-house-booking.png`,
                    body: {
                        item1: {
                            headingText: 'Support ID',
                            headingValue: 'N/A'
                        },
                        item2: {
                            headingText: 'Support Status',
                            headingValue: 'N/A'
                        }
                    }
                },
                {
                    Id: 'StaffQuartersBooking',
                    headingName: 'STAFF QUARTERS BOOKING',
                    url: `${basePath}/staff-quarters-booking`,
                    imageUrl: `${baseImageUrl}service-quaters-request.png`,
                    body: {
                        item1: {
                            headingText: 'Support ID',
                            headingValue: 'N/A'
                        },
                        item2: {
                            headingText: 'Support Status',
                            headingValue: 'N/A'
                        }
                    }
                },
                {
                    Id: 'MealBooking',
                    headingName: 'MEAL BOOKING',
                    url: `${basePath}/meal-booking`,
                    imageUrl: `${baseImageUrl}book-meals.png`,
                    body: {
                        item1: {
                            headingText: 'Support ID',
                            headingValue: 'N/A'
                        },
                        item2: {
                            headingText: 'Support Status',
                            headingValue: 'N/A'
                        }
                    }
                },

                /*{
            Id: 'Leave Management',
            headingName: 'LEAVE MANAGEMENT',
            
            url: `${basePath}/leavemanagement`,
            imageUrl: `${baseImageUrl}hostel-request.png`,
            body: {
                item1: {
                    headingText: 'Route 1',
                    headingValue: 'N/A'
                },
                item2: {
                    headingText: 'Route 2',
                    headingValue: 'N/A'
                }
            }

        },*/


                {
                    Id: 'MessManagement',
                    headingName: 'MESS MANAGEMENT',
                    url: `${basePath}/reva-mess-management`,
                    imageUrl: `${baseImageUrl}service-quaters-request.png`,
                    body: {
                        item1: {
                            headingText: 'Support ID',
                            headingValue: 'N/A'
                        },
                        item2: {
                            headingText: 'Support Status',
                            headingValue: 'N/A'
                        }
                    }
                },
                /***Leave QR added on 04-10-2024 by veera***/
                
    ];

   /*  @wire(getStudentPortalTileMenuVisibility)
    WiredTileVisiblity({ error, data }) {
        if (error) {
            this.showErrorToast(error.body.message);

        } else if (data) {

            this.tileVisibility = data;

            //set the visibility for all tiles based on the data from the wire service
            this.menuList.forEach(tile => {
                tile.isVisible = !!this.tileVisibility[tile.Id]; // Convert to boolean for safety
            });


            const visibleTiles = this.menuList.filter(tile => tile.isVisible);

            // If more than four tiles are visible, limit the visibility to the first four
            if (visibleTiles.length > 4) {

                const firstFourVisibleTiles = visibleTiles.slice(0, 4);

                // Set isVisible to false for all tiles, then set to true for the first four visible
                this.menuList = this.menuList.map(tile => ({
                    ...tile,
                    isVisible: firstFourVisibleTiles.includes(tile)
                }));

            }

            this.fetchDataForVisibleTiles();
        }
    } */

  /*   fetchDataForVisibleTiles() {
        // Fetch data for Fees & Payments if visible
        if (this.menuList[0].isVisible) {
            getStudentFeeRecords()
                .then(data => {
                    // Set the data for Fees & Payments tile
                    if (data) {
                        this.menuList[0].body.item1.headingValue = this.formatCurrency(data.TotalAmount);
                        this.menuList[0].body.item2.headingValue = this.formatCurrency(data.TotalPaidAmount);
                        this.menuList[0].body.item3.headingValue = this.formatCurrency(data.TotalPendingAmount);

                    }
                })
                .catch(error => {
                    this.showErrorToast(error.body.message);
                });
        }

        // Fetch data for Mentor or Mentee if visible
        if (this.menuList[1].isVisible) {
            getMentorMenteeDetails()
                .then(data => {
                    // Set the data for Mentor or Mentee tile
                    if (data) {
                        this.menuList[1].url = data.Id ? `${basePath}/case/${data.Id}` : '';
                        this.menuList[1].body.item1.headingValue = data.Subject ? data.Subject : 'N/A';
                        this.menuList[1].body.item2.headingValue = data.Mentor_Name__c ? data.Mentor_Name__c : 'N/A';
                        this.menuList[1].body.item3.headingValue = data.Mentor_Mobile__c ? data.Mentor_Mobile__c : 'N/A';

                    }

                })
                .catch(error => {
                    this.showErrorToast(error.body.message);
                });
        }

        // Fetch data for Support Request if visible
        if (this.menuList[2].isVisible) {
            getSupportRequestDetails()
                .then(data => {
                    // Set the data for Support Request tile
                    if (data) {
                        this.menuList[2].url = data.Id ? `${basePath}/case/${data.Id}` : '';
                        this.menuList[2].body.item1.headingValue = data.CaseNumber ? data.CaseNumber : 'N/A';
                        this.menuList[2].body.item2.headingValue = data.Category__c ? data.Category__c : 'N/A';
                        this.menuList[2].body.item3.headingValue = data.Case_Status__c ? data.Case_Status__c : 'N/A';

                    }
                })
                .catch(error => {
                    this.showErrorToast(error.body.message);
                });
        }

        // Fetch data for Time Table if visible
        if (this.menuList[3].isVisible) {
            getNextExamDates()
                .then(data => {
                    // Set the data for Time Table tile
                    if (data) {
                        this.menuList[3].body.item1.headingValue = data.IA_1_Start_date__c ? data.IA_1_Start_date__c : 'N/A';
                        this.menuList[3].body.item2.headingValue = data.IA_2_Start_date__c ? data.IA_2_Start_date__c : 'N/A';
                        this.menuList[3].body.item3.headingValue = data.Exam_Start_Date__c ? data.Exam_Start_Date__c : 'N/A';

                    }

                })
                .catch(error => {
                    //this.showErrorToast(error.body.message);
                });
        }

        // Fetch data for Placement  if visible
        if (this.menuList[4].isVisible) {

            getPlacementSummaryDetails()
                .then(data => {

                    if (data) {

                        this.menuList[4].body.item1.headingValue = data.upcomingDriveDate;
                        this.menuList[4].body.item2.headingValue = data.totalDrives;
                        this.menuList[4].body.item3.headingValue = data.offerCount;

                    }

                })
                .catch(error => {

                    this.showErrorToast(error.body.message);
                });
        }
    }

    // Helper method to format the currency
    formatCurrency(value) {
        if (value !== null && value !== undefined) {
            // Formatter for Indian Rupee currency
            const formatter = new Intl.NumberFormat('en-IN', {
                style: 'currency',
                currency: 'INR',
                minimumFractionDigits: 2
            });
            return formatter.format(value);
        } else {
            return 'N/A';
        }
    }

    //Error Notification
    showErrorToast(errorMessage) {
        const event = new ShowToastEvent({
            title: 'Error',
            message: errorMessage,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

 */

}