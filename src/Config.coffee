# Store all program-specific, loose variables in here to change them within the program later.
class Config

	# When we actually implement proxy images, this will be the default image to display.
	@PROXY_IMAGE_URL = 'http://www.google.com/puppies.jpg'
	# This will change the amount of scale changed when scrolling on a mouse.
	@SCROLL_SENSITIVITY = .001

	# Changes the amount of space moved when panning in any direction within the skyview
	@PAN_SENSITIVITY = 0.005