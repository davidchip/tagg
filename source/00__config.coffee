tag = {}
tags = {}

tag.nets = {
	local: {
		dir: "/bases"
		extensions: [".html", ".js"]
		hostname: window.location.hostname	
		port: window.location.port
		protocol: window.location.protocol
	}
	remote: {
		dir: ""
		extensions: [".html", ".js"]
		hostname: "stream.helix.to"
		port: 80
		protocol: "http:"
	}
}


