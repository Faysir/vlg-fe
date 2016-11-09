function GameServer(gamecallback){
	this.wsurl = "ws://localhost:8080/vlgsocket/game";
	var that = this;
	var stat = 0;
	var user;
	var isspeaking=false;
	//0--not log in
	//1--loged and in hall
	//2--entered room , xiazuo , not mai
	//3--entered room , xiazuo , mai
	//4--entered room , shangzuo , game not started, not mai
	//5--entered room , shangzuo , game not started, mai
	//6--entered room , game started , not speaking
	//7--entered room , game started , speaking
	//8--entered room , game started , dead
	var ws;
	this.enterputong = function(roomid){
		roomid = Number(roomid);
		if(stat == 1 && roomid>=0 && roomid<putongplayernum)
		{
			ws.send("action enter putong "+roomid);
			return 0;
		}
		else
			return 1;
	}
	this.enterjiazu = function(roomid){
		roomid = Number(roomid);
		if(stat == 1 && roomid>=0 && roomid<jiazuplayernum)
		{
			ws.send("action enter jiazu "+roomid);
			return 0;
		}
		else
			return 1;
	}
	this.shangmai = function(){
		if(stat!=2&&stat!=4){
			return 1;
		}
		ws.send("action shangmai");
		return 0;
	}
	this.xiamai = function(){
		if(stat!=3&&stat!=5){
			return 1;
		}
		ws.send("action xiamai");
		return 0;
	}
	this.shangzuo = function(){
		if(stat!=2&&stat!=3){
			return 1;
		}
		ws.send("action shangzuo");
		return 0;
	}
	this.xiazuo = function(){
		if(stat!=4&&stat!=5){
			return 1;
		}
		ws.send("action xiazuo");
		return 0;
	}
	
	this.quitroom = function(){
		if(stat!=2)
			return 1;
		stat = 1;
		ws.send("action quit")
		return 0;
	}
	this.login = function(u,p){
		if(stat!=0)
			return 1;
		user = u;
		passwd = p;
		ws.send("query key");
		return 0;
	}
	var on_login = gamecallback.onlogin;
	var on_putong = gamecallback.onputong;
	var on_jiazu = gamecallback.onjiazu;
	var on_enterroom = gamecallback.onenterroom;
	var on_roomplayer = gamecallback.onroomplayer;
	var on_speaker = gamecallback.onspeaker;
	ws = new WebSocket(this.wsurl);
	ws.onopen = wsopen;
	ws.onclose = wsclose;
	ws.onmessage = wsmessage;
	ws.onerror = wserror; 
	ws.binaryType = "blob";
	
	function sendaudio(blob){
		//var audio = new Audio();
		//audio.src = window.URL.createObjectURL(blob)
		//audio.play()
		ws.send(blob)
		console.log(blob);
	}
	var rec = new Qrecorder(sendaudio);
	
	var putongplayernum,jiazuplayernum;
	var user,passwd_en,passwd;
	
	function wsopen(evt) {
		
	}; 
	function wsclose(evt) { 

	}; 
	function wsmessage(evt) { 
		if(typeof(evt.data)!="string"){
			bb = evt.data
			var audio = new Audio();
			audio.src = window.URL.createObjectURL(bb)
			audio.play()
			console.log(evt.data);
			return
		}
		console.log(evt.data)
		mess = evt.data.split(" ");
		switch(mess[0]){
			case "pubkey":
				console.log("pubkey:"+mess[1]);
				passwd_en = passwd;
				ws.send("login "+user+" "+passwd_en);
			break;
			case "login":
				var ss = Number(mess[1])
				on_login(ss);
				if(ss==0)
				{	
					stat = 1;
					ws.send("query roomputong");
					ws.send("query roomjiazu");
					//rec.startrec()
				}
			break;
			case "roomputong":
				var n = new Array();
				var nn = mess[1].split('_');
				for(k in nn){
					n.push(Number(nn[k]));
				}
				putongplayernum=n.length;
				on_putong(n);
				console.log(mess[1]);
			break;
			case "roomjiazu":
				var n = new Array();
				var nn = mess[1].split('_');
				for(k in nn){
					n.push(Number(nn[k]));
				}
				jiazuplayernum=n.length;
				on_jiazu(n);
				console.log(mess[1]);
			break;
			case "enter":
				var ss = Number(mess[1])
				on_enterroom(ss);
				if(ss==0)
					stat = 2;
			break;
			case "roomplayer":
				var p = new Array();
				var s = new Array();
				var m = mess[1].split("#");
				for(var i=0;i<3;i++){
					var ss = m[i].split(";")
					var players = new Array();
					var playerstatus = new Array();
					for(k in ss){
						var t = ss[k].split(",")
						players.push(t[0])
						playerstatus.push(t[1])
					}
					p.push(players)
					s.push(playerstatus)
				}
				on_roomplayer(p,s)
			break;
			case "shangzuo":
				var r = Number(mess[1])
				if(r == 0)
				{	if(stat == 2)
						stat = 4
					else if(stat == 3)
						stat =5
				}
			break;
			case "xiazuo":
				var r = Number(mess[1])
				if(r == 0)
				{	if(stat == 4)
						stat = 2
					else if(stat == 5)
						stat =3
				}
			break;
			case "shangmai":
				var r = Number(mess[1])
				if(r == 0)
				{	if(stat == 2)
						stat = 3
					else if(stat == 4)
						stat =5
				}
			break;
			case "xiamai":
				var r = Number(mess[1])
				if(r == 0)
				{	if(stat == 3)
						stat = 2
					else if(stat == 5)
						stat =4
				}
			break;
			case "speakover":
				if(stat == 3)
					stat = 2
				else if(stat == 5)
					stat =4
				else if(stat == 7)
						stat =6
			break;
			case "speaker":
				var r = mess[1]
				if(r=='#')
				{	if(stat == 3)
						stat = 2
					else if(stat == 5)
						stat =4
					else if(stat == 7)
						stat =6
				}
				on_speaker(mess[1])
			break;
			case "gamestart":
				if(stat==4|| stat==5)
					stat = 6;
			break;
			default:
			break;
		}
	}; 
	function wserror(evt){
	
	};
};

