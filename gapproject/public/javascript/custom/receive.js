
$(document).ready(function(){
	$(".numeric").numeric({ negative : false });
	$('#receiveForm').validate();
	
	$(".ajaxSearchField").each(function(){
		var jqObj = $(this);
		
		jqObj.autocomplete("/order/getAjaxField", {
			extraParams: {
				'fieldName': jqObj.attr("fieldName")
				},
				
				formatItem: function(item){
					return item[0];
				},
				
				matchCase: false,
				mustMatch: true
		});
	});
	
	// $("form").submit(function(){
	// 	$(".template").remove();
	// });
});


function toCancel(){
	if(confirm("The form hasn't been saved, are you sure to leave the page?")){
		return true;
	}else{
		return false;
	}
};


var toAdd = function(){
    var w = $('#tmp-warehouseID').val() || $('#warehouseID').val();
    if(w ||  (typeof w) === 'undefined'){
        $('#warehouseID').val(w);
        var url = '/receive/newSub';
window.open(url, 'SearchItem','height=600,width=800,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no, status=yes');  
    }else{
       $.prompt('Please select a warehouse first!',{opacity: 0.6,prefix:'cleanred'}); 
    }
};


function toConfirm(){
$.prompt("Are you sure to confirm these now?",
		{opacity: 0.6,
		 prefix:'cleanblue',
		 buttons:{'Yes':true,'No,Go Back':false},
		 focus : 1,
		 callback : function(v,m,f){
		 	if(v){
		 		$("#receiveForm").attr('action', '/receive/save');
		 		$("#receiveForm").submit();
		 	}
		 }
		}
	);
	
}
