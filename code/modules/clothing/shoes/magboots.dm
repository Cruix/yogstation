/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	var/magboot_state = "magboots"
	var/magpulse = 0
	var/slowdown_active = 2
	action_button_name = "Toggle Magboots"
	strip_delay = 70
	put_on_delay = 70
	burn_state = -1 //Won't burn in fires

/obj/item/clothing/shoes/magboots/verb/toggle()
	set name = "Toggle Magboots"
	set category = "Object"
	set src in usr
	if(!can_use(usr))
		return
	attack_self(usr)


/obj/item/clothing/shoes/magboots/attack_self(mob/user)
	if(src.magpulse)
		src.flags &= ~SUPERNOSLIP
		src.slowdown = SHOES_SLOWDOWN
	else
		src.flags |= SUPERNOSLIP
		src.slowdown = slowdown_active
	magpulse = !magpulse
	icon_state = "[magboot_state][magpulse]"
	user << "<span class='notice'>You [magpulse ? "enable" : "disable"] the mag-pulse traction system.</span>"
	user.update_inv_shoes()	//so our mob-overlays update
	user.update_gravity(user.mob_has_gravity())

/obj/item/clothing/shoes/magboots/negates_gravity()
	return flags & SUPERNOSLIP

/obj/item/clothing/shoes/magboots/examine(mob/user)
	..()
	user << "Its mag-pulse traction system appears to be [magpulse ? "enabled" : "disabled"]."


/obj/item/clothing/shoes/magboots/advance
	desc = "Advanced magnetic boots that have a lighter magnetic pull, placing less burden on the wearer."
	name = "advanced magboots"
	icon_state = "advmag0"
	magboot_state = "advmag"
	slowdown_active = SHOES_SLOWDOWN
	high_risk = 1

/obj/item/clothing/shoes/magboots/syndie
	desc = "Reverse-engineered magnetic boots that have a heavy magnetic pull. Property of Gorlex Marauders."
	name = "blood-red magboots"
	icon_state = "syndiemag0"
	magboot_state = "syndiemag"

/obj/item/clothing/shoes/magboots/security
	name = "combat magboots"
	desc = "Specialized combat-issued magboots crafted for tactical NT security missions while in the depth of space or when facing a vacuum. Though they are nothing compared to the advanced verson, they will make you more mobile than the standard edition. Has embroidered letters 'NT' enscribed onto the back."
	name = "blood-red magboots"
	icon_state = "magboots0"
	magboot_state = "magboots"
	slowdown_active = 1
