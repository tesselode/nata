local ShootSystem = {}

function ShootSystem:filter()
	return self.x and self.y and self.shoot
end

function ShootSystem:add()
	self.shoot._canShoot = true
	if self.shoot.every then
		self.timer:every(self.shoot.every, function()
			self.entities:callOn(self, 'shoot')
		end)
	end
end

function ShootSystem:shoot()
	if self.shoot._canShoot then
		self.entities:queue(self.shoot.bulletEntity(self.entities,
			self.x + self.w/2, self.y + self.h/2))
		if self.shoot.reloadTime then
			self.shoot._canShoot = false
			self.timer:after(self.shoot.reloadTime, function()
				self.shoot._canShoot = true
			end)
		end
	end
end

return ShootSystem