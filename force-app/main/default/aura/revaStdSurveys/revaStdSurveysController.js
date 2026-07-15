({
    redirectToSurveyPage: function (component, event, helper) {

        var surveyPageUrl = "/student-feedback-on-curriculum"; 


        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": surveyPageUrl
        });
        urlEvent.fire();
    },

    redirectToSurveyMentorPage: function (component, event, helper) {
        var secondPageUrl = "/survey-test"; 

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": secondPageUrl
        });
        urlEvent.fire();
    }
})