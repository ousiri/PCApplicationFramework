
$ = require 'zepto'
C = require 'common'
Gallery = require 'gallery'
IndexTpl = require 'page/index/index.tpl'

$body = null

init = ->
	Gallery.init()
	$body = $ document.body
	$body.append IndexTpl(content: 'content')

module.exports =
	init: init