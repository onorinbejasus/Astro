// Generated by CoffeeScript 1.3.3
(function() {
  var FITS, require;

  require = window.require;

  FITS = require("fits");

  describe("FITS Image", function() {
    beforeEach(function() {
      return this.addMatchers({
        toBeNaN: function(expected) {
          return isNaN(this.actual) === isNaN(expected);
        }
      });
    });
    it('can read a FITS image', function() {
      var image;
      image = fits.getDataUnit();
      image.getFrame();
      expect(image.getPixel(0, 0)).toEqual(3852);
      expect(image.getPixel(890, 0)).toEqual(4223);
      expect(image.getPixel(890, 892)).toEqual(4015);
      expect(image.getPixel(0, 892)).toEqual(3898);
      expect(image.getPixel(405, 600)).toEqual(9128);
      expect(image.getPixel(350, 782)).toEqual(4351);
      expect(image.getPixel(108, 345)).toEqual(4380);
      return expect(image.getPixel(720, 500)).toEqual(5527);
    });
    it('can read a FITS data cube', function() {
      var i, image, precision, _i;
      precision = 6;
      image = datacube.getDataUnit();
      image.getFrame();
      expect(image.getPixel(0, 0)).toBeNaN();
      expect(image.getPixel(106, 0)).toBeNaN();
      expect(image.getPixel(106, 106)).toBeNaN();
      expect(image.getPixel(0, 106)).toBeNaN();
      expect(image.getPixel(54, 36)).toBeCloseTo(0.0340614, precision);
      expect(image.getPixel(100, 7)).toBeCloseTo(-0.0275259, precision);
      expect(image.getPixel(42, 68)).toBeCloseTo(-0.0534229, precision);
      expect(image.getPixel(92, 24)).toBeCloseTo(0.153861, precision);
      image.getFrame();
      expect(image.getPixel(0, 0)).toBeNaN();
      expect(image.getPixel(106, 0)).toBeNaN();
      expect(image.getPixel(106, 106)).toBeNaN();
      expect(image.getPixel(0, 106)).toBeNaN();
      expect(image.getPixel(54, 36)).toBeCloseTo(0.0329713, precision);
      expect(image.getPixel(100, 7)).toBeCloseTo(0.0763166, precision);
      expect(image.getPixel(42, 68)).toBeCloseTo(-0.103573, precision);
      expect(image.getPixel(92, 24)).toBeCloseTo(0.0360738, precision);
      for (i = _i = 2; _i <= 601; i = ++_i) {
        image.getFrame();
      }
      expect(image.getPixel(0, 0)).toBeNaN();
      expect(image.getPixel(106, 0)).toBeNaN();
      expect(image.getPixel(106, 106)).toBeNaN();
      expect(image.getPixel(0, 106)).toBeNaN();
      expect(image.getPixel(54, 36)).toBeCloseTo(-0.105564, precision);
      expect(image.getPixel(100, 7)).toBeCloseTo(0.202304, precision);
      expect(image.getPixel(42, 68)).toBeCloseTo(0.221437, precision);
      return expect(image.getPixel(92, 24)).toBeCloseTo(-0.163851, precision);
    });
    return it('can get extremes, seek, then get data without blowing up', function() {
      var image;
      image = fits.getDataUnit();
      expect(image.frame).toEqual(0);
      image.seek();
      expect(image.frame).toEqual(-1);
      image.getFrame();
      expect(image.getPixel(0, 0)).toEqual(3852);
      expect(image.getPixel(890, 0)).toEqual(4223);
      expect(image.getPixel(890, 892)).toEqual(4015);
      expect(image.getPixel(0, 892)).toEqual(3898);
      expect(image.getPixel(405, 600)).toEqual(9128);
      expect(image.getPixel(350, 782)).toEqual(4351);
      expect(image.getPixel(108, 345)).toEqual(4380);
      return expect(image.getPixel(720, 500)).toEqual(5527);
    });
  });

}).call(this);
