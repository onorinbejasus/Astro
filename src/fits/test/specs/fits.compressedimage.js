// Generated by CoffeeScript 1.3.3
(function() {
  var FITS, require;

  require = window.require;

  FITS = require("fits");

  describe("FITS CompImage", function() {
    return it('can read a FITS compressed image', function() {
      var data;
      data = compimg.getDataUnit();
      return data.getFrame();
    });
  });

}).call(this);
