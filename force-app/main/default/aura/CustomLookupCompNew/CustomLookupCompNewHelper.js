({
    processResults : function(results, returnFields, searchText) {
        
        var regEx = null;
        if (searchText != null && searchText.length> 0) {
            regEx = new RegExp(searchText, 'gi');
        }
       //  alert('==for----'+JSON.stringify(results));
        for (var i = 0; i < results.length; i++) {
            
            results[i]['Field0'] = results[i][returnFields[0]].replace(regEx,'<mark>$&</mark>');
            for(var j = 1; j < returnFields.length; j++){
                var fieldValue = results[i][returnFields[j]];                
                if (fieldValue) {
                    if(j == 1){
                    results[i]['Field1'] = (results[i]['Field1'] || '') + ' • ' + fieldValue;
                    }		
                    if(j == 2){
                    	results[i]['Field2'] = (results[i]['Field2'] || '') + ' • ' + fieldValue;   
                    }                    
                    if(j == 3)
                    { 
                        results[i]['Field3'] = (results[i]['Field3'] || '') + ' • ' + fieldValue; 
                    }
                }    
            }
            if (results[i]['Field1']) {
                results[i]['Field1'] = results[i]['Field1'].substring(3).replace(regEx,'<mark>$&</mark>');
            }
            if (results[i]['Field2']) {
                results[i]['Field2'] = results[i]['Field2'].substring(3).replace(regEx,'<mark>$&</mark>');
            }
            if (results[i]['Field3']) 
            {                
                    results[i]['Field3'] = results[i]['Field3'].substring(3).replace(regEx,'<mark>$&</mark>');
            }
            else{
                
               results[i]['Field3'] = ''; 
            }
        }
        return results;
    }
})