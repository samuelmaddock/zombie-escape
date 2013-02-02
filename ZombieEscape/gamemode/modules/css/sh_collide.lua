/*-------------------------------------------------
	Collision Rules
-------------------------------------------------*/

function GM:ShouldCollide( ent1, ent2 )

	-- CS:S Collision Rules
	local collisionGroup0 = ent1:GetCollisionGroup()
	local collisionGroup1 = ent2:GetCollisionGroup()

	if collisionGroup0 > collisionGroup1 then
		local old = collisionGroup0
		collisionGroup0 = collisionGroup1
		collisionGroup1 = old
	end

	if collisionGroup0 == COLLISION_GROUP_PLAYER_MOVEMENT and 
		collisionGroup1 == COLLISION_GROUP_WEAPON then
		return false
	end

	if (collisionGroup0 == COLLISION_GROUP_PLAYER or collisionGroup0 == COLLISION_GROUP_PLAYER_MOVEMENT) and
		collisionGroup1 == COLLISION_GROUP_PUSHAWAY then
		return false
	end

	if collisionGroup0 == COLLISION_GROUP_DEBRIS and collisionGroup1 == COLLISION_GROUP_PUSHAWAY then
		return true
	end

	return self.BaseClass:ShouldCollide( ent1, ent2 )

end

hook.Add( "OnEntityCreated", "CSSCustomCollisions", function( ent )
	ent:SetCustomCollisionCheck(true)
end )