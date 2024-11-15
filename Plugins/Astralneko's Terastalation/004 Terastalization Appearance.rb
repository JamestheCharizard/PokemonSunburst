# Not tested yet with EBDX - Terastalized sprite coloring
class PokemonBattlerSprite
	alias astraltera_setPokemonBitmap setPokemonBitmap
	def setPokemonBitmap(pkmn,back=false)
		astraltera_setPokemonBitmap(pkmn,back)
		if $Astralneko_Temp.terastalization_flag
			terabitmap = GameData::Species.sprite_bitmap_from_pokemon(@pkmn, back)
			tera_rgb = {}
			tera_color = AstralnekoConfig.getTeraTypeColors(@pkmn.tera_type)
			tera_rgb[:red] = tera_color.red
			tera_rgb[:green] = tera_color.green
			tera_rgb[:blue] = tera_color.blue
			tera_hsl = anRGBtoHSL(tera_rgb)
			terabitmap = anColorizeBitmap(terabitmap,tera_hsl[:hue],tera_hsl[:saturation],tera_hsl[:lightness])
			self.bitmap = terabitmap
		end
	end
end