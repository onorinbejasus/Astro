// Generated by CoffeeScript 1.3.3
(function() {
  var FITS, require;

  require = window.require;

  FITS = require("fits");

  describe("FITS Table", function() {
    return it('can read a FITS table', function() {
      var i, row, table, _i, _ref;
      table = fits.getDataUnit(1);
      for (i = _i = 0, _ref = table.rows - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        row = table.getRow();
        if (i === 0) {
          expect(row[0]).toEqual(-3.12);
          expect(row[1]).toEqual(-3.12);
          expect(row[2]).toEqual(0);
          expect(row[3]).toEqual(0);
        }
        if (i === 800) {
          expect(row[0]).toEqual(-3.12);
          expect(row[1]).toEqual(0.08);
          expect(row[2]).toEqual(-0.59);
          expect(row[3]).toEqual(0.09);
        }
      }
      expect(row[0]).toEqual(3.12);
      expect(row[1]).toEqual(3.12);
      expect(row[2]).toEqual(-0.20);
      return expect(row[3]).toEqual(-0.07);
    });
  });

}).call(this);
