
url = "http://localhost:8080/vlgsocket/Register";
var mo;
var enpass;
$('#reg').click(function(){
	console.log("registering");
	//var modulus;
	var getkeydata={
	'action':'getpubkey',
	'accounttype':'phonenum',
	'account':'13732293375',
	'user':'qiaohan'
	};
	var s1 = $.ajax({
	type: 'POST',
	url: url,
	data: getkeydata, 
	success:function(res) {
		mo=res;
		setMaxDigits(120);
		var key = new RSAKeyPair('10001','',res);
		enpass = encryptedString(key,$('#passwd').val());
		var registerdata = {
		'action':'register',	
		'accounttype':'phonenum',
		'account':'13732293375',
		'user':'qiaohan',
		'passwd':enpass
		};
		var s2 = $.ajax({
		type: 'POST',
		url: url,
		data: registerdata, 
		success:function(res) {
		console.log(res);
		}
		});
		console.log(res.length);
	}
	});
});