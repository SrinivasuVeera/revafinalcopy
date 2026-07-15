import { LightningElement, api , wire} from 'lwc';
import getTrainingMaterialData from '@salesforce/apex/rpl_Placement_Training_Controller.getTrainingMaterialData';
import Static_Resources from '@salesforce/resourceUrl/RPL_Static_Resources';

export default class Rpl_RevaTrainingMaterial extends LightningElement {

    @api schoolName;
    @api activeSemester;
    openModal;
    mainTopic = '';
    subTopic = '';
    targetToAchieve = '';
    numberOfHours = '';
    showNoMaterial = true;
    //isSpinner = true;
    connectedCallback() {
        console.log(JSON.stringify(this.schoolName));
          console.log(JSON.stringify(this.activeSemester));

    }
    data;
    icon1 = Static_Resources + '/Reva_Placement_Static_Resources/Icons/1.png';
    icon2 =  Static_Resources + '/Reva_Placement_Static_Resources/Icons/2.png';
    icon3 = Static_Resources + '/Reva_Placement_Static_Resources/Icons/3.png';
    icon4 =  Static_Resources + '/Reva_Placement_Static_Resources/Icons/4.png';
    icon5 = Static_Resources + '/Reva_Placement_Static_Resources/Icons/5.png';
    icon6 =  Static_Resources + '/Reva_Placement_Static_Resources/Icons/6.png';
    icon7 = Static_Resources + '/Reva_Placement_Static_Resources/Icons/7.png';
    icon8 =  Static_Resources + '/Reva_Placement_Static_Resources/Icons/8.png';
    icon9 = Static_Resources + '/Reva_Placement_Static_Resources/Icons/9.png';
  
    handleCardClick(event){
        this.openModal = true;
        const moduleName = event.currentTarget.dataset.module;
        const selectedModule = this.data.find(module => module.Rpl_Main_Topic__c === moduleName);
        if(selectedModule){
            this.mainTopic = selectedModule.Rpl_Main_Topic__c;
            this.subTopic = selectedModule.Rpl_Sub_Topic__c;
            this.targetToAchieve = selectedModule.Rpl_Target__c;
            this.numberOfHours = selectedModule.Rpl_No_of_Hours__c;
        }
    }
    handleModalClose(){
        this.openModal = false;
    }
    @wire(getTrainingMaterialData, {semesterNumber: '$activeSemester' , schoolName: '$schoolName'})
    wiredTrainingMaterial({data, error}){
        if(data){
            this.isSpinner = false;
            if(data && data.length ==0){
                this.showNoMaterial = true;
                return;
            }
             this.showNoMaterial = false;
            this.data = data.map((module,index) => {
                index += 1;
                let number = 0;
                if(index <= 9){
                    number = index;
                }
                else if(index >= 10 && index <= 18){
                    number = index - 9;
                }else if(index >=19 && index <=27){
                    number = index - 18;
                }else if(index >= 28 && index <= 36){
                    number = index - 27;
                }else{
                    number = index - 36;
                }
                let imgUrl = `icon${number}`;
              
                return {...module, 
                    imgUrl :this[imgUrl],
                }
            })
        } else if (error) {
            console.error('Error when fetching training material data', error);
            this.isSpinner = false;

        }
        
    }
    
}