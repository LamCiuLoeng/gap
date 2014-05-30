$("document").ready(function(){
	$("#china_size_count").change(function(){
    	var count = $(this).val();
    	var origin_size = $("#china_size").parent().parent().clone();
    	var origin_size_kind = $("#china_size_kind").parent().parent().clone();
    	
    	$(".china_size").parent().parent().remove();
    	$(".china_size_kind").parent().parent().remove();
    	origin_size.insertAfter($("#china_size_count").parent().parent());
    	origin_size_kind.insertAfter($("#china_size").parent().parent());
    	
    	$("#china_size").attr("value", '');
    	$("#china_size_kind").attr("value", '');
    	
    	for (index = 1; index < count; index++) {
    		$("#china_size").parent().parent().clone().insertAfter($("#china_size").parent().parent());
    		$("#china_size_kind").parent().parent().clone().insertAfter($("#china_size_kind").parent().parent());
    	}
    });
    
    $("#japan_size_count").change(function(){
    	var count = $(this).val();
    	var origin_size = $("#japan_size").parent().parent().clone();
    	var origin_size_kind = $("#japan_size_kind").parent().parent().clone();
    	
    	$(".japan_size").parent().parent().remove();
    	$(".japan_size_kind").parent().parent().remove();
    	origin_size.insertAfter($("#japan_size_count").parent().parent());
    	origin_size_kind.insertAfter($("#japan_size").parent().parent());
    	
    	$("#japan_size").attr("value", '');
    	$("#japan_size_kind").attr("value", '');
    	
    	for (index = 1; index < count; index++) {
    		$("#japan_size").parent().parent().clone().insertAfter($("#japan_size").parent().parent());
    		$("#japan_size_kind").parent().parent().clone().insertAfter($("#japan_size_kind").parent().parent());
    	}
    });
})



