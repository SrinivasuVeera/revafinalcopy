({

    render: function (component, helper) {
        var ret = this.superRender();
        // Attach resize event listener
        window.addEventListener('resize', $A.getCallback(function () {
            helper.handleResize(component);
        }));
        return ret;
    },

    afterRender: function (component, helper) {
        this.superAfterRender();
        helper.handleResize(component);
    },

    unrender: function () {
        this.superUnrender();
        window.removeEventListener('resize', $A.getCallback(function () {
        }));
    }
})