/client/proc/cmd_mentor_say(msg as text)
	set category = "Special Verbs"
	set name = "Msay"
	set hidden = 1
	if(!check_rights(0))	return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)	return

	log_admin("[key_name(src)] : [msg]")
	msg = keywords_lookup(msg)
	if(check_rights(R_ADMIN,0))
		var/adminmsg = "<span class='mentor'><span class='prefix'>MENTOR:</span> <EM>[key_name(usr, 1)]</EM> (<a href='?_src_=holder;adminplayerobservefollow=\ref[mob]'>FLW</A>): <span class='message'>[msg]</span></span>"
		var/mentormsg = "<span class='mentor'><span class='prefix'>MENTOR:</span> <EM>[key_name(usr, 1)]</EM>: <span class='message'>[msg]</span></span>"//mentors don't get the href.
		admins << adminmsg
		mentors << mentormsg

	//I don't know what feedback_add_details() does or if I should use it here.
	//feedback_add_details("admin_verb","M") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

