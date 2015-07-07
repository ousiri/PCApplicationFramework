window.allowAnimation = false
if navigator.userAgent.toLowerCase().indexOf('msie')==-1 and not (navigator.userAgent.match(/windows.+safari/i) and navigator.userAgent.toLowerCase().indexOf('chrome')==-1)
	window.allowAnimation = true
	document.documentElement.className += 'allow-animation'