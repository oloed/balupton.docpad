# Requires
docpad = require 'docpad'
express = require 'express'

# =====================================
# Configuration

# Variables
oneDay = 86400000
expiresOffset = oneDay

# Configuration
docpadPort = process.env.BALUPTONPORT || process.env.PORT || 10113

# Create Servers
docpadServer = express.createServer()

# Configure DocPad
docpadConfig =
	port: docpadPort
	maxAge: expiresOffset
	server: docpadServer
	checkVersion: false


# =====================================
# Start & Extend DocPad

# Create DocPad, and wait for it to load
docpadInstance = docpad.createInstance docpadConfig, (err) ->
	# Prepare
	throw err  if err
	logger = docpadInstance.logger


	# ---------------------------------
	# Server Configuration

	# Redirect Middleware
	docpadServer.use (req,res,next) ->
		if req.headers.host in ['www.balupton.com','lupton.cc','www.lupton.cc','balupton.no.de','balupton.herokuapp.com']
			res.redirect 'http://balupton.com'+req.url, 301
		else
			next()

	# Start Server
	docpadInstance.action 'server generate'


	# ---------------------------------
	# Server Extensions

	# Demos
	docpadServer.get /^\/sandbox(?:\/([^\/]+).*)?$/, (req, res) ->
		project = req.params[0]
		res.redirect "http://balupton.github.com/#{project}/demo/", 301
		# ^ github pages don't have https

	# Projects
	docpadServer.get /^\/(?:g|gh|github)(?:\/(.*))?$/, (req, res) ->
		project = req.params[0] or ''
		res.redirect "https://github.com/balupton/#{project}", 301

	# Twitter
	docpadServer.get /^\/(?:t|twitter|tweet)\/?.*$/, (req, res) ->
		res.redirect "https://twitter.com/balupton", 301

	# Sharing Feed
	docpadServer.get /^\/feeds?\/shar(e|ing)?.*$/, (req, res) ->
		res.redirect "http://feeds.feedburner.com/balupton/shared", 301

	# Feeds
	docpadServer.get /^\/feeds?\/?.*$/, (req, res) ->
		res.redirect "http://feeds.feedburner.com/balupton", 301


	# ---------------------------------
	# DocPad Extensions

	# Regenerate every hour
	# this is used so our cachr feeds stay alive
	fiveMinutes = 1000*60*60
	setInterval(
		-> docpadInstance.action 'generate'
		fiveMinutes
	)


# =====================================
# Exports

# Export the DocPad Server we created
module.exports = docpadServer