$(function(){

    $(".ajaxSearchField").each(function(){
        var jqObj = $(this);
        var latest = $('form input[name=item_number]').val() || 0;
            jqObj.autocomplete("/inventory/getAjaxField", {
                    extraParams: {
                       fieldName: jqObj.attr("name"),
                       latest: latest
                    },
                    formatItem: function(item){
                           return item[0];
                    },
                    matchCase : false
            });

    });
});
