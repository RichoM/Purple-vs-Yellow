extends "ws_webrtc_client.gd"

var rtc_mp: WebRTCMultiplayer = WebRTCMultiplayer.new()
var sealed = false

func _init():
	connect("connected", self, "connected")
	connect("disconnected", self, "disconnected")

	connect("offer_received", self, "offer_received")
	connect("answer_received", self, "answer_received")
	connect("candidate_received", self, "candidate_received")

	connect("lobby_joined", self, "lobby_joined")
	connect("lobby_sealed", self, "lobby_sealed")
	connect("peer_connected", self, "peer_connected")
	connect("peer_disconnected", self, "peer_disconnected")


func start(url, lobby = ""):
	stop()
	sealed = false
	self.lobby = lobby
	connect_to_url(url)


func stop():
	rtc_mp.close()
	close()


func _create_peer(id):
	var peer: WebRTCPeerConnection = WebRTCPeerConnection.new()
	peer.initialize({
		"iceServers": [ { "urls": ["stun:stun.l.google.com:19302",
									"stun:iphone-stun.strato-iphone.de:3478",
									"stun:numb.viagenie.ca:3478",
									"stun:stun.12connect.com:3478",
									"stun:stun.12voip.com:3478",
									"stun:stun.1und1.de:3478",
									"stun:stun.3cx.com:3478",
									"stun:stun.acrobits.cz:3478",
									"stun:stun.actionvoip.com:3478",
									"stun:stun.altar.com.pl:3478",
									"stun:stun.antisip.com:3478",
									"stun:stun.avigora.fr:3478",
									"stun:stun.bluesip.net:3478",
									"stun:stun.cablenet-as.net:3478",
									"stun:stun.callromania.ro:3478",
									"stun:stun.callwithus.com:3478",
									"stun:stun.cheapvoip.com:3478",
									"stun:stun.cloopen.com:3478",
									"stun:stun.commpeak.com:3478",
									"stun:stun.cope.es:3478",
									"stun:stun.counterpath.com:3478",
									"stun:stun.counterpath.net:3478",
									"stun:stun.dcalling.de:3478",
									"stun:stun.demos.ru:3478",
									"stun:stun.dus.net:3478",
									"stun:stun.easycall.pl:3478",
									"stun:stun.easyvoip.com:3478",
									"stun:stun.ekiga.net:3478",
									"stun:stun.epygi.com:3478",
									"stun:stun.etoilediese.fr:3478",
									"stun:stun.faktortel.com.au:3478",
									"stun:stun.freecall.com:3478",
									"stun:stun.freeswitch.org:3478",
									"stun:stun.freevoipdeal.com:3478",
									"stun:stun.gmx.de:3478",
									"stun:stun.gmx.net:3478",
									"stun:stun.halonet.pl:3478",
									"stun:stun.hoiio.com:3478",
									"stun:stun.hosteurope.de:3478",
									"stun:stun.infra.net:3478",
									"stun:stun.internetcalls.com:3478",
									"stun:stun.intervoip.com:3478",
									"stun:stun.ipfire.org:3478",
									"stun:stun.ippi.fr:3478",
									"stun:stun.ipshka.com:3478",
									"stun:stun.it1.hr:3478",
									"stun:stun.ivao.aero:3478",
									"stun:stun.jumblo.com:3478",
									"stun:stun.justvoip.com:3478",
									"stun:stun.l.google.com:19302",
									"stun:stun.linphone.org:3478",
									"stun:stun.liveo.fr:3478",
									"stun:stun.lowratevoip.com:3478",
									"stun:stun.lundimatin.fr:3478",
									"stun:stun.mit.de:3478",
									"stun:stun.miwifi.com:3478",
									"stun:stun.myvoiptraffic.com:3478",
									"stun:stun.netappel.com:3478",
									"stun:stun.netgsm.com.tr:3478",
									"stun:stun.nfon.net:3478",
									"stun:stun.nonoh.net:3478",
									"stun:stun.nottingham.ac.uk:3478",
									"stun:stun.ooma.com:3478",
									"stun:stun.ozekiphone.com:3478",
									"stun:stun.pjsip.org:3478",
									"stun:stun.poivy.com:3478",
									"stun:stun.powervoip.com:3478",
									"stun:stun.ppdi.com:3478",
									"stun:stun.qq.com:3478",
									"stun:stun.rackco.com:3478",
									"stun:stun.rockenstein.de:3478",
									"stun:stun.rolmail.net:3478",
									"stun:stun.rynga.com:3478",
									"stun:stun.schlund.de:3478",
									"stun:stun.sigmavoip.com:3478",
									"stun:stun.sip.us:3478",
									"stun:stun.sipdiscount.com:3478",
									"stun:stun.sipgate.net:10000",
									"stun:stun.sipgate.net:3478",
									"stun:stun.siplogin.de:3478",
									"stun:stun.sipnet.net:3478",
									"stun:stun.sipnet.ru:3478",
									"stun:stun.sippeer.dk:3478",
									"stun:stun.siptraffic.com:3478",
									"stun:stun.sma.de:3478",
									"stun:stun.smartvoip.com:3478",
									"stun:stun.smsdiscount.com:3478",
									"stun:stun.solcon.nl:3478",
									"stun:stun.solnet.ch:3478",
									"stun:stun.sonetel.com:3478",
									"stun:stun.sonetel.net:3478",
									"stun:stun.sovtest.ru:3478",
									"stun:stun.srce.hr:3478",
									"stun:stun.stunprotocol.org:3478",
									"stun:stun.t-online.de:3478",
									"stun:stun.tel.lu:3478",
									"stun:stun.telbo.com:3478",
									"stun:stun.tng.de:3478",
									"stun:stun.twt.it:3478",
									"stun:stun.uls.co.za:3478",
									"stun:stun.usfamily.net:3478",
									"stun:stun.vivox.com:3478",
									"stun:stun.vo.lu:3478",
									"stun:stun.voicetrading.com:3478",
									"stun:stun.voip.aebc.com:3478",
									"stun:stun.voip.blackberry.com:3478",
									"stun:stun.voip.eutelia.it:3478",
									"stun:stun.voipblast.com:3478",
									"stun:stun.voipbuster.com:3478",
									"stun:stun.voipbusterpro.com:3478",
									"stun:stun.voipcheap.co.uk:3478",
									"stun:stun.voipcheap.com:3478",
									"stun:stun.voipgain.com:3478",
									"stun:stun.voipgate.com:3478",
									"stun:stun.voipinfocenter.com:3478",
									"stun:stun.voipplanet.nl:3478",
									"stun:stun.voippro.com:3478",
									"stun:stun.voipraider.com:3478",
									"stun:stun.voipstunt.com:3478",
									"stun:stun.voipwise.com:3478",
									"stun:stun.voipzoom.com:3478",
									"stun:stun.voys.nl:3478",
									"stun:stun.voztele.com:3478",
									"stun:stun.webcalldirect.com:3478",
									"stun:stun.wifirst.net:3478",
									"stun:stun.xtratelecom.es:3478",
									"stun:stun.zadarma.com:3478",
									"stun:stun1.faktortel.com.au:3478",
									"stun:stun1.l.google.com:19302",
									"stun:stun2.l.google.com:19302",
									"stun:stun3.l.google.com:19302",
									"stun:stun4.l.google.com:19302",
									"stun:stun.nextcloud.com:443",
									"stun:relay.webwormhole.io:3478"] } ]
	})
	peer.connect("session_description_created", self, "_offer_created", [id])
	peer.connect("ice_candidate_created", self, "_new_ice_candidate", [id])
	rtc_mp.add_peer(peer, id)
	if id > rtc_mp.get_unique_id():
		peer.create_offer()
	return peer


