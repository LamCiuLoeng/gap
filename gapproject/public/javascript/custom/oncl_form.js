if (!Array.prototype.indexOf) { 
    Array.prototype.indexOf = function(obj, start) {
         for (var i = (start || 0), j = this.length; i < j; i++) {
             if (this[i] === obj) { return i; }
         }
         return -1;
    };
}

function loadCare(){
    $.getJSON('/oncl/ajaxCare',{},function(r){
        if(r.code!=0){
            
        }else{
            var cares = [["care_wash_","WASH"],["care_bleach_","BLEACH"],["care_dry_","DRY"],["care_iron_","IRON"],["care_dryclean_","DRYCLEAN"],["care_specialcare_","SPECIALCARE"]];
            for(var i=0;i<cares.length;i++){
                var tmp = cares[i];
                var html = '<option value=""></option>';
                for(var j=0;j<r.data[tmp[1]].length;j++){
                    var t = r.data[tmp[1]][j];
                    html += '<option value="'+t.id+'">' + t.value +'</option>';
                }
                $("select[name^='"+tmp[0]+"']").html(html);
            }
            
            
            /*
            var html = '<option value=""></option>';
            for(var i=0;i<r.data.length;i++){
                var t = r.data[i];
                html += '<option value="'+t.id+'">' + t.value +'</option>';
            }
            $("select[name^='care_wash_']").html(html);
            $("select[name^='care_bleach_']").html(html);
            $("select[name^='care_dry_']").html(html);
            $("select[name^='care_iron_']").html(html);
            $("select[name^='care_dryclean_']").html(html);
            */
        }
    });
}


function loadWarn(){
    $.getJSON('/oncl/ajaxWarn',{},function(r){
        if(r.code!=0){
            
        }else{
            var html = '<option value="NOSELECTED" selected="selected">NONE</option>';
            for(var i=0;i<r.data.length;i++){
                var t = r.data[i];
                html += '<option value="'+t.id+'">' + t.value +'</option>';
            }
            $("select[name^='warning']").html(html);
        }
    });
    
}


function loadContent(){
    $.getJSON('/oncl/ajaxContent',{},function(r){
        if(r.code!=0){
            
        }else{
            var html = '<option value=""></option>';
            for(var i=0;i<r.data.length;i++){
                var t = r.data[i];
                html += '<option value="'+t.id+'">' + t.value +'</option>';
            }
            $(".fcomselect").html(html);
        }
    });
    
}


function onChangeItem(ts){
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
        var option = $(":selected",obj);
        var v = option.text().toUpperCase();
        $("select[name^='fit']").val('');
        if( v == 'GIRLS' || v == 'BOYS'){
            $("select[name^='fit']").removeAttr('disabled');
        }else{
            $("select[name^='fit']").attr('disabled','disabled');
        }       
        
        var params = {
            did : obj.val(),
            t : Date.parse(new Date())
        };
        $.getJSON('/oncl/ajaxCategory',params,function(r){
            if(r.flag != 0 ){
                alert(r.msg);
            }else{
                var html = '<option value=""></option>';
                for(var i=0;i<r.data.length;i++){
                    var t = r.data[i];
                    html += '<option value="'+t[0]+'">'+t[1]+'</option>';
                }
                $("#categoryId").html(html);
            }
        });
        
        
    }
}


function onChangeCategory(c){
    var obj = $(c);
    if(!obj.val()){
        $("select[name^='sizeId']").html('');
        $("select[name^='fitId']").html('');
    }else{
        var params = {
            categoryId : obj.val(),
            t : Date.parse(new Date())
        };
        $.getJSON('/oncl/ajaxSize',params,function(r){
            if(r.flag != 0 ){
                alert(r.msg);
            }else{
                if(r.fits.length > 0){
                    $("select[name^='sizeId']").html('');
                    var html = '<option value=""></option>';
                    for(var i=0;i<r.fits.length;i++){
                        var t = r.fits[i];
                        html += '<option value="'+t.id+'">'+t.name+'</option>';
                    }
                    $("select[name^='fitId']").removeAttr('disabled');
                    $("select[name^='fitId']").html(html);
                }else{
                    var html = '<option value=""></option>';
                    for(var i=0;i<r.sizes.length;i++){
                        var t = r.sizes[i];
                        html += '<option value="'+t.id+'" ref="'+t.ref+'">'+t.name+'</option>';
                    }
                    $("select[name^='sizeId']").html(html);
                    $("select[name^='fitId']").html('');
                    $("select[name^='fitId']").attr('disabled','disabled');
                }
            }
        });
    }
}
                             


