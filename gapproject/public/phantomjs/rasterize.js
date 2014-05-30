var page = require('webpage').create(),
    address, output, size;

if (phantom.args.length < 2 || phantom.args.length > 3) {
    console.log('Usage: rasterize.js URL filename [paperwidth*paperheight|paperformat]');
    console.log('  paper (pdf output) examples: "5in*7.5in", "10cm*20cm", "A4", "Letter"');
    phantom.exit();
} else {
    address = phantom.args[0];
    output = phantom.args[1];
    page.viewportSize = { width: 600, height: 600 };
    if (phantom.args.length === 3 && phantom.args[1].substr(-4) === ".pdf") {
        size = phantom.args[2].split('*');
        page.paperSize = size.length === 2 ? { width: size[0], height: size[1], border: '0px' }
                                           : { format: phantom.args[2], orientation: 'portrait', border: '1cm' };
    }
    page.open(address, function (status) {
        if (status !== 'success') {
            console.log('Unable to load the address!');
        } else {
        	var currentUrl = page.evaluate(function(){
        		return window.location.href;
    		});
        	
        	page.injectJs('jquery-1.6.4.min.js');
        	page.injectJs('jquery-ui-1.7.3.custom.min.js');
        	
        	if(currentUrl.indexOf('login') != -1){
        		// console.log('logining...');
        		page.evaluate(function(){
    	     		$('#login_name').val('admin');
    	     		$('#login_password').val('ecrmadmin');
    	     		$('form').first().submit();
       			});
        	}
        	
        	/*var currentUrl = page.evaluate(function(){
        		return window.location.href;
    		});*/
        	
        	if(currentUrl.indexOf(address) != -1) {
        		window.setTimeout(function () {
                    page.render(output);
                    phantom.exit();
                }, 200);
        	}
            
        }
    });
}
