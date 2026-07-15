/**
 * @description       : 
 * @author            : owais.ahanger@cloudodyssey.co
 * @group             : 
 * @last modified on  : 05-20-2024
 * @last modified by  : owais.ahanger@cloudodyssey.co
**/
({
    handleResize: function (component) {
        var isMobile = window.innerWidth <= 800;
        component.set("v.isMobile", isMobile);
    }

})