function onChangeSize(c){
    var obj = $(c);
    var op = $(":selected",obj);
    var tr = $(obj.parents("tr")[0]);
    var h = $("input[name^='scontent']",tr);
    
    if(!op.val()){
        h.val('');
    }else{
        var rs = op.attr('ref').split('|');
        h.val(rs.join("/"));
    }
}


function onChangeFit(c){
    var obj = $(c);
    var tr = $(obj.parents("tr")[0]);
    var sizeSelect = $("select[name^='sizeId'],select[name^='oldSizeId']",tr);
    if(!obj.val()){
        sizeSelect.html('');
    }else{
        var params = {
            fitId : obj.val(),
            t : Date.parse(new Date())
        };
        $.getJSON('/oncl/ajaxFit',params,function(r){
            if(r.flag != 0 ){
                alert(r.msg);
            }else{
                var html = '<option value=""></option>';
                for(var i=0;i<r.sizes.length;i++){
                    var t = r.sizes[i];
                    html += '<option value="'+t.id+'" ref="'+t.ref+'">'+t.name+'</option>';
                }
                sizeSelect.html(html);
            }
        });
    }
}





function toCheck(){
    var msg = [];
    
    $(".error").removeClass("error");

    var fields = ['shipCompany','billCompany','shipAddress','billAddress',
              'shipCity','billCity','shipState','billState',
              'shipCountry','billCountry','shipTel','billTel','shipEmail','billEmail',
              'onclpo','itemId','printShopId','divisionId','categoryId'];

    var allOK = true;         
    for(var i=0;i<fields.length;i++){
        var n = fields[i];
        if(!$("#"+n).val()){
            $("#"+n).addClass('error');
            allOK = false;
        }
    }
    
    if(!allOK){ msg.push('Please fill in the required field(s)!'); }
    
    return msg;
}



//#############################################
// for layout page
//
//#############################################

var care_index = 11;
function addCare(obj){
    var t = $(obj);
    var tb = $(t.parents('.caretable')[0]);
    var tpl = $(".template",tb).clone().removeClass("template");
    
    $("select",tpl).each(function(){
        var k = $(this);
        var n = k.attr('name');
        k.attr('name',n.replace("_xx","_"+care_index));
    });
    
    care_index ++ ;
    tb.append(tpl);
    
    /*
    var t = $(".care.template");
    var c = t.clone();
    var s = $("select",c);
    s.attr('name',s.attr('name') + care_index++);
    c.removeClass('care').removeClass('template');    
    t.before(c);
    */
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
    $(".pcominput",c).numeric();
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
    $(".pcominput",t).numeric();
    $(bn.parents('table')[0]).append(t);
    fp_index++;
}

function delFP(obj){
    var t= $(obj);
    $(t.parents('tr')[0]).remove();
}



function toLayoutSubmit(){
    var msg = toCheck();
    var msg2 = checkLayout();
    var totalmsg = msg.concat(msg2);    
    
    if(totalmsg.length > 0 ){
        var m = '<ul>';
        for(var i=0;i<msg.length;i++){ m += '<li>' + msg[i] + '</li>'; }
        m += '</ul>';
        showError(m);
        return;
    }else{
        $(".template").remove();
        $(".ui-button").attr('disabled','true');
        $("form").submit();
    }
}



