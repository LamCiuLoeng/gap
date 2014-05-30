$(document).ready(function(){
	var dateFormat = 'yy-mm-dd';

    $('.datePicker').datepicker({firstDay: 1 , dateFormat: dateFormat});
});

function toConfirm(){
	$.prompt("We are going to confirm your order information in our Production System upon your final confirmation.<br /> \
				 Are you sure to confirm the order now?",
	    		{opacity: 0.6,
	    		 prefix:'cleanblue',
	    		 buttons:{'Yes':true,'No,Go Back':false},
	    		 focus : 1,
	    		 callback : function(v,m,f){
	    		 	if(v){
	    		 		$("form").submit();
	    		 	}
	    		 }
	    		}
	    	);
}
