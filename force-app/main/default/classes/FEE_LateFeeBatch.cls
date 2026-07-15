global class FEE_LateFeeBatch implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        Date todayDate = System.today();
        String Str_Feetype =Label.Exclude_Late_Fee_Charges_Fee_Type;
        set<String> Set_Feetype = new set<string>();
        Set_Feetype.addAll(Str_Feetype.split(','));
        return database.getQueryLocator([Select Id, Name,Due_Date__c,Fee_Payment_Criteria__c,Fee_Type__c,No_of_Days_Due__c,Contact__c,Contact__r.Student_Status__c,Contact__r.Name,Parent_Student_Fee__c, 
                                         Amount_Pending__c,Program_Enrollment__c,Program_Enrollment__r.hed__Program_Plan__c,
                                         Program_Enrollment__r.hed__Program_Plan__r.Exclude_Late_Fee_Charges_PB__c,Amount__c,
                                         Contact__r.Exclude_Late_Fee_Charges_Student__c,Exclude_Late_Fee_Charges_Fee__c
                                         from Student_Fee__c where Amount_Pending__c > 0 AND Due_Date__c <: todayDate
                                         AND Program_Enrollment__r.hed__Program_Plan__c != null AND
                                         Program_Enrollment__r.hed__Program_Plan__r.Exclude_Late_Fee_Charges_PB__c =: FALSE
                                         AND Contact__r.Exclude_Late_Fee_Charges_Student__c =: FALSE AND Contact__r.Student_Status__c =: 'Pursuing' and 
                                         Exclude_Late_Fee_Charges_Fee__c =: FALSE AND Fee_Type__c Not in: Set_Feetype
                                         and Parent_Student_Fee__c =: null  order by LastModifiedDate]);
    }
    global void execute(Database.BatchableContext Bc, List<Student_Fee__c> lst_StuFee)
    {
        map<id,list<Late_Fee_Charges__c>> map_Latefee = new map<id,list<Late_Fee_Charges__c>>();
        List<Student_Fee__c> lst_InsertStuFee = new List<Student_Fee__c>();
        List<Student_Fee__c> lst_UpdateStuFee = new List<Student_Fee__c>();
        List<Student_Fee__c> lst_DailyStuFee = new List<Student_Fee__c>();
        set<id> set_ProgBatchId = new set<id>();
        set<id> set_StuFeeId = new set<id>();
        for(Student_Fee__c objStufee : lst_StuFee)
        { 
            set_StuFeeId.add(objStufee.Id);
            set_ProgBatchId.add(objStufee.Program_Enrollment__r.hed__Program_Plan__c);
        }
        if(set_ProgBatchId.size() >0)
        {
            for(Late_Fee_Charges__c objLateFee : [Select Id,Name,Amount__c,Fee_Type__c,From_Day__c,Late_Fee_Calculation_Type__c,
                                                  Program__c,Program_Batch__c,School__c,To_Day__c from Late_Fee_Charges__c
                                                  where Program_Batch__c in: set_ProgBatchId])
            {
                if(map_Latefee.get(objLateFee.Program_Batch__c) == null)
                {
                    list<Late_Fee_Charges__c> lst_fee = new list<Late_Fee_Charges__c>();
                    lst_fee.add(objLateFee);
                    map_Latefee.put(objLateFee.Program_Batch__c,lst_fee);
                }
                else
                {
                    map_Latefee.get(objLateFee.Program_Batch__c).add(objLateFee);
                }
            }
            Integer MaxDays =Integer.valueof(Label.FEE_Late_Fee_Maximum_Days);
            Decimal FAmount=0;
            Decimal InFAmount =0;
            for(Student_Fee__c objStufee : [Select Id, Name,Due_Date__c,Fee_Payment_Criteria__c,Amount__c,No_of_Days_Due__c,Fee_Type__c,Contact__c,Contact__r.Name,Parent_Student_Fee__c, 
                                            Amount_Pending__c,Program_Enrollment__c,Program_Enrollment__r.hed__Program_Plan__c,
                                            (select id,Name,Amount__c,No_of_Days_Due__c from Student_Fees__r)
                                            from Student_Fee__c where id in:set_StuFeeId order by LastModifiedDate])
            { 
                integer NoOfDay =  Integer.valueof(objStufee.No_of_Days_Due__c);
                if(MaxDays < objStufee.No_of_Days_Due__c)
                {
                    NoOfDay = MaxDays;
                }
                if(NoOfDay <= MaxDays)
                {                    
                    if(objStufee.Student_Fees__r.size()>0)
                    {
                        for(Student_Fee__c ChildFee : objStufee.Student_Fees__r)
                        {
                            if(map_Latefee.get(objStufee.Program_Enrollment__r.hed__Program_Plan__c) != null)
                            {
                                 FAmount =0;
                                Student_Fee__c stufeeDate = new Student_Fee__c();                                
                                for(Late_Fee_Charges__c ObjLateFee : map_Latefee.get(objStufee.Program_Enrollment__r.hed__Program_Plan__c))
                                {
                                    if(objStufee.Fee_Type__c == ObjLateFee.Fee_Type__c && 
                                       ObjLateFee.Late_Fee_Calculation_Type__c =='Daily Basis')
                                    {
                                        stufeeDate.Name = objStufee.Name+' - Late Fee';
                                        stufeeDate.Fee_Type__c = ObjLateFee.Fee_Type__c;
                                        stufeeDate.Amount__c = ObjLateFee.Amount__c * NoOfDay; 
                                            //ChildFee.Amount__c + (ObjLateFee.Amount__c * (NoOfDay - ChildFee.Late_Fee_Due_Days__c)); //ObjLateFee.Amount__c * NoOfDay ;
                                        stufeeDate.Id = ChildFee.Id;
                                        //stufeeDate.Late_Fee_Due_Days__c = NoOfDay;
                                        stufeeDate.Amount_Pending__c = stufeeDate.Amount__c;
                                    }
                                    else if(objStufee.Fee_Type__c == ObjLateFee.Fee_Type__c &&
                                            ObjLateFee.Late_Fee_Calculation_Type__c =='Date Range')
                                    {
                                        stufeeDate.Name = objStufee.Name+' - Late Fee';
                                        stufeeDate.Fee_Type__c = ObjLateFee.Fee_Type__c;
                                        
                                        if(NoOfDay >= ObjLateFee.To_Day__c)
                                        {
                                            decimal Diffdays =   math.abs(ObjLateFee.To_Day__c - ObjLateFee.From_Day__c)+1;
                                            FAmount = FAmount + (ObjLateFee.Amount__c * Diffdays);
                                        }
                                        else if(ObjLateFee.From_Day__c <= NoOfDay)
                                        {
                                            decimal Diffdays = math.abs(ObjLateFee.From_Day__c - NoOfDay) +1 ;                                           
                                            FAmount = FAmount + (ObjLateFee.Amount__c * Diffdays);     //ObjLateFee.Amount__c * Diffdays;
                                        }
                                        else
                                        {
                                            FAmount = ChildFee.Amount__c;
                                        }
                                        stufeeDate.Amount__c = FAmount ;
                                        //stufeeDate.Late_Fee_Due_Days__c = NoOfDay;
                                        stufeeDate.Amount_Pending__c = stufeeDate.Amount__c;                                      
                                        stufeeDate.Id = ChildFee.Id;
                                    }
                                }
                                lst_UpdateStuFee.add(stufeeDate);
                            }
                        }   
                    }
                    else
                    {
                        if(map_Latefee.get(objStufee.Program_Enrollment__r.hed__Program_Plan__c) != null)
                        {
                            InFAmount =0;
                            Student_Fee__c stufee = new Student_Fee__c();
                            for(Late_Fee_Charges__c ObjLateFee : map_Latefee.get(objStufee.Program_Enrollment__r.hed__Program_Plan__c))
                            {                                 
                                if(objStufee.Fee_Type__c == ObjLateFee.Fee_Type__c && 
                                   ObjLateFee.Late_Fee_Calculation_Type__c =='Daily Basis')
                                {
                                    stufee.Name = objStufee.Name+' - Late Fee';
                                    stufee.Fee_Type__c = ObjLateFee.Fee_Type__c;
                                    stufee.Amount__c = ObjLateFee.Amount__c * NoOfDay;
                                    stufee.Parent_Student_Fee__c = objStufee.id;
                                    stufee.Number_of_Installments__c=1;
                                    stufee.Amount_Pending__c = stufee.Amount__c;
                                    stufee.Contact__c = objStufee.Contact__c;
                                    stufee.Fee_Payment_Criteria__c = objStufee.Fee_Payment_Criteria__c;
                                    //stufee.Late_Fee_Due_Days__c = NoOfDay;
                                    stufee.Due_Date__c = objStufee.Due_Date__c;
                                   // lst_InsertStuFee.add(stufee);
                                }
                                else if(objStufee.Fee_Type__c == ObjLateFee.Fee_Type__c &&
                                        ObjLateFee.Late_Fee_Calculation_Type__c =='Date Range')                              
                                {                                            
                                    stufee.Name = objStufee.Name+' - Late Fee';
                                    stufee.Fee_Type__c = ObjLateFee.Fee_Type__c;
                                    stufee.Parent_Student_Fee__c = objStufee.id;
                                    stufee.Number_of_Installments__c=1;
                                    stufee.Contact__c = objStufee.Contact__c;
                                    stufee.Fee_Payment_Criteria__c = objStufee.Fee_Payment_Criteria__c;
                                    //stufee.Late_Fee_Due_Days__c = NoOfDay;
                                    if(NoOfDay >= ObjLateFee.To_Day__c)
                                    {                                        
                                        decimal Diffdays =   math.abs(ObjLateFee.To_Day__c - ObjLateFee.From_Day__c)+1;
                                        InFAmount = InFAmount + ObjLateFee.Amount__c * Diffdays;
                                    }
                                    else if(ObjLateFee.From_Day__c <= NoOfDay)
                                    {
                                        decimal Diffdays =  math.abs(ObjLateFee.From_Day__c - NoOfDay)+1;
                                        InFAmount = InFAmount + ObjLateFee.Amount__c * Diffdays;                                       
                                    }
                                    stufee.Amount__c = InFAmount ;
                                    stufee.Due_Date__c = objStufee.Due_Date__c;
                                    stufee.Amount_Pending__c = stufee.Amount__c;
                                    
                                }                                
                            }
                            if(stufee.Amount__c >0 )
                            lst_InsertStuFee.add(stufee);
                        }
                    }
                }
            }
        }
        if(lst_InsertStuFee.size() >0)
        {
            insert lst_InsertStuFee;
        }
        if(!lst_UpdateStuFee.isEmpty())
        {
            update lst_UpdateStuFee;
        }
    }
    global void finish(DataBase.BatchableContext bc)
    {
        
    }
}