function checkLayout(){
       
    var msg = [];
    var oneSize = false;
    var oneqty = false;
    var qtyOK = true;
    var sizeList = [];
    var duplicateSize = false;
    
    $("select[name^='sizeId']").each(function(){
        var t = $(this);
        var tr = $(t.parents('tr')[0]);
        var q = $("input[name^='qty']",tr);
        
        if(t.val()){
           oneSize = true;
           if(sizeList.indexOf(t.val()) > -1){
               duplicateSize = true;
           }else{
               sizeList.push(t.val());
           }
        }
        if(q.val()){ oneqty = true; }     
        
        if( t.val() && !q.val() ){ qtyOK = false; }
        else if( !t.val() && q.val() ){ qtyOK = false; }
    });
    
    if(!oneSize){ msg.push('Please select at lease one size !'); }
    if(!oneqty){ msg.push('Please select at lease one qty !'); }
    if(!qtyOK){ msg.push('Please input both the size and qty correctly !'); }
    if(duplicateSize){ msg.push("Please do not select the duplicate size!"); }

   
    var allCareIds = [];
    var isCareDuplicate = false;
    var caresArray = [{'flag' : 'care_wash_', 'label' : 'Wash'},{'flag' : 'care_bleach_', 'label' : 'Bleach'},
                      {'flag' : 'care_dry_', 'label' : 'Dry'},{'flag' : 'care_iron_', 'label' : 'Iron'},
                      {'flag' : 'care_dryclean_', 'label' : 'Professional textile care (Dry Clean)'},
                      {'flag' : 'care_specialcare_', 'label' : 'Special Care'}];
    for(var i=0;i<caresArray.length;i++){
        var atleaseone = false;
        var k = caresArray[i];
        $("select[name^='"+k.flag+"']").each(function(){
            var _id = $(this).val(); 
            if(_id){ 
                atleaseone = true;
                if(allCareIds.indexOf(_id) > -1){ isCareDuplicate = true; } //is duplicated
                else{ allCareIds.push(_id); } 
            }
        });
        if(!atleaseone){ msg.push("Please select at least one '"+k.label+"'!"); }
    }
    if(isCareDuplicate){ msg.push("Please don't select duplicated 'Care Instructions'!"); }
    
    if(!$("#coId").val()){  msg.push('Please select the "Country of Origin".'); }
    
    
    var warnOK = false;
    var warnIds = [];
    var iswarnduplicated = false;
    $("select[name^='warning']").each(function(){
        var t = $(this).val() ;
        if(t){ 
            warnOK = true;
            if(t!='NOSELECTED' && warnIds.indexOf(t)>-1){ iswarnduplicated = true; }
            else{ warnIds.push(t); } 
        }
    });        
    if(!warnOK){ msg.push('Please select at lease one "Warnings".'); }
    if(iswarnduplicated){ msg.push("Please don't select duplicated 'Warnings'!"); }
    
    
    var partOK = false;
    var mOk = true;
    
    $(".realCom").each(function(){
        var tr = $(this);
        if($('.comselect',tr).val()!='NOSELECTED'){ partOK = true; }
        var sum = 0;
        $(".pcominput",tr).each(function(){
            var k = $(this);
            if(k.val()){
                sum += parseFloat(k.val());
                var n = k.attr('name').replace('pcom','fcom');
                if(!$('select[name="'+n+'"]').val()){ mOk = false;  }
            }
        });
        if(sum != 100){ mOk = false;}
    });

    if(!partOK){ msg.push('Please select at least one "Fabric Content".'); }
    if(!mOk){ msg.push('Please input the "Content" correctly, total percentage should be 100%.'); }
    
    return msg;
}



