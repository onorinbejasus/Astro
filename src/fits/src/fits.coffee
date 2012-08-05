# require('jDataView/src/jdataview')

FITS = @FITS = {}

FITS.VERSION    = '0.0.2'
FITS.HDU        = require('./fits.hdu')
FITS.File       = require('./fits.file')
FITS.Header     = require('./fits.header')
FITS.Image      = require('./fits.image')
FITS.BinTable   = require('./fits.binarytable')
FITS.CompImage  = require('./fits.compressedimage')
FITS.Table      = require('./fits.table')
FITS.ImageSet   = require('./fits.imageset')
FITS.Visualize  = require('./fits.visualize')
FITS.ImageStats = require('./fits.imagestats')

module?.exports = FITS