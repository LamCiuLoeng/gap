function clearInput(obj,exclude){
	var t = $(obj).parents("table")[0];
	var excludeStr = "";
	
	if(exclude.length > 0){ 
		exclude.unshift("");
		exclude.push("");
		
		excludeStr = exclude.join("|");
	}
	
	$("input,select,textarea",t).each(function(){
		var temp = $(this);
		
		if( excludeStr.indexOf("|"+temp.attr("id")+"|") < 0 ){temp.val("");}
	});
}

/*
function changeItem(obj){
	var item = $(obj);
	
	if(!item.val()){
		return;
	}
	
	var width = item.val().split('|')[1];
	var length = item.val().split('|')[2];
	var gusset = item.val().split('|')[3];
	var lip = item.val().split('|')[4];
	var price = item.val().split('|')[5];

	item.parent().parent().find("td:nth-child(2)").text(width);
	item.parent().parent().find("td:nth-child(3)").text(length);
	item.parent().parent().find("td:nth-child(4)").text(gusset);
	item.parent().parent().find("td:nth-child(5)").text(lip);
	item.parent().parent().find("td:nth-child(6)").text(parseFloat(price) * 1000);
}
*/

function toCancel(){
	if(confirm("The form hasn't been saved,are you sure to leave the page?")){
		return true;
	}else{
		return false;
	}
}

var INDEX = 1;

function toAdd(){
	INDEX++;
	var c = $(".template");
	var tr = c.clone();
	$("input",tr).each(function(){
		var t = $(this);
		var n = t.attr("name").replace("_x","_"+INDEX);

		t.attr("name",n);
		if (t.attr("name").split("_")[0] == "item") {
			t.attr("class", "required ajaxSearchField input-style1-40fonts");
		} else {
			t.attr("class", "required numeric");
		}
	});

	var tr_id = tr.attr("id").replace("_x", "_"+INDEX);
	
	tr.attr("id", tr_id);
	tr.insertBefore(c[0]);
	tr.removeClass("template");
	tr.show();
	
	$(".numeric",tr).numeric();
	bindAutoComplete($(".ajaxSearchField",tr));
}

function toRemove(obj){
	var index = $(obj).attr("name").split("_")[1];
	
	$("#item_" + index + "_ext").remove();
}

$(document).ready(function(){
	$(".numeric").numeric();
	
	var dateFormat = 'yy-mm-dd';

    $('.datePicker').datepicker({firstDay: 1 , dateFormat: dateFormat});
	
	$("form").submit(function(){
		$(".template").remove();
	});
	
	$("#shipTel, #billTel, #shipFax, #billFax").keyup(function(){
		$(this).val($(this).val().replace(/[^0-9*#-]/g, ''));
	}).bind("paste", function(){
		$(this).val($(this).val().replace(/[^0-9*#-]/g, ''));
	}).css("ime-mode", "disabled");
	
	$("#shipInstruction").change(function(){
		if ($(this).val() == "BY OTHER") {
			$(".otherInstruction").show();
		} else {
			$(".otherInstruction").hide();
		}
	});
	
	$(".otherInstruction").hide();
	
	bindAutoComplete($(".ajaxSearchField"));
});



function toConfirm(){
	var valid = true;
	var intRegex = /^\d+$/;
	var msg = Array();

	if( !$("#shipCompany").val() ){msg.push("* Please select the 'Ship To' company!");}
	if( !$("#shipAddress").val() ){msg.push("* Please input the 'Ship To' address!");}
	if( !$("#billCompany").val() ){msg.push("* Please select the 'Bill To' company!");}
	if( !$("#billAddress").val() ){msg.push("* Please input the 'Bill To' address!");}
	/*if( !$("#buyerPO").val() ){msg.push("* Please input the 'Buyer PO#'!");};*/
	if( !$("#vendorPO").val() ){msg.push("* Please input the 'Vendor PO#'!");};
	/*if( !$("#rpacContact").val() ){msg.push("* Please select the 'r-pac Regional Contact'!");};*/
	
	
	var filled_rows = 0;
	var isQtyCorrect = true;
	var isItemDuplicate = false;
	var item_index_arr = [];
	$(".gridTable tbody tr").not('.template').each(function(){
	   var tmp = $(this);
	   var no = $("input[name^='item_']",tmp).val();
	   var q = $("input[name^='quantity_']",tmp).val();
	   if( no ){
    	   if(q){
    	       filled_rows++;
    	       if( parseInt(q) % 250 != 0 ){
        	       isQtyCorrect = false;
    	       }
    	   }
    	   if (jQuery.inArray(no, item_index_arr) == -1) {
               item_index_arr.push(no);
           }else{
               isItemDuplicate = true;
           }
	   } 
	});
	   	   
    if(!isQtyCorrect){ msg.push("* Please input quantity with correct number,which should be in a multiple number of 250 pcs!");};	
	if(filled_rows<1){ msg.push("* Please input at least one item and qty!"); }
	if (isItemDuplicate) {msg.push("* The items are duplicated!");}
	
	if( msg.length > 0 ){
		$.prompt(msg.join("<br />"),{opacity: 0.6,prefix:'cleanred'});
		return false;
	}else{
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
}

// ADD BY CL
function bindAutoComplete(selector){
    selector.each(function(){
        var jqObj = $(this);
        jqObj.autocomplete("/order/getAjaxField", {
            extraParams: {
                fieldName: jqObj.attr("fieldName"),
                region_id : $("input[name='region']").val()
                },
                formatItem: function(item){
                    return item[0]
                },
                mustMatch : true,
                matchCase: false
                //minChars : 2
        }).result(function(event, data, formatted){
            jqObj.parent().parent().find("td:nth-child(2)").text(data[2]);
            jqObj.parent().parent().find("td:nth-child(3)").text(data[3]);
            jqObj.parent().parent().find("td:nth-child(4)").text(data[4]);
            jqObj.parent().parent().find("td:nth-child(5)").text(data[5]);
            jqObj.parent().parent().find("td:nth-child(6)").text(data[6]);
            jqObj.val(formatted);
        });       
    });
}