func _new_ice_candidate(mid_name, index_name, sdp_name, id):
	send_candidate(id, mid_name, index_name, sdp_name)


func _offer_created(type, data, id):
	if not rtc_mp.has_peer(id):
		return
	print("created", type)
	rtc_mp.get_peer(id).connection.set_local_description(type, data)
	if type == "offer": send_offer(id, data)
	else: send_answer(id, data)


func connected(id):
	print("Connected %d" % id)
	rtc_mp.initialize(id, true)


func lobby_joined(lobby):
	self.lobby = lobby


func lobby_sealed():
	sealed = true


func disconnected():
	print("Disconnected: %d: %s" % [code, reason])
	if not sealed:
		stop() # Unexpected disconnect


func peer_connected(id):
	print("Peer connected %d" % id)
	_create_peer(id)


func peer_disconnected(id):
	print("Peer disconnected %d" % id)
	if rtc_mp.has_peer(id): rtc_mp.remove_peer(id)


func offer_received(id, offer):
	print("Got offer: %d" % id)
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.set_remote_description("offer", offer)


func answer_received(id, answer):
	print("Got answer: %d" % id)
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.set_remote_description("answer", answer)


func candidate_received(id, mid, index, sdp):
	print("Candidate received from %d (%s)" % [id, str(sdp)])
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.add_ice_candidate(mid, index, sdp)
