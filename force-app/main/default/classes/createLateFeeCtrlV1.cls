public class createLateFeeCtrlV1{

    @AuraEnabled
    public static lfMainWrp getFeeTypeDetails(){
        lfMainWrp mainWrp = new lfMainWrp();
        mainWrp.mapFeeModePickVal = new map<string,string>();
        mainWrp.mapFeeTypePickVal = new map<string,string>();
        mainWrp.mapSchoolPickVal = new map<string,string>();
        mainWrp.mapProgramPickVal = new map<string,string>();
        mainWrp.selectedProgram = new list<string>();
        mainWrp.lateFee = new list<lfSubWrp>();
        lfSubWrp objSub = new lfSubWrp();
        mainWrp.lateFee.add(objSub);
                
        Schema.DescribeFieldResult fieldResult = Late_Fee_Charges__c.Late_Fee_Calculation_Type__c.getDescribe();        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {           
            mainWrp.mapFeeModePickVal.put(p.getValue(), p.getLabel());
        }
        
        Schema.DescribeFieldResult fieldResult1 = Late_Fee_Charges__c.Fee_Type__c.getDescribe();        
        List<Schema.PicklistEntry> pValues1 = fieldResult1.getPicklistValues();
        for (Schema.PicklistEntry p1 : pValues1) {           
            mainWrp.mapFeeTypePickVal.put(p1.getValue(), p1.getLabel());
        }        
        
        Map<string,string> mapSchools = new Map<string,string>();
        string rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        for(account acc : [SELECT id,Name FROM Account WHERE recordTypeId =: rtId]){
            mainWrp.mapSchoolPickVal.put(acc.id,acc.Name);
        }         
    
        return mainWrp;
    }

    @AuraEnabled
    public static Map<string,string> getProgramDetails(string schoolId){
        Map<string,string> mapprograms = new Map<string,string>();
        for(account acc : [SELECT id,Name FROM Account WHERE parentId =: schoolId]){
            mapprograms.put(acc.id,acc.Name);
        }
        return mapprograms;
    }
    
    @AuraEnabled
    public static list<wrpCls> getProgramBatchDetails(string selectedFeeType,list<string> selectedPgm){
        list<wrpCls> lstWrp = new list<wrpCls>();
        system.debug('+++++++++'+selectedFeeType);
        system.debug('+++++++++'+selectedPgm);
        for(hed__Program_Plan__c pp : [SELECT id,Name,hed__Account__c,hed__Account__r.parentId,(SELECT id,Name FROM Late_Fee_Charges2__r 
                                       WHERE Fee_Type__c =: selectedFeeType limit 1) FROM hed__Program_Plan__c 
                                       WHERE hed__Account__c =: selectedPgm AND Active__c = true]){
                                       
            wrpCls objWrp = new wrpCls();
            objWrp.isChecked = false;
            objWrp.id = pp.id;
            objWrp.programId = pp.hed__Account__c;
            objWrp.schoolId = pp.hed__Account__r.parentId;
            objWrp.Name = pp.Name;
            if(pp.Late_Fee_Charges2__r.size() > 0){
                objWrp.exRecord = true;
                objWrp.lateFeeId = pp.Late_Fee_Charges2__r[0].id;
                objWrp.lateFeeName = pp.Late_Fee_Charges2__r[0].Name;
            }
            else{
                objWrp.exRecord = false;
            }
            lstWrp.add(objWrp);                               
        }
        return lstWrp;
    }
    
    @AuraEnabled
    public static updateMainWrp selectUpdateLateFee(string batchId,string feeType,string feeMode){
        updateMainWrp mainWrp = new updateMainWrp();
        mainWrp.lateFee = new list<lfSubWrp>();
        for(hed__Program_Plan__c pp : [SELECT id,Name,hed__Account__c,hed__Account__r.parentId,(SELECT id,Name,Fee_Type__c,Amount__c,From_Day__c,
                                       Late_Fee_Calculation_Type__c,To_Day__c FROM Late_Fee_Charges2__r 
                                       WHERE Fee_Type__c =: feeType ) FROM hed__Program_Plan__c 
                                       WHERE id =: batchId AND Active__c = true]){
            mainWrp.selectedSchool = pp.hed__Account__r.parentId;
            mainWrp.selectedProgram = pp.hed__Account__c;
            mainWrp.selectedBatch = batchId;
            mainWrp.selectedMode = pp.Late_Fee_Charges2__r[0].Late_Fee_Calculation_Type__c;
            mainWrp.selectedFeeType = pp.Late_Fee_Charges2__r[0].Fee_Type__c;
            mainWrp.previusMode = pp.Late_Fee_Charges2__r[0].Late_Fee_Calculation_Type__c; 
            mainWrp.totAmount = pp.Late_Fee_Charges2__r[0].Amount__c;                      
            for(Late_Fee_Charges__c lf : pp.Late_Fee_Charges2__r){
                lfSubWrp objFee = new lfSubWrp();
                objFee.recordId = lf.id;
                objFee.FromDay = lf.From_Day__c;
                objFee.totDay = lf.To_Day__c;
                objFee.totAmount = lf.Amount__c; 
                mainWrp.lateFee.add(objFee);
            }
        }
        return mainWrp;
    }
    
    @AuraEnabled
    public static string insertLateFee(string feeType,string feeMode,list<string> deletedIds,list<string> prgIds,list<lfSubWrp> lstSubFee,
                                       list<string> batchIds,boolean isInsert,decimal totAmount,string batchId){
        
        system.debug('feeType+++++++'+feeType);
        system.debug('feeMode+++++++'+feeMode);
        system.debug('deletedIds+++++++'+deletedIds);
        system.debug('prgIds+++++++'+prgIds);
        system.debug('lstSubFee+++++++'+lstSubFee);
        system.debug('batchIds+++++++'+batchIds);
        system.debug('isInsert+++++++'+isInsert);
        system.debug('totAmount+++++++'+totAmount);
        system.debug('batchId+++++++'+batchId);
        list<Late_Fee_Charges__c> lstLateFee = new list<Late_Fee_Charges__c>();
        list<Late_Fee_Charges__c> lstDeleteLateFee = new list<Late_Fee_Charges__c>();
        /*
        list<string> prgBatchIds = new list<string>();
        if(isInsert){
            prgBatchIds = batchIds;
        }
        else{
            prgBatchIds.add(batchId);
        }
        
        set<string> delIds = new set<string>();
        delIds.addAll(deletedIds);
        if(feeMode == 'Daily Basis'){
            for(Late_Fee_Charges__c lf : [SELECT id FROM Late_Fee_Charges__c WHERE Program_Batch__c =: prgBatchIds]){
                delIds.add(lf.id);
            }
        }
        system.debug('batchId+++++++'+delIds);
        for(Late_Fee_Charges__c lf : [SELECT id FROM Late_Fee_Charges__c WHERE id =: delIds]){
            lstDeleteLateFee.add(lf);
        }
        if(lstDeleteLateFee.size() > 0){
            delete lstDeleteLateFee;
        }
        */
        system.debug('batchId+++++++'+batchIds);
            for(hed__Program_Plan__c pp : [SELECT id,Name,hed__Account__c,hed__Account__r.parentId FROM hed__Program_Plan__c 
                                           WHERE id =: batchIds]){
                if(feeMode == 'Date Range'){
                    for(lfSubWrp wrp : lstSubFee){
                        Late_Fee_Charges__c objLf = new Late_Fee_Charges__c(); 
                        if(string.isNotBlank(wrp.recordId)){
                            objLf.id = wrp.recordId;    
                        }                                       
                        objLf.Fee_Type__c = feeType;
                        objLf.Late_Fee_Calculation_Type__c = feeMode;
                        objLf.Program_Batch__c = pp.id;
                        objLf.Program__c = pp.hed__Account__c;
                        objLf.School__c = pp.hed__Account__r.parentId;                    
                        objLf.Amount__c = wrp.totAmount;
                        objLf.From_Day__c = wrp.FromDay;
                        objLf.To_Day__c = wrp.totDay;             
                        lstLateFee.add(objLf);              
                    }
                }
                if(feeMode == 'Daily Basis'){
                    Late_Fee_Charges__c objLf = new Late_Fee_Charges__c(); 
                    objLf.Fee_Type__c = feeType;
                    objLf.Late_Fee_Calculation_Type__c = feeMode;
                    objLf.Program_Batch__c = pp.id;
                    objLf.Program__c = pp.hed__Account__c;
                    objLf.School__c = pp.hed__Account__r.parentId;
                    objLf.Amount__c = totAmount; 
                    lstLateFee.add(objLf);
                }            
            }
            system.debug('lstLateFee.size+++++++'+lstLateFee.size());
            if(lstLateFee.size() > 0){
                insert lstLateFee;
            }
            system.debug('lstLateFee+++++++'+lstLateFee);
        
        return 'Success';
    }
    
    @AuraEnabled
    public static string UpdateLateFee(string batchId,string feeType,string feeMode,updateMainWrp mainRec){
        system.debug('batchId++++++'+batchId);
        system.debug('feeType++++++'+feeType);
        system.debug('feeMode++++++'+feeMode);
        system.debug('mainRec++++++'+mainRec);
        
        list<Late_Fee_Charges__c> lstLf = new list<Late_Fee_Charges__c>();
        for(Late_Fee_Charges__c lf : [SELECT id FROM Late_Fee_Charges__c WHERE Program_Batch__c =: batchId AND Fee_Type__c =: mainRec.selectedFeeType]){
            lstLf.add(lf);                                   
        }
        
        if(lstLf.size() > 0){
            delete lstLf;
        }
        
        list<Late_Fee_Charges__c> lstLateFee = new list<Late_Fee_Charges__c>();
        
        if(mainRec.selectedMode == 'Date Range'){
            for(lfSubWrp wrp : mainRec.lateFee){
                Late_Fee_Charges__c objLf = new Late_Fee_Charges__c();
                objLf.Fee_Type__c = feeType;
                objLf.Late_Fee_Calculation_Type__c = mainRec.selectedMode;
                objLf.Program_Batch__c = batchId;
                objLf.Program__c = mainRec.selectedProgram;
                objLf.School__c = mainRec.selectedSchool;                    
                objLf.Amount__c = wrp.totAmount;
                objLf.From_Day__c = wrp.FromDay;
                objLf.To_Day__c = wrp.totDay;             
                lstLateFee.add(objLf);
            }
        }
        
        if(mainRec.selectedMode == 'Daily Basis'){
            Late_Fee_Charges__c objLf = new Late_Fee_Charges__c();
            objLf.Fee_Type__c = feeType;
            objLf.Late_Fee_Calculation_Type__c = mainRec.selectedMode;
            objLf.Program_Batch__c = batchId;
            objLf.Program__c = mainRec.selectedProgram;
            objLf.School__c = mainRec.selectedSchool;
            objLf.Amount__c = mainRec.totAmount; 
            lstLateFee.add(objLf);
        }
        system.debug('lstLateFee++++++'+lstLateFee);
        if(lstLateFee.size() > 0){
            insert lstLateFee;
        }
        return 'Success';
    }
    
                                       
    public class wrpCls{
        @AuraEnabled public boolean isChecked{get;set;}
        @AuraEnabled public string id{get;set;}
        @AuraEnabled public string programId{get;set;}
        @AuraEnabled public string schoolId{get;set;}
        @AuraEnabled public string Name{get;set;}
        @AuraEnabled public boolean exRecord{get;set;}
        @AuraEnabled public string lateFeeId{get;set;}
        @AuraEnabled public string lateFeeName{get;set;}
    }
    
    public class lfMainWrp{
        @AuraEnabled public map<string,string> mapFeeModePickVal{get;set;}
        @AuraEnabled public map<string,string> mapFeeTypePickVal{get;set;}
        @AuraEnabled public map<string,string> mapSchoolPickVal{get;set;}
        @AuraEnabled public map<string,string> mapProgramPickVal{get;set;}
        @AuraEnabled public string selectedSchool{get;set;}
        @AuraEnabled public list<string> selectedProgram{get;set;}
        @AuraEnabled public string selectedMode{get;set;}
        @AuraEnabled public string selectedFeeType{get;set;}
        @AuraEnabled public decimal totAmount{get;set;}
        @AuraEnabled public list<lfSubWrp> lateFee{get;set;}
    }
    
    public class lfSubWrp{
        @AuraEnabled public string recordId{get;set;}
        @AuraEnabled public decimal FromDay{get;set;}
        @AuraEnabled public decimal totDay{get;set;}
        @AuraEnabled public decimal totAmount{get;set;}
    }
    
    public class updateMainWrp{
        @AuraEnabled public string selectedSchool{get;set;}
        @AuraEnabled public string selectedProgram{get;set;}
        @AuraEnabled public string selectedBatch{get;set;}
        @AuraEnabled public string selectedMode{get;set;}
        @AuraEnabled public string selectedFeeType{get;set;}
        @AuraEnabled public string previusMode{get;set;}
        @AuraEnabled public decimal totAmount{get;set;}
        @AuraEnabled public list<lfSubWrp> lateFee{get;set;}
    }
}