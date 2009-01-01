
var LastfmPlayer = Class.create({
  initialize: function(div_id, api_key, artist, track) {
		this.div_id = div_id;
		this.load_json("http://ws.audioscrobbler.com/2.0/?format=json&method=track.getinfo&callback=lastfm_player.load_player&api_key="+api_key+"&artist="+artist+"&track="+track);
  },

	load_json: function(url) {
		var script = document.createElement( 'script' );
		script.type = 'text/javascript';
		script.src = url;
		document.getElementsByTagName('head')[0].appendChild( script );
	},
	
	load_player: function(data) {
		var track_id = data.track.id;
		var track_name = data.track.name;
		var artist_name = data.track.artist.name;
		var track_picture = '';
		if( data.track.album && data.track.album.image) {
			track_picture = data.track.album.image[0]['#text'];
		}
		var flashvars = 'lang=en&amp;lfmMode=playlist&amp;FOD=true&amp;resourceID='+track_id+'&amp;resname='+track_name+'&amp;restype=track&amp;artist='+artist_name+'&amp;albumArt='+track_picture;
		var embed = '<embed height="221" width="300" align="middle" swliveconnect="true" name="lfmPlayer" id="lfmPlayer" allowfullscreen="true" allowscriptaccess="always" flashvars="'+flashvars+'" bgcolor="#fff" wmode="transparent" quality="high" menu="true" pluginspage="http://www.macromedia.com/go/getflashplayer" src="http://cdn.last.fm/webclient/s12n/s/5/lfmPlayer.swf" type="application/x-shockwave-flash"/>';
		$(this.div_id).innerHTML = embed;
	}
	
});

