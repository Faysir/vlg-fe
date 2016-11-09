$(window).load(function init() {
	try {
		window.AudioContext = window.AudioContext || window.webkitAudioContext;
		navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia;
		window.URL = window.URL || window.webkitURL;
	} catch (e) {
		console.log(e);
	}
});

function Qrecorder(process){
	var audio_context;
	var recorder;
	var input;
	var started=false;
	var timer;
	var config = {};
    config.sampleBits = 16; //config.sampleBits || 8;      //采样数位 8, 16
    config.sampleRate =  44100/6 ;   //采样率(1/6 44100)
	var audioData = {
            size: 0          //录音文件长度
            , buffer: []     //录音缓存
            , inputSampleRate: 44100/6//audio_context.sampleRate    //输入采样率
            , inputSampleBits: 16       //输入采样数位 8, 16
            , outputSampleRate: config.sampleRate    //输出采样率
            , oututSampleBits: config.sampleBits       //输出采样数位 8, 16
            , input: function (data) {
                //this.buffer.push(new Float32Array(data));
				this.buffer.push(data);
                this.size += data.length;
            }
            , compress: function () { //合并压缩
                //合并
                var data = new Float32Array(this.size);
                var offset = 0;
                for (var i = 0; i < this.buffer.length; i++) {
                    data.set(this.buffer[i], offset);
                    offset += this.buffer[i].length;
                }
				console.log(this.buffer.length);
				console.log(this.size);
				//var length = data.length
				return data;
                //压缩
                 var compression = parseInt(this.inputSampleRate / this.outputSampleRate);
                var length = data.length / compression;
                var result = new Float32Array(length);
                var index = 0, j = 0;
                while (index < length) {
                    result[index] = data[j];
                    j += compression;
                    index++;
                }
                return result; 
            }
            , encodeWAV: function () {
                var sampleRate = Math.min(this.inputSampleRate, this.outputSampleRate);
                var sampleBits = Math.min(this.inputSampleBits, this.oututSampleBits);
                var bytes = this.compress();
                var dataLength = bytes.length * (sampleBits / 8);
                var buffer = new ArrayBuffer(44 + dataLength);
                var data = new DataView(buffer);

                var channelCount = 1;//单声道
                var offset = 0;

                var writeString = function (str) {
                    for (var i = 0; i < str.length; i++) {
                        data.setUint8(offset + i, str.charCodeAt(i));
                    }
                }
                
                // 资源交换文件标识符 
                writeString('RIFF'); offset += 4;
                // 下个地址开始到文件尾总字节数,即文件大小-8 
                data.setUint32(offset, 36 + dataLength, true); offset += 4;
                // WAV文件标志
                writeString('WAVE'); offset += 4;
                // 波形格式标志 
                writeString('fmt '); offset += 4;
                // 过滤字节,一般为 0x10 = 16 
                data.setUint32(offset, 16, true); offset += 4;
                // 格式类别 (PCM形式采样数据) 
                data.setUint16(offset, 1, true); offset += 2;
                // 通道数 
                data.setUint16(offset, channelCount, true); offset += 2;
                // 采样率,每秒样本数,表示每个通道的播放速度 
                data.setUint32(offset, sampleRate, true); offset += 4;
                // 波形数据传输率 (每秒平均字节数) 单声道×每秒数据位数×每样本数据位/8 
                data.setUint32(offset, channelCount * sampleRate * (sampleBits / 8), true); offset += 4;
                // 快数据调整数 采样一次占用字节数 单声道×每样本的数据位数/8 
                data.setUint16(offset, channelCount * (sampleBits / 8), true); offset += 2;
                // 每样本数据位数 
                data.setUint16(offset, sampleBits, true); offset += 2;
                // 数据标识符 
                writeString('data'); offset += 4;
                // 采样数据总数,即数据总大小-44 
                data.setUint32(offset, dataLength, true); offset += 4;
                // 写入采样数据 
                if (sampleBits === 8) {
                    for (var i = 0; i < bytes.length; i++, offset++) {
                        var s = Math.max(-1, Math.min(1, bytes[i]));
                        var val = s < 0 ? s * 0x8000 : s * 0x7FFF;
                        val = parseInt(255 / (65535 / (val + 32768)));
                        data.setInt8(offset, val, true);
                    }
                } else {
                    for (var i = 0; i < bytes.length; i++, offset += 2) {
                        var s = Math.max(-1, Math.min(1, bytes[i]));
                        data.setInt16(offset, s < 0 ? s * 0x8000 : s * 0x7FFF, true);
                    }
                }
				this.buffer=[];
				this.size=0;
                return new Blob([data], { type: 'audio/wav' });
            }
        };
	function rec2(){
		recorder.getBuffer(function(buffers) {
        process(buffers);
		newSource = audio_context.createBufferSource();
		newBuffer = audio_context.createBuffer( 2, buffers[0].length, audio_context.sampleRate );
		newBuffer.getChannelData(0).set(buffers[0]);
		newBuffer.getChannelData(1).set(buffers[1]);
		//newSource.buffer = null;

		newSource.buffer = newBuffer;

		newSource.connect( audio_context.destination );
		newSource.start();
		recorder.clear()
		});
	}
	function rec(){
		recorder.getBuffer(function(buffers) {
        //process(buffers)
		audioData.input(buffers[0]);
		var w = audioData.encodeWAV();
		process(w);
		recorder.clear()
		});
	}
	function start() {
		if(started)
			return;
		started=true;
		recorder.record();
		var newSource// = audio_context.createBufferSource();
		var newBuffer;
		var has=0;
		timer = setInterval(rec, 1000);
	}

	function stop(){
		if(!started)
			return;
		started=false;
		clearInterval(timer);
	}
	
	function startmedia(stream){
		console.log("start audio record");
		try{
			audio_context = new AudioContext;
		} catch (e) {
			console.log(e);
		}
		input = audio_context.createMediaStreamSource(stream);    
		//input.connect(audio_context.destination);    
		recorder = new Recorder(input);
	}
	this.startrec = start;
	this.stoprec = stop;
	function mediaerror(){}
	navigator.getUserMedia({audio:true},startmedia,mediaerror); 
}