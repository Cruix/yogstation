/obj/effect/proc_holder/spell/proc/abomination_check(var/mob/living/carbon/human/H)
	if(!H || !istype(H))
		return
	if(H.dna.species.id == "abomination")
		return 1
	if(!H.dna.species.id == "abomination") usr << "<span class='warning'>You cannot use this ability in your current body.</span>"



/obj/effect/proc_holder/spell/aoe_turf/abomination/screech //Stuns anyone in view range.
	name = "Screech"
	desc = "Releases a terrifying screech, freezing those who hear."
	panel = "Abomination"
	range = 7
	charge_max = 150
	clothes_req = 0
	sound = 'sound/effects/creepyshriek.ogg'

/obj/effect/proc_holder/spell/aoe_turf/abomination/screech/cast(list/targets)
	if(!abomination_check(usr))
		charge_counter = charge_max
		return
	playMagSound()
	usr.visible_message("<span class='warning'><b>[usr] opens their maw and releases a horrifying shriek!</span>")
	for(var/turf/T in targets)
		for(var/mob/living/carbon/M in T.contents)
			if(M == usr) //No message for the user, of course
				continue
			var/mob/living/carbon/human/H = M
			if(istype(H.ears, /obj/item/clothing/ears/earmuffs))
				H.Stun(2)
				continue
			M << "<span class='userdanger'>You freeze in terror, your blood turning cold from the sound of the scream!</span>"
			M.Stun(5)

/obj/effect/proc_holder/spell/targeted/abomination/abom_fleshmend
	name = "Fleshmend"
	desc = "Rapidly replaces damaged flesh, healing any physical damage sustained."
	panel = "Abomination"
	charge_max = 300
	clothes_req = 0
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/abomination/abom_fleshmend/cast(list/targets)
	if(!abomination_check(usr))
		return
	usr.visible_message("<span class='warning'>[usr]'s skin shifts and pulses, any damage rapidly vanishing!</span>")
	spawn(0)
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			H.restore_blood()
			H.remove_all_embedded_objects()
	var/mob/living/carbon/human/user = usr
	for(var/i = 0, i<10,i++)
		user.adjustBruteLoss(-10)
		user.adjustOxyLoss(-10)
		user.adjustFireLoss(-10)
		sleep(10)




/obj/effect/proc_holder/spell/targeted/abomination/devour
	name = "Devour"
	desc = "Eat a target, absorbing their genetic structure and completely destroying their body."
	panel = "Abomination"
	charge_max = 0
	clothes_req = 0
	range = 1


