$(document).ready(function(){
	$(".ajaxSearchField").each(function(){
		var jqObj = $(this);
		
		jqObj.autocomplete("/order/getAjaxField", {
			extraParams: {
				'fieldName': jqObj.attr("fieldName")
				},
				
				formatItem: function(item){
					return item[0]
				},
				
				matchCase: true,
				mustMatch: true
		});
	});
});
