CVars.Debug = CreateConVar( "ze_debug", 0, FCVAR_REPLICATED, "Enable/disable debug mode." )

function IsDebugMode()
	return CVars.Debug:GetBool()
end