function showInfo(){
    var msg1 = toCheck();
    var msg2 = checkLayout();
    
    var msg = msg1.concat(msg2);
    
    if(msg.length > 0){
        var m = '<ul>';
        for(var i=0;i<msg.length;i++){ m += '<li>' + msg[i] + '</li>'; }
        m += '</ul>';
        showError(m);
        return;
    }
    
    var params = {
        t : Date.parse(new Date())
    };
    
    /*
    var cids = [];
    $("[name^='care']").each(function(){
        var t = $(this);
        if(t.val()){ cids.push(t.val()); }
    });
    */
    
    var cares = ["care_wash","care_bleach","care_dry","care_iron","care_dryclean","care_specialcare"];
    for(var i=0;i<cares.length ;i++){
        var t = cares[i];
        var tmp = [];
        $("select[name^='"+t+"']").each(function(){
            var e = $(this);
            if(e.val()){ tmp.push(e.val()); }
        });
        params[t] = tmp.join("|");
    }
    

    var wids = [];
    $("[name^='warning']").each(function(){
        var t = $(this);
        if(t.val() && t.val()!='NOSELECTED'){ wids.push(t.val()); }
    });
    
    
    //params['cids'] = cids.join("|");
    params['wids'] = wids.join("|");
    var coms = [];
    
    $("select[name^='com']",".realCom").each(function(){
        var k = $(this);
        var tmp = [];
        tmp.push(k.val());
        var n = k.attr('name');
        $("select[name^='f" + n + "']").each(function(){
            var m = $(this);
            if(m.val()){ tmp.push(m.val()); }
        });
        coms.push(tmp.join(','));        
    });
    params['coms'] = coms.join("|");
        
        
    $.getJSON('/oncl/ajaxLayoutInfo',params,function(r){
        if(r.code != 0 ){
            alert(r.msg);
        }else{
            $("#item_td").text( $("#itemId :selected").text() );
            var sizehtml = '<ul>';
            $("input[name^='scontent']").each(function(){
                var t = $(this);
                if(t.val()){
                    sizehtml += '<li>' + t.val() + '</li>';
                }
            });
            sizehtml += '</ul>';
            
            $("#size_td").html(sizehtml);
            
            
            $("#co_td").text( $("#coId :selected").text() );
            $("#com_td").html(r.composition );
            $("#care_td").html(r.cares);
            $("#warn_td").html(r.warngs);   
            
            
            var cntr = '<tr>';
            for(var i=0;i<r.cnimgs.length;i++){
                var img = r.cnimgs[i];
                if(img){
                    cntr += '<td style="width:40px"><img src="/images/caresymbols/' + img + '"/></td>';
                }else{
                    cntr += '<td style="width:40px">&nbsp;</td>';
                }
            }
            cntr += '</tr>';
            
            var jptr = '<tr>';
            for(var i=0;i<r.jpimgs.length;i++){
                var img = r.jpimgs[i];
                if(img){
                    jptr += '<td style="width:40px"><img src="/images/caresymbols/' + img + '"/></td>';
                }else{
                    jptr += '<td style="width:40px">&nbsp;</td>';
                }
            }
            jptr += '</tr>';
            
            $("#symbol_tb").html( cntr + jptr );
            $( "#layoutinfo" ).dialog('open');
        }
    });
}


var sizeIndex = 11;

function addSize(){
    var tr = $(".size_template").clone();
    tr.removeClass('size_template').removeClass("template").addClass("size_tr");
    $("select,input[type='text'],input[type='hidden']",tr).each(function(){
        var t = $(this);
        var n = t.attr('name');
        t.attr('name',n+sizeIndex);
    });
    sizeIndex += 1;
    $(".num",tr).numeric();
    $("#sizetb").append(tr);
}

    
function delSize(obj){
    var t= $(obj);
    $(t.parents('tr')[0]).remove();
}

function check_number(v){
    var pattern = /^[\d\.]+$/;
    return pattern.test(v); 
}

function roundup(v){
    if(v == 0 ){ return 0 ;}
    /*
    var m = v % 250 == 0 ? 0 : 1; 
    return 250 * (parseInt(v / 250) + m );
    */
   var m = v % 50 == 0 ? 0 : 1; 
    return 50 * (parseInt(v / 50) + m );
}


function chqty(obj){
    var t = $(obj);
    var tr = $(t.parents('tr')[0]);
    var span = $(".roundup",tr);
    if(!t.val()){
        span.text('');
    }else{
        if( !check_number(t.val())){
            alert('Please input the qty correctly, the value should be digital.');
            t.focus();
        }else{
            span.text(roundup(t.val()));
        }
    }
}
            
