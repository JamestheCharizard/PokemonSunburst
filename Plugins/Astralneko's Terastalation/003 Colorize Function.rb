# Colorizes a bitmap with the given HSL values
def anColorizeBitmap(bitmap, hue = 0.0, saturation = 0.0, lightness = 0.0)
	# Hue is 1-360, saturation and lightness are percents
	# Image's hue is set to new hue, while saturation and lightness are added to by S and L
	newHSL = {hue: hue, saturation: saturation, lightness: lightness}
	for i in 0..bitmap.width
		for j in 0..bitmap.height
			bitmap = anColorizePixel(bitmap,i,j,newHSL)
		end
	end
	return bitmap
end

# Colorizes a bitmap with the given HSL values, but only for pixels where xpos+ypos is within range of frame
def anColorizeBitmapOnlyOnDiagonal(bitmap, hue = 0.0, saturation = 0.0, lightness = 0.0, frame = 0, range = 0)
	# Hue is 1-360, saturation and lightness are percents
	# Image's hue is set to new hue, while saturation and lightness are added to by S and L
	newHSL = {hue: hue, saturation: saturation, lightness: lightness}
	for i in 0..bitmap.width
		for j in 0..bitmap.height
			if i+j <= frame+range && i+j >= frame-range
				bitmap = anColorizePixel(bitmap,i,j,newHSL)
			end
		end
	end
	return bitmap
end

# newHSL is a hash with values hue, saturation, lightness
def anColorizePixel(bitmap,x,y, newHSL)
	color = bitmap.get_pixel(x,y)
	# Do not bother trying to colorize empty pixels
	if !color.alpha.zero?
		# Convert to HSL
		thisPixelRGB = {red: color.red,green: color.green,blue: color.blue}
		thisPixelHSL = anRGBtoHSL(thisPixelRGB)
		# Get the new HSL
		thisPixelHSL[:hue] = newHSL[:hue]
		thisPixelHSL[:saturation] += newHSL[:saturation]
		thisPixelHSL[:lightness] += newHSL[:lightness]
		# Reconvert to RGB
		newRGB = anHSLtoRGB(thisPixelHSL)
		color.red = newRGB[:red]
		color.blue = newRGB[:blue]
		color.green = newRGB[:green]
		# Color the pixel
		bitmap.set_pixel(x,y,color)
	end
	return bitmap
end

# originalRGB is a hash with values red, blue, green
def anRGBtoHSL(originalRGB)
	red_ratio = originalRGB[:red]/255r
	green_ratio = originalRGB[:green]/255r
	blue_ratio = originalRGB[:blue] / 255r
	c_max = [red_ratio, green_ratio, blue_ratio].max
	c_min = [red_ratio, green_ratio, blue_ratio].min
	chroma = c_max-c_min
	# If chroma is 0, hue doesn't matter
	if chroma == 0r
	    hue = 0r
	elsif c_max == red_ratio
		hue = ((green_ratio-blue_ratio)/chroma)%6r
	elsif c_max == green_ratio
		hue = ((blue_ratio-red_ratio)/chroma)+2r
	elsif c_max == blue_ratio
		hue = ((red_ratio-green_ratio)/chroma)+4r
	end
	hue *= 60r
	hue = hue % 360r
	# Find lightness (average of max and min chromas)
	lightness = (c_max + c_min)/2
	# If chroma is 0 or lightness is 0 or 1, then saturation doesn't matter
	if chroma == 0r || lightness == 0r || lightness == 1r
		saturation = 0r
	elsif lightness <= 1r/2r
		saturation = chroma / (2*lightness)
	else
		saturation = chroma / (2 - (2*lightness))
	end
	return {hue: hue.to_f, saturation: saturation.to_f, lightness: lightness.to_f}
end

# originalHSL is a hash with values hue, saturation, lightness
def anHSLtoRGB(originalHSL)
	hue = Rational(originalHSL[:hue])
	hue = hue % 360r
	saturation = Rational(originalHSL[:saturation])
	lightness = Rational(originalHSL[:lightness])
	chroma = (1r-((2r*lightness)-1).abs)*saturation
	value_x = (hue/60r)%2r
	value_x -= 1r
	value_x = value_x.abs
	value_x = 1 - value_x
	value_x *= chroma
	value_m = lightness - chroma/2r
	red_ratio, blue_ratio, green_ratio = 0r
	case hue
		when 0r...60r
			red_ratio = chroma
			green_ratio = value_x
			blue_ratio = 0r
		when 60r...120r
			red_ratio = value_x
			green_ratio = chroma
			blue_ratio = 0r
		when 120r...180r
			red_ratio = 0
			green_ratio = chroma
			blue_ratio = value_x
		when 180r...240r
			red_ratio = 0r
			green_ratio = value_x
			blue_ratio = chroma
		when 240r...300r
			red_ratio = value_x
			green_ratio = 0r
			blue_ratio = chroma
		when 300r...360r
			red_ratio = chroma
			green_ratio = 0r
			blue_ratio = value_x
	end
	red = red_ratio+value_m
	red *= 255r
	green = green_ratio+value_m
	green *= 255r
	blue = blue_ratio+value_m
	blue *= 255r
	return {red: red.round, green: green.round, blue: blue.round}
end