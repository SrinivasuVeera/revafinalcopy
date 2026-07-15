public class ASM_ResultTrgHandler {
    public static void linkParents(List<hed__Term_Grade__c> list_Results){
        Set<Id> set_CrsConIds = new Set<Id>();
        List<hed__Term_Grade__c> list_ResultsMatch = new List<hed__Term_Grade__c>();
        for(hed__Term_Grade__c res : list_Results){
            if(res.hed__Course_Connection__c != null){
                set_CrsConIds.add(res.hed__Course_Connection__c);
                list_ResultsMatch.add(res);
            }
        }
        
        if(set_CrsConIds.isEmpty()) return;
        Map<Id,hed__Course_Enrollment__c> map_CrsConn = new Map<Id,hed__Course_Enrollment__c>(
            [SELECT Id,hed__Course_Offering__c,hed__Program_Enrollment__c,hed__Program_Enrollment__r.Semester__c,Course_Offering_Section_ID__c,Semester_Name__c FROM hed__Course_Enrollment__c WHERE Id IN: set_CrsConIds]);
        
        Set<String> semesterNames = new Set<String>();
        for(hed__Course_Enrollment__c ce : map_CrsConn.values()){
            if(String.isNotBlank(ce.Semester_Name__c)){
                semesterNames.add(ce.Semester_Name__c);
            }
        }
        
        Map<String, Id> map_TermNameToId = new Map<String, Id>();
        for(hed__Term__c term : [SELECT Id, Name FROM hed__Term__c WHERE Name IN :semesterNames]){
            map_TermNameToId.put(term.Name, term.Id);
        }
        
        for(hed__Term_Grade__c res : list_ResultsMatch){            
            if(map_CrsConn.containsKey(res.hed__Course_Connection__c)){                
                hed__Course_Enrollment__c crsCon = map_CrsConn.get(res.hed__Course_Connection__c);    
                res.hed__Course_Offering__c = crsCon.Course_Offering_Section_ID__c;                
                if(String.isNotBlank(crsCon.Semester_Name__c) &&
                   map_TermNameToId.containsKey(crsCon.Semester_Name__c)){                       
                       res.hed__Term__c = map_TermNameToId.get(crsCon.Semester_Name__c);
                   }
            }
        }
    }
    public static void rollupTotals(List<hed__Term_Grade__c> list_Results){
        Map<Id,hed__Term_Grade__c> map_SummaryIds = new Map<Id,hed__Term_Grade__c>();
        for(hed__Term_Grade__c res : list_Results){
            if(res.Result_Summary__c != null){
                map_SummaryIds.put(res.Result_Summary__c,new hed__Term_Grade__c(Id=res.Result_Summary__c,Total_Maximum_Marks_Semester__c=0,Total_Secured_Marks_Semester__c=0));
            }
        }
        if(!map_SummaryIds.isEmpty()){
            for(hed__Term_Grade__c child : [SELECT Id,Total_Maximum_Marks_Course__c,Total_Secured_Marks_Course__c,hed__Term__c,Result_Summary__c FROM hed__Term_Grade__c WHERE Result_Summary__c IN: map_SummaryIds.keySet()]){
                map_SummaryIds.get(child.Result_Summary__c).hed__Term__c= child.hed__Term__c;
                if(child.Total_Secured_Marks_Course__c != null) map_SummaryIds.get(child.Result_Summary__c).Total_Secured_Marks_Semester__c += child.Total_Secured_Marks_Course__c;
                if(child.Total_Maximum_Marks_Course__c != null) map_SummaryIds.get(child.Result_Summary__c).Total_Maximum_Marks_Semester__c += child.Total_Maximum_Marks_Course__c;
            }
            Update map_SummaryIds.values();
        }
    }
}