/*function onChangeItem(ts){
    var obj = $(ts);
    if(!obj.val()){ $("#itemcodedesc").text(''); }
    else{
        var t = $(":selected",obj).attr('ref');
        $("#itemcodedesc").text(t);
    }
}



function onChangeDivision(ts){
    var obj = $(ts);
    if(!obj.val()){
        $("#categoryId").html('');
    }else{
        var params = {
            did : obj.val(),
            t : Date.parse(new Date())
        }
        $.getJSON('/oncl/ajaxCategory',params,function(r){
            if(r.flag != 0 ){
                alert(r.msg)
            }else{
                var html = '<option value=""></option>';
                for(var i=0;i<r.data.length;i++){
                    var t = r.data[i];
                    html += '<option value="'+t[0]+'">'+t[1]+'</option>';
                }
                $("#categoryId").html(html);
            }
        })
    }
}


function toCheck(){
    var msg = [];
    
    $(".error").removeClass("error");
    
    var fields = ['shipCompany','billCompany','shipAddress','billAddress',
                  'shipCity','billCity','shipState','billState',
                  'shipCountry','billCountry','shipTel','billTel','shipEmail','billEmail',
                  'onclpo','vendorpo','itemId','printShopId','divisionId','categoryId','qty'];
    
    var allOK = true;         
    for(var i=0;i<fields.length;i++){
        var name = fields[i];
        if(!$("#"+name).val()){
            $("#"+name).addClass('error');
            allOK = false;
        }
    }
    
    if(!allOK){ msg.push('Please fill in the required field(s)!'); }
    
    return msg;
}



function toConfirm(){
    var msg = toCheck();
    if(msg.length > 0 ){
        showError(msg.join('\n'));
        return;        
    }else{
        $("#status").val(0);
        $("form").submit();
        
    }
}

function toPending(){
    var msg = toCheck();
    if(msg.length > 0 ){
        showError(msg.join('\n'));
        return;      
    }else{
        $("#status").val(-1);
        $("form").submit();
        
    }
}






//#############################################
// for layout page
//
//#############################################

var care_index = 11;
function addCare(){
    var t = $(".care.template");
    var c = t.clone();
    var s = $("select",c);
    s.attr('name',s.attr('name') + care_index++);
    c.removeClass('care').removeClass('template');    
    t.before(c);
}

function delCare(obj){
    var k = $(obj);
    $(k.parents("tr")[0]).remove();
}



var warn_index = 11;
function addWarn(){
    var t = $(".warning.template");
    var c = t.clone();
    var s = $("select",c);
    s.attr('name',s.attr('name') + warn_index++);
    c.removeClass('warning').removeClass('template');    
    t.before(c);
}

function delWarn(obj){
    var k = $(obj);
    $(k.parents("tr")[0]).remove();
}


var com_index = 11;
var fp_index = 11;
function addCom(){
    var t = $(".com.template");
    var c = t.clone();
    
    var s1 = $(".comselect",c);
    var comname = s1.attr('name') + com_index++;
    
    s1.attr('name',comname);
    
    var s2 = $(".fcomselect",c);
    s2.attr('name','f'+ comname + '_' + fp_index);
    
    var s3 = $(".pcominput",c);
    s3.attr('name','p'+ comname + '_' + fp_index);
    
    fp_index++;
  
    c.removeClass('com').removeClass('template').addClass("realCom");
    t.before(c);
}

function delCom(obj){
    var k = $(obj);
    $(k.parents("tr")[1]).remove();
}

function addFP(o){
    var bn = $(o);
    var tr = $(bn.parents("tr")[0]);
    var fname =  $(".fcomselect",tr).attr('name').split('_')[0];
    var pname =  $(".pcominput",tr).attr('name').split('_')[0];
    
    
    var t = $("#material_template").clone();
    t.attr('id','');
    $(".fcomselect",t).attr('name',fname+'_'+fp_index);
    $(".pcominput",t).attr('name',pname+'_'+fp_index);

    $(bn.parents('table')[0]).append(t);
    fp_index++;
}

function delFP(obj){
    var t= $(obj);
    $(t.parents('tr')[0]).remove();
}



function toLayoutSubmit(){    
    var msg = checkLayout();
    
    if(msg.length > 0 ){
        var m = '<ul>';
        for(var i=0;i<msg.length;i++){ m += '<li>' + msg[i] + '</li>'; }
        m += '</ul>';
        showError(m);
        return;
    }else{
        $(".template").remove();
        $("form").submit();
    }
}



function checkLayout(){
    var msg = [];
    
    var fields = [];
    if(!$("#sizeId").val()){  msg.push('Please select the "Size".'); }
    var careOK = false;
    $("select[name^='care']").each(function(){
        var t = $(this);
        if(t.val()){ careOK = true; }
    })
    if(!careOK){ msg.push('Please select at least one "Care Instructions".');}
    if(!$("#coId").val()){  msg.push('Please select the "Country of Origin".'); }
    
    var warnOK = false;
    $("select[name^='warning']").each(function(){
        var t = $(this);
        if(t.val()){ warnOK = true; }
    });        
    if(!warnOK){ msg.push('Please select at lease one "Warnings".'); }
    
    var partOK = false;
    var mOk = true;
    
    $(".realCom").each(function(){
        var tr = $(this);
        if($('.comselect',tr).val()){ partOK = true; }
        var sum = 0;
        $(".pcominput",tr).each(function(){
            var k = $(this);
            if(k.val()){
                sum += parseFloat(k.val());
                var n = k.attr('name').replace('pcom','fcom')
                if(!$('select[name="'+n+'"]').val()){ mOk = false;  }
            }
        });
        if(sum != 100){ mOk = false;}
    });

    if(!partOK){ msg.push('Please select at least one "Composition".'); }
    if(!mOk){ msg.push('Please input the "Material" correctly, total percentage should be 100%.'); }
    
    return msg;
}
*/