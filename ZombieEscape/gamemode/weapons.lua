
// DO NOT EDIT THIS FILE!

// Globals that we need 
//local gmod = gmod
local pairs = pairs
local unpack = unpack
local type = type
local tostring = tostring
local ErrorNoHalt = ErrorNoHalt
local table = table

/*---------------------------------------------------------
   Name: weapons
   Desc: A module to manage adding and fetching SWEPS
---------------------------------------------------------*/
module("weapons")

local Aliases = {}
local WeaponList = {}


/*---------------------------------------------------------
   Name: TableInherit( t, base )
   Desc: Copies any missing data from base to t
---------------------------------------------------------*/
local function TableInherit( t, base )

	for k, v in pairs( base ) do 
		
		if ( t[k] == nil ) then	
			t[k] = v 
		elseif ( k != "BaseClass" && type(t[k]) == "table" ) then
			TableInherit( t[k], v )
		end
		
	end
	
	t["BaseClass"] = base
	
	return t

end


/*---------------------------------------------------------
   Name: Register( table, string, bool )
   Desc: Used to register your SWEP with the engine
---------------------------------------------------------*/
function Register( t, name, reload )

	// Don't load it twice unless we're reloading
	if (!reload && WeaponList[ name ] != nil ) then
		return
	end
	
	// This gives the illusion of inheritence
	//if ( name != "weapon_base" ) then
	//	t = TableInherit( t, Get( "weapon_base" ) )
	//end
	
	t.Classname = name
	t.ClassName = name

	WeaponList[ name ] = t	

end

/*---------------------------------------------------------
   Name: Get( string )
   Desc: Get a weapon by name.
---------------------------------------------------------*/
function Get( name )

	-- Do we have an alias?
	if ( Aliases[ name ] ) then
		name = Aliases[ name ]
	end

	local Stored = GetStored(name)
	if ( !Stored ) then return nil end

	// Create/copy a new table
	local retval = table.Copy( Stored )
	
	// If we're not derived from ourselves (a base weapon) 
	// then derive from our 'Base' weapon.
	if ( retval.Base != name ) then
	
		local BaseWeapon = Get( retval.Base )
		
		if ( !BaseWeapon ) then
			ErrorNoHalt( "SWEP (", name, ") is derived from non existant SWEP (", retval.Base, ") - Expect errors!" )
		else
			retval = TableInherit( retval, Get( retval.Base ) )
		end
		
	end

	return retval
end

/*---------------------------------------------------------
   Name: GetStored( string )
   Desc: Gets the REAL weapon table, not a copy
---------------------------------------------------------*/
function GetStored( name )
	return WeaponList[ name ]
end

/*---------------------------------------------------------
   Name: GetList( string )
   Desc: Get a list of all the registered SWEPs
---------------------------------------------------------*/
function GetList()
	local result = {}
	
	for k,v in pairs(WeaponList) do
		table.insert(result, v)
	end
	
	return result
end

/*---------------------------------------------------------
   Name: Remove( string )
   Desc: Remove a registered SWEP
---------------------------------------------------------*/
function Remove( name )
	WeaponList[ name ] = nil
end

--[[---------------------------------------------------------
   Name: Alias
-----------------------------------------------------------]]
function Alias( From, To )

	Aliases[ From ] = To
	
end
