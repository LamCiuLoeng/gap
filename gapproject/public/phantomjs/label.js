var page = require('webpage').create();
var address = null;
var output = null;
var size = null;

if (phantom.args.length < 2 || phantom.args.length > 3) {
  console.log('Usage: rasterize.js URL filename [paperwidth*paperheight|paperformat]');
  console.log('  paper (pdf output) examples: "5in*7.5in", "10cm*20cm", "A4", "Letter"');
  phantom.exit(1);
} else {
  address = phantom.args[0];
  output = phantom.args[1];
  // page.viewportSize = { width: 600, height: 600 };

  // if (phantom.args.length === 3 && phantom.args[1].substr(-4) === ".pdf") {
  //     size = phantom.args[2].split('*');
  //     page.paperSize = size.length === 2 ? { width: size[0], height: size[1], border: '0px' }
  //                                        : { format: phantom.args[2], orientation: 'portrait', border: '1cm' };
  // }

  page.paperSize = {
    format: 'A4',
    orientation: 'portrait',
    margin: '1cm'
  };

  page.zoomFactor = 1;

  page.open(address, function (status) {
    if (status !== 'success') {
        console.log('Unable to load the address!');
        phantom.exit();
    } else {
      var currentUrl = page.evaluate(function(){
        return window.location.href;
      });

      if(~currentUrl.indexOf(address)) {
        window.setTimeout(
          function () {
            page.render(output);
            phantom.exit();
          },
          200
        );
      }

    }
  });
}
