# Store all program-specific, loose variables in here to change them within the program later.
class Config
	@proxy_image_url = 'http://www.google.com/puppies.jpg'
	###
	Create a texture within init and set it to Config.proxy_default_texture
	###
	@proxy_default_texture = null
	@scroll_sensitivity = .001
	@pan_sensitivity = 0.1