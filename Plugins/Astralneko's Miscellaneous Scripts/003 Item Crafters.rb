def anTRCrafter
	pbItemCrafter(pbGetRecipes("TR"))
end

def anHisuiHealCrafter
	pbItemCrafter(pbGetRecipes("Apothecary"), speech1="\\xn[Apothecary]\\bAh, you wish for some healing items?", speech2="\\xn[Apothecary]\\bTry not to get hurt too bad...")
end