/obj/effect/proc_holder/spell/targeted/abomination/devour/cast(list/targets,mob/user = usr)
	if(!abomination_check(usr))
		return
	var/datum/changeling/changeling = user.mind.changeling
	if(changeling.isabsorbing)
		user << "<span class='warning'>We are already absorbing!</span>"
		return
	var/obj/item/weapon/grab/G = user.get_active_hand()
	if(!istype(G))
		user << "<span class='warning'>We must be grabbing a creature in our active hand to devour them!</span>"
		return
	if(G.state < GRAB_AGGRESSIVE)
		user << "<span class='warning'>We must have a tighter grip to devour this creature!</span>"
		return
	var/mob/living/carbon/target = G.affecting
	changeling.can_absorb_dna(user,target)

	changeling.isabsorbing = 1
	var/stage = 1
	if(stage == 1)
		user << "<span class='notice'>This creature is compatible. We must hold still...</span>"
		user.visible_message("<span class='warning'><b>[user] opens their mouth wide, lifting up [target]!</span>", "<span class='notice'>We prepare to devour [target].</span>")

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(user, target, 50))
			user << "<span class='warning'>Our devouring of [target] has been interrupted!</span>"
			changeling.isabsorbing = 0
			return

	user.visible_message("<span class='danger'>[user] devours [target], vomiting up some things!</span>", "<span class='notice'>We have devoured [target].</span>")
	target << "<span class='userdanger'>You are eaten by the abomination!</span>"

	if(changeling.has_dna(target.dna))
		changeling.remove_profile(target)
		changeling.absorbedcount--
	changeling.add_profile(target, user)

	if(user.nutrition < NUTRITION_LEVEL_WELL_FED)
		user.nutrition = min((user.nutrition + target.nutrition), NUTRITION_LEVEL_WELL_FED)

	if(target.mind)//if the victim has got a mind

		target.mind.show_memory(src, 0) //I can read your mind, kekeke. Output all their notes.

	//Some of target's recent speech, so the changeling can attempt to imitate them better.
	//Recent as opposed to all because rounds tend to have a LOT of text.
		var/list/recent_speech = list()

		if(target.say_log.len > LING_ABSORB_RECENT_SPEECH)
			recent_speech = target.say_log.Copy(target.say_log.len-LING_ABSORB_RECENT_SPEECH+1,0) //0 so len-LING_ARS+1 to end of list
		else
			for(var/spoken_memory in target.say_log)
				if(recent_speech.len >= LING_ABSORB_RECENT_SPEECH)
					break
				recent_speech += spoken_memory

		if(recent_speech.len)
			user.mind.store_memory("<B>Some of [target]'s speech patterns, we should study these to better impersonate them!</B>")
			user << "<span class='boldnotice'>Some of [target]'s speech patterns, we should study these to better impersonate them!</span>"
			for(var/spoken_memory in recent_speech)
				user.mind.store_memory("\"[spoken_memory]\"")
				user << "<span class='notice'>\"[spoken_memory]\"</span>"
			user.mind.store_memory("<B>We have no more knowledge of [target]'s speech patterns.</B>")
			user << "<span class='boldnotice'>We have no more knowledge of [target]'s speech patterns.</span>"

		if(target.mind.changeling)//If the target was a changeling, suck out their extra juice and objective points!
			changeling.chem_charges += min(target.mind.changeling.chem_charges, changeling.chem_storage)
			changeling.absorbedcount += (target.mind.changeling.absorbedcount)

			target.mind.changeling.stored_profiles.len = 1
			target.mind.changeling.absorbedcount = 0


	changeling.chem_charges=min(changeling.chem_charges+50, changeling.chem_storage)

	changeling.isabsorbing = 0
	changeling.canrespec = 1
	for(var/obj/item/I in target) //drops all items
		target.unEquip(I)
	new /obj/effect/decal/remains/human(target.loc)
	qdel(target)




/obj/effect/proc_holder/spell/targeted/abomination/abom_revert
	name = "Revert"
	desc = "Returns you to a normal, human form."
	panel = "Abomination"
	charge_max = 0
	clothes_req = 0
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/abomination/abom_revert/cast(list/targets,mob/user = usr)
	var/mob/living/carbon/human/H = user
	var/datum/changeling/changeling = user.mind.changeling
	var/transform_or_no=alert(user,"Are you sure you want to revert?",,"Yes","No")
	switch(transform_or_no)
		if("No")
			user << "<span class='warning'>You decide not to revert."
			return
		if("Yes")
			if(!abomination_check(usr))
				user << "<span class='warning'>You're already reverted!</span>"
				for(var/spell in user.mind.spell_list)
					if(istype(spell, /obj/effect/proc_holder/spell/targeted/abomination)|| istype(spell, /obj/effect/proc_holder/spell/aoe_turf/abomination))
						user.mind.spell_list -= spell
						qdel(spell)
				return
			user <<"<span class='notice'>You transform back into a humanoid form, leaving you exhausted!</span>"
			var/datum/mutation/human/HM = mutations_list[HULK]
			if(H.dna && H.dna.mutations)
				HM.force_lose(H)
			changeling.reverting = 1
			changeling.geneticdamage += 10
			user.Stun(5)


