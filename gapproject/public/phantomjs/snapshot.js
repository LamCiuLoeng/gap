
setTimeout(function(){phantom.exit()}, 60*1000);

var page = new WebPage(),
	//url = 'http://tribaltest.r-pac.com.hk/sku/update?id=57';
	url, tabQty, imgDir;

if(phantom.args.length <= 3){
	console.log('Usage: snapshot.js URL positions img_dir files');
    phantom.exit();
}else{
url = phantom.args[0];
positions = phantom.args[1].split('|');
imgDir = phantom.args[2];
files = phantom.args[3].split('-');
// console.log(url);
// console.log('###');
// console.log(positions);
// console.log(imgDir);

page.open(url, function(status){
	if(status !== 'success'){
		console.log('Unable to load the address!');
	}else{
		var currentUrl = page.evaluate(function(){
        		return window.location.href;
    		});
    		
    	// console.log('current url:' + currentUrl);
    	
    	page.injectJs('jquery-1.6.4.min.js');
    	page.injectJs('jquery-ui-1.7.3.custom.min.js');
    	
    	if(currentUrl.indexOf('login') != -1){
    		// console.log('logining...');
    		page.evaluate(function(){
	     		$('#login_name').val('admin');
	     		$('#login_password').val('ecrmadmin');
	     		$('form').first().submit();
   			});
    	}else if(currentUrl.indexOf(url) != -1){
    		// snapshot the last tab
    		// console.log('snapshot...');
            // var pdfname = null;
			for (var i= 0; i<positions.length; i++) {
				var pos = positions[i].split('-');
				// console.log("***" + pos);
				var selectTab = function(){
					var $tabs = $('#tabs').tabs();
	    		 	$tabs.tabs('select', parseInt('POS'));
				}
				page.evaluate(selectTab.toString().replace('POS', pos[0]));
				
				var height = page.evaluate(function() { return document.body.offsetHeight }),
   				width = page.evaluate(function() { return document.body.offsetWidth });
   				page.viewportSize = {width: width, height: height};
				// console.log(page.viewportSize);
				// print pdf
				var d = new Date();
	    		var tmpName = imgDir + '/' + pos[1]
	    					+ '_' + d.getFullYear() + (d.getMonth()+1) 
	    					+ d.getDate() + d.getHours() + d.getMinutes() 
	    					+ d.getSeconds() + d.getMilliseconds();
	    		for(var j=0; j<files.length; j++){
	    		    var tmpFileName = tmpName + '.' + files[j];
	    		    var pr = page.render(tmpFileName);
	    		    if(pr){
                        console.log(tmpFileName); // do not comment this line
                    }
	    		}
			}
    		// console.log('exit.');
    		phantom.exit();
    	}
    	
	}
});

}
