import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
import STUDENTPORTALICONS from '@salesforce/resourceUrl/NTS_Portal_Static_Resources';
import checkIfMessAdmin from '@salesforce/apex/RevaMealBookingController.checkIfMessAdmin';
import checkIfGuestHouseManager from '@salesforce/apex/RevaGuestHouseController.checkIfGuestHouseManager';
import isCaseOwner from '@salesforce/apex/CaseController.isCaseOwner';
import getSupportRequestDetails from '@salesforce/apex/SP_FetchStudentDetailsController.getSupportRequestLatestCase';
import hasExistingHostelRequest from '@salesforce/apex/RevaHostelRequestController.hasExistingHostelRequest';
import checkMessSupportTeam from '@salesforce/apex/RevaMealBookingController.checkIfMessSupportTeam';
import checkIfSecurityUser from '@salesforce/apex/RevaHostelLeaveRequestController.isSecurityUser';

 
const baseImageUrl = `${STUDENTPORTALICONS}/NTS_Portal_Static_Resources/NTS_Icons/`;
 
export default class RevInfraSupportHomeMenuTile extends NavigationMixin(LightningElement) {
    @track menuList = [];
 
    connectedCallback() {
        this.initializeMenu();
    }
 
    async initializeMenu() {
        try {
            const hasRevaMessPermission = await checkIfMessAdmin();
            const hasGuestHouseManager = await checkIfGuestHouseManager();
            const hasCaseOwner = await isCaseOwner();
            const hasHostelrequest = await hasExistingHostelRequest();
            const hasMessSupportTeam = await checkMessSupportTeam();
            const hasSecurityUser = await checkIfSecurityUser();
            const allMenuItems = [
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
            headingName: 'VEHICLE REQUEST/ROUTE CHANGE REQUEST',
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
            Id: 'Manodhaara',
            headingName: 'MANODHAARA',
            
            url: `${basePath}/manodhaara`,
            imageUrl: `${baseImageUrl}manodhara.png`,
            body: {
                item1: {
                    headingText: 'NA',
                    headingValue: 'N/A'
                },
                item2: {
                    headingText: 'NA',
                    headingValue: 'N/A'
                }
            }

        },
                
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
                /*{
                    Id: 'RevaGuestHouseRequests',
                    headingName: 'REVA GUEST HOUSE BOOKING',
                    url: `${basePath}/reva-guest-house-requests`,
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
                },*/
                
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
                Id: 'RevaGuestHouseRequests',
                    headingName: 'REVA GUEST HOUSE REQUESTS',
                    url: `${basePath}/reva-guest-house-requests`,
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
                    Id: 'SupportRequest',
                    //isVisible: false,  //Default Visible
                    headingName: 'SUPPORT REQUEST',
        
                    url: `${basePath}/support-request`,
                    imageUrl: `${baseImageUrl}service-quaters-request.png`,
                    body: {
                        item1: {
                            headingText: 'Support Id',
                            headingValue: 'N/A'
                        },
                        item2: {
                            headingText: 'Support Status',
                            headingValue: 'N/A'
                        },
                       /* item3: {
                            headingText: 'Request Type',
                            headingValue: 'N/A'
                        },*/
                    }
        
                },
                {
                    Id: 'BrandingCaseManagement',                    
                    headingName: 'BRANDING CASE MANAGEMENT',        
                    url: `${basePath}/branding-case-mangament`,
                    imageUrl: `${baseImageUrl}service-quaters-request.png`,
                    body: {
                        item1: {
                            headingText: 'Support Id',
                            headingValue: 'N/A'
                        },
                        item2: {
                            headingText: 'Support Status',
                            headingValue: 'N/A'
                        },                      
                    }
        
                },
            ];
 
            if (hasRevaMessPermission) {
                console.log('Adding RevaMessManagement tile');
                allMenuItems.push({
                    Id: 'RevaMessManagement',
                    headingName: 'REVA MESS MANAGEMENT',
                    url: `${basePath}/reva-mess-management`,
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
                });
            }
            /*****Newly added for the security user******/
            if(hasSecurityUser){
                console.log('Adding Leave QR code scanner tile');
                allMenuItems.push({
                    Id: 'Hostel Leave QR Scanner',
                    headingName: 'Hostel Leave QR Scanner',
                    url: `${basePath}/leavemanagement`,
                    imageUrl: `${baseImageUrl}hostel-request.png`,
                    body: {
                        item1: {
                            headingText: 'Request ID',
                            headingValue: 'N/A'
                        },
                        item2: {
                            headingText: 'Leave QR',
                            headingValue: 'N/A'
                        }
                    }
                });
            }
            /************************************** */

            /*************/
            if (hasCaseOwner) {
                console.log('checking whether caseowner or not');
                allMenuItems.push({
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
                });
            }
            /********** */
            /***********************/
             //hasHostelrequest ||  removed meal booking tile for other than messteam
            if ( hasRevaMessPermission ||hasMessSupportTeam) {
                console.log('checking whether HostelRequest is there or not');
                allMenuItems.push({
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
                });
            }
            /**********************/
            if (hasMessSupportTeam || hasRevaMessPermission ) {
                console.log('checking whether MessSupport team permission  is there or not');
                allMenuItems.push({
                    Id: 'Meal QR Scanner',
                    headingName: 'Meal QR Scanner',
                    url: `${basePath}/mealqrscanner`,
                    imageUrl: `${baseImageUrl}book-meals.png`,
                    body: {
                        item1: {
                            headingText: 'Request ID',
                            headingValue: 'N/A'
                        },
                        item2: {
                            headingText: 'Meal QR',
                            headingValue: 'N/A'
                        }
                    }
                });
            }
 
            this.menuList = allMenuItems;
 
        } catch (error) {
            console.error('Error checking permission:', error);
        }
    }
}