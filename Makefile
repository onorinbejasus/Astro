# Please install coffeescript before running this file.
#	all will compile all the js and put it into one file.
#	debug is if you want to see all the intermediate files, not suggested
#	since you will have to have a lot of script tags

all:
	coffee -c -o lib/ -j sky.js src/*.coffee

debug:
	coffee -c -o lib/ src/*.coffee
