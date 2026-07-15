({
    doInit: function (component, event, helper) {
        helper.doInitHelper(component, event, helper);
        helper.RecTypeHelper(component, event, helper);
    },
    onSubCatChange: function (component, event, helper) {
        helper.onSubCatChangeHelper(component, event, helper);
    },
    handleFilesChange: function (component, event, helper) {
        var files = event.getSource().get("v.files");
       console.log("Files:", files);
        var fileName = 'No File Selected';
        if (files && files.length > 0) {
        var fileName = files[0].name;
        console.log("Selected File Name:", fileName);

        // Store file list in an attribute
        component.set("v.uploadedFiles", files);
        
        // Clear additional fields
        component.set("v.Remarks", '');
        component.set("v.docRequired", '');
        component.set("v.fileName", fileName);
    }
    },
    saveCase: function (component, event, helper) {
        var files = component.get("v.uploadedFiles");
    console.log("Retrieved Files in saveCase:", files);
        helper.saveCaseHelper(component, event, helper,files);
    },
})