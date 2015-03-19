# Setup
document.body.style.cursor = "auto"
imageWidth = 32
imageHeight = 16
pixelWidth = 30
pixelHeight = 30
pixelSpacing = 1
toolbarHeight = 2 * pixelHeight
buttonWidth = 8 * pixelWidth
pixelsClickable = true
popupOpen = false
dragEvent = false
dragThreshold = 5

Framer.Defaults.Layer.style = {
	    "color": "black",
	    "font-size": "16px"
	    "line-height": "18px"
	    "font-family" : "'Courier New', Courier, monospace"
	}

### Components ###

# Background
bkg = new BackgroundLayer
	backgroundColor: "#000000"

# Pixel Array
Pixels = []

# Pixel Image Canvas
mainContainer = new Layer
	width: pixelWidth * imageWidth + pixelSpacing * (imageWidth - 1)
	height: pixelHeight * imageHeight + pixelSpacing * (imageHeight - 1)
	backgroundColor: "transparent"
mainContainer.center()


# Pixel Builder
pixelLabel = 0
for i in [0..31]
	row = new Layer
		height: mainContainer.height
		width: pixelWidth
		backgroundColor: "transparent"
		x:pixelWidth * i + pixelSpacing * i
		y:0
		superLayer: mainContainer
	for j in [0..15]
		pixel = new Layer
			width: pixelWidth
			height: pixelHeight
			x:0
			y:pixelHeight * j + pixelSpacing * j
			superLayer: row
		pixel.listIndex = j
		pixel.states.add
			on: {backgroundColor:"#ffffff"}
			off: {backgroundColor:"#252525"}
		pixel.states.switchInstant "off"
		Pixels.push(pixel)
# Pixel Listeners
memoryBuffer = []
memoryIndex = 1
pixelClicker = (event, layer) ->
	if pixelsClickable is true and dragEvent is false
		layer.states.next()
lastLayer = null
thisAction = false
firstPixelState = null
firstPixel = false
pixelDragger = (event, layer) ->
	if popupOpen is false and dragEvent is true
		if firstPixel is true
			firstPixelState = layer.states.state
		firstPixel = false
		if firstPixelState is "off"
			layer.states.switchInstant "on"
		else
			layer.states.switchInstant "off"
			#layer.states.switchInstant "off"
		lastLayer = layer
saveState = (event, layer) ->
	if memoryIndex < 20
		lastEntry = memoryBuffer[memoryIndex - 1]
		if layer.id is lastEntry
		else
			memoryBuffer[memoryIndex] = layer.id
			memoryIndex++
			#print "memoryIndex: " + memoryIndex + " memoryBuffer: " + memoryBuffer
	else
		memoryBuffer[1] = layer.id
		memoryIndex = 1
		#print "memoryIndex: " + memoryIndex + " memoryBuffer: "+ memoryBuffer



for pixel in Pixels
	pixel.states.remove("default")
	pixel.on(Events.Click, pixelClicker)
	pixel.on(Events.TouchMove, pixelDragger)

# Toolbar
toolbar = new Layer
	width: mainContainer.width
	height: toolbarHeight
	backgroundColor: "transparent"
	y:mainContainer.maxY + 10
toolbar.centerX()

### Input Box
inputBox = new Layer
	width: 400
	height: toolbarHeight
	x: 0
	y: 0
	backgroundColor: "#ffffff"
	borderRadius:1
	superLayer: toolbar
###

# Print Button
printButton = new Layer
	width: 200
	height: toolbarHeight
	y:0
	x:0
	backgroundColor: "#606060"
	borderRadius:1
	superLayer: toolbar
printButton.states.add
	ready: {backgroundColor: "#606060"}
	clicked: {backgroundColor: "#252525"}
printLabel = new Layer
	width: printButton.width
	height: 30
	x:0
	backgroundColor: "transparent"
	superLayer: printButton
printLabel.centerY()
printLabel.html = "<p style='color:white; font-size:18px; text-align:center;'> Generate Code </p>"

