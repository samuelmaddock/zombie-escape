function util.TranslateToPlayerModel( model )

	if model == "models/player/urban.mbl" then
		return "models/player/urban.mdl"
	end

	if model == "models/killingfloor/haroldlott.mdl" then
		return "models/player/haroldlott.mdl"
	end

	model = string.Replace( model, "models/humans/", "models/" )
	model = string.Replace( model, "models/", "models/" )

	/*if !string.find( model, "models/player/" ) then
		model = string.Replace( model, "models/", "models/player/" )
	end*/

	return model

end