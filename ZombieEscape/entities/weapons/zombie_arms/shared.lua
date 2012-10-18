SWEP.Base = "weapon_base"

if SERVER then
	AddCSLuaFile("shared.lua")
	SWEP.Weight = 5
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true
else
	SWEP.PrintName = "Zombie Arms"
	SWEP.Slot = 0
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.DrawWeaponInfoBox = false
	
	killicon.Add( "zombie_arms", "HUD/killicons/default", Color( 255, 80, 0, 255 ) )
end


SWEP.ViewModel		= Model("models/weapons/v_zombiearms.mdl")
SWEP.WorldModel		= Model("models/weapons/w_knife_t.mdl")
SWEP.ViewModelFlip	= false

SWEP.HoldType		= "knife"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay			= 0.5	-- second(s)

SWEP.Secondary = SWEP.Primary

SWEP.Mins = Vector(-8, -8, -8)
SWEP.Maxs = Vector(8, 8, 8)

SWEP.AttackSound = {
	Sound("npc/zombie/zo_attack1.wav"),
	Sound("npc/zombie/zo_attack2.wav")
}
SWEP.MissSound = {
	Sound("npc/zombie/claw_miss1.wav"),
	Sound("npc/zombie/claw_miss2.wav")
}
SWEP.HitSound = {
	Sound("npc/zombie/claw_strike1.wav"),
	Sound("npc/zombie/claw_strike2.wav"),
	Sound("npc/zombie/claw_strike3.wav")
}
SWEP.HitTable = {
	"prop_physics",
	"func_breakable"
}
	
function SWEP:Initialize()
	self:DrawShadow(false)
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Precache()
end

function SWEP:Think()
	if self:GetNextPrimaryFire() > CurTime() then
		-- Speed up melee animations
		self.Owner:GetViewModel():SetPlaybackRate(3.0)
	end
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
	local tracedata = {
		start = self.Owner:GetShootPos(),
		endpos 	= self.Owner:GetShootPos() + (self.Owner:GetAimVector() * 85),
		mins	= self.Mins,
		maxs = self.Maxs,
		filter = { self.Owner }
	}
	
	-- Zombies shouldn't hit other zombies, otherwise: http://i.imgur.com/YEXSS.jpg
	for _, ply in pairs(team.GetPlayers(TEAM_ZOMBIES)) do
		table.insert( tracedata.filter, ply )
	end
	
	local tr = util.TraceHull(tracedata)
	
	local EmitSound = table.Random(self.MissSound)
	
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
	
	if(tr.Hit) then
		EmitSound = table.Random(self.HitSound)
		if(IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsNPC() or table.HasValue(self.HitTable, tr.Entity:GetClass()))) then
			if(SERVER) then
				local dmginfo = DamageInfo()
				dmginfo:SetDamage(math.random(45,55))
				dmginfo:SetDamageType(DMG_CLUB)
				dmginfo:SetInflictor(self.Owner)
				dmginfo:SetAttacker(self.Owner)
				tr.Entity:TakeDamageInfo(dmginfo)
			end
		--else
			--EmitSound = self.HitSoundWall
		end
	end
	
	if(IsFirstTimePredicted()) then
		if(EmitSound) then
			self.Weapon:EmitSound(EmitSound)
		end
	end
end

function SWEP:Reload()
	return false
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	return true
end

function SWEP:Holster()
	self.Weapon:SendWeaponAnim(ACT_VM_HOLSTER)
	return true
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:DrawWorldModel()
	-- don't draw anything
end