# Clear Button
clearButton = new Layer
	width: 150
	height: toolbarHeight
	y:0
	x:printButton.width + 10
	backgroundColor: "red"
	borderRadius:1
	superLayer: toolbar
clearLabel = new Layer
	width: clearButton.width
	height: 30
	x:0
	backgroundColor: "transparent"
	superLayer: clearButton
clearLabel.centerY()
clearLabel.html = "<p style='color:white; font-size:18px; text-align:center;'> Clear </p>"

### Code Generator ###
spewCode = (event, layer) ->
	pixelsClickable = false
	popupOpen = true
	printButton.states.switchInstant "clicked"
	printButton.off(Events.Click, spewCode)
	clearButton.off(Events.Click, clearAll)
	popup = new Layer
		name:'popup'
		height:660
		width:800
		backgroundColor: "#ffffff"
		shadowBlur: 20
		shadowColor: "black"
		borderRadius:1

	outputLayer = new Layer
		height:600
		width:500
		backgroundColor: "transparent"
		x:40
		y:40
		superLayer: popup
	outputLayer.style = {
	    "color": "black",
	    "font-size": "16px",
	    "line-height": "18px",
	    "font-family" : "'Courier New', Courier, monospace",
	}
	closeButton = new Layer
		height: 50
		width: 100
		backgroundColor: "red"
		maxX:popup.width
		borderRadius:1
		superLayer: popup
	closeLabel = new Layer
		width: closeButton.width
		height: 30
		x:0
		backgroundColor: "transparent"
		superLayer: closeButton
	closeLabel.centerY()
	closeLabel.html = "<p style='color:white; font-size:18px; text-align:center'> Close </p>"
	closeButton.on Events.Click, ->
		printButton.states.switchInstant "ready"
		printButton.on(Events.Click, spewCode)
		clearButton.on(Events.Click, clearAll)
		popupOpen = false
		pixelsClickable = true
		popup.destroy()
	popup.center()
	popup.bringToFront()
	imageMap = []
	for i in [31..0]
		currentColumn = []
		imageVisualizer = []
		for j in [0..15]
			currentPixel = i*16 + j
			currentPixelState = Pixels[currentPixel].states.state
			if currentPixelState is "on"
				currentColumn.push "1"
				imageVisualizer.push "#"
			else
				currentColumn.push "0"
				imageVisualizer.push "&nbsp"
		imageMap.push "'" + currentColumn.join("") + "'," + "//" + imageVisualizer.join("") + "<br>"
	outputLayer.html = imageMap.join("")

### Pixel Clearer ###
clearAll = (event, layer) ->
	for pixel in Pixels
		pixel.states.switchInstant "off"

touchLayer = new Layer
	height: mainContainer.height
	width: mainContainer.width
	x: mainContainer.x
	y: mainContainer.y
	backgroundColor: "transparent"
touchOriginX = touchLayer.x
touchOriginY = touchLayer.y
touchLayer.states.add
	ready: {scale:1, x: mainContainer.x, y: mainContainer.y}
	clicked: {scale:0}
touchLayer.draggable.enabled = true
touchLayer.on Events.DragStart, ->
	firstPixel = true
	if popupOpen is false
		touchLayer.states.switchInstant "clicked"
touchLayer.on Events.DragMove, ->
	if dragEvent is false and popupOpen is false
		if touchLayer.x > touchOriginX + dragThreshold or touchLayer.x < touchOriginX - dragThreshold
			dragEvent = true
		if touchLayer.y > touchOriginY + dragThreshold or touchLayer.y < touchOriginY - dragThreshold
			dragEvent = true
touchLayer.on Events.DragEnd, ->
	if popupOpen is false
		touchLayer.states.switchInstant "ready"
		dragEvent = false
		pixelsClickable = true

# Button Functions
printButton.on(Events.Click, spewCode)
clearButton.on(Events.Click, clearAll)
