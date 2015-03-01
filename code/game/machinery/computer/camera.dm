/obj/machinery/computer/security
	name = "security camera console"
	desc = "Used to access the various cameras on the station."
	icon_state = "cameras"
	circuit = /obj/item/weapon/circuitboard/security
	var/obj/machinery/camera/current = null
	var/last_pic = 1.0
	var/list/network = list("SS13")
	var/mapping = 0//For the overview file, interesting bit of code.

/obj/machinery/computer/security/check_eye(var/mob/user as mob)
	if ((get_dist(user, src) > 1 || user.eye_blind || !( current ) || !( current.status )) && (!istype(user, /mob/living/silicon)))
		return null
	var/list/viewing = viewers(src)
	if((istype(user,/mob/living/silicon/robot)) && (!(viewing.Find(user))))
		return null
	user.reset_view(current)
	return 1


/obj/machinery/computer/security/attack_hand(var/mob/user as mob)
	if(!stat)

		if (!network)
			ERROR("A computer lacks a network at [x],[y],[z].")
			return
		if (!(istype(network,/list)))
			ERROR("The computer at [x],[y],[z] has a network that is not a list!")
			return

		if(..())
			return

		if(ispAI(usr))
			if(paired != usr)
				user.reset_view()
				user.unset_machine()
				return

		var/list/L = list()
		for (var/obj/machinery/camera/C in cameranet.cameras)
			if((z > ZLEVEL_SPACEMAX || C.z > ZLEVEL_SPACEMAX) && (C.z != z))//if on away mission, can only recieve feed from same z_level cameras
				continue
			L.Add(C)

		camera_sort(L)

		var/list/D = list()
		D["Cancel"] = "Cancel"
		for(var/obj/machinery/camera/C in L)
			if(!C.network)
				ERROR("[C.c_tag] has no camera network.")
				continue
			if(!(istype(C.network,/list)))
				ERROR("[C.c_tag]'s camera network is not a list!")
				continue
			var/list/tempnetwork = C.network&network
			if(tempnetwork.len)
				D[text("[][]", C.c_tag, (C.status ? null : " (Deactivated)"))] = C

		var/t = input(user, "Which camera should you change to?") as null|anything in D
		if(!t)
			if(!isAI(user))
				user.reset_view()
			user.unset_machine()
			return 0

		if (!network)
			ERROR("A computer lacks a network at [x],[y],[z].")
			return
		if (!(istype(network,/list)))
			ERROR("The computer at [x],[y],[z] has a network that is not a list!")
			return
		if(t == "Cancel")
			if(!isAI(user))
				user.reset_view()
			user.unset_machine()
			return 0

		var/obj/machinery/camera/C = D[t]

		if(C)
			if ((get_dist(user, src) > 1 || user.machine != src || user.eye_blind || !( C.can_use() )) && (!istype(user, /mob/living/silicon/ai)) && (!istype(user, /mob/living/silicon/pai)))
				if(!C.can_use() && !isAI(user))
					src.current = null
				return 0
			else
				if(isAI(user))
					var/mob/living/silicon/ai/A = user
					A.eyeobj.setLoc(get_turf(C))
					A.client.eye = A.eyeobj
				else if(ispAI(user))
					var/mob/living/silicon/pai/A = user
					A.switchCamera(C)
				else
					src.current = C
					use_power(50)

				spawn(5)
					attack_hand(user)
		return
	else
		if(!isAI(user))
			user.reset_view()
		user.unset_machine()
		return


/obj/machinery/computer/security/telescreen
	name = "\improper Telescreen"
	desc = "Used for watching an empty arena."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "telescreen"
	network = list("thunder")
	density = 0
	circuit = null
	paiallowed = 0 //2retro

/obj/machinery/computer/security/telescreen/update_icon()
	icon_state = initial(icon_state)
	SetLuminosity(brightness_on)
	if(stat & BROKEN)
		icon_state += "b"
	return

/obj/machinery/computer/security/telescreen/entertainment
	name = "entertainment monitor"
	desc = "Damn, they better have the /tg/ channel on these things."
	icon = 'icons/obj/status_display.dmi'
	icon_state = "entertainment"
	network = list("thunder")
	density = 0
	circuit = null


/obj/machinery/computer/security/wooden_tv
	name = "security camera monitor"
	desc = "An old TV hooked into the stations camera network."
	icon_state = "security_det"
	paiallowed = 0 //2retro


/obj/machinery/computer/security/mining
	name = "outpost camera console"
	desc = "Used to access the various cameras on the outpost."
	icon_state = "miningcameras"
	network = list("MINE")
	circuit = "/obj/item/weapon/circuitboard/mining"
