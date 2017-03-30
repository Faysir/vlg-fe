$ ->
  try
    window.AudioContext = window.AudioContext || window.webkitAudioContext
    navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia
    window.URL = window.URL || window.webkitURL
  catch e
    console.log(e)

window.Qrecorder = (process) ->
  audio_context = null
  recorder = null
  input = null
  started = false
  timer = null
  config = {}
  config.sampleBits = 16 # config.sampleBits || 8;      //采样数位 8, 16
  config.sampleRate = 44100 / 6   # 采样率(1/6 44100)

  audioData =
    size: 0           # 录音文件长度
    buffer: []        # 录音缓存
    inputSampleRate: 44100 / 6 # audio_context.sampleRate     # 输入采样率
    inputSampleBits: 16        # 输入采样数位 8, 16
    outputSampleRate: config.sampleRate     # 输出采样率
    oututSampleBits: config.sampleBits        # 输出采样数位 8, 16

    input: (data) ->
      # this.buffer.push(new Float32Array(data));
      this.buffer.push(data)
      this.size += data.length
      return

    compress: () -> # 合并压缩
      # 合并
      data = new Float32Array(this.size)
      offset = 0
      for item_buffer in this.buffer
        data.set(item_buffer, offset)
        offset += item_buffer.length
      # console.log(this.buffer.length);
      # console.log(this.size);
      # var length = data.length
      return data;
      # 压缩
      compression = parseInt(this.inputSampleRate / this.outputSampleRate)
      length = data.length / compression
      result = new Float32Array(length)
      index = 0
      j = 0
      while index < length
        result[index] = data[j]
        j += compression
        index++
      return result

    encodeWAV: () ->
      sampleRate = Math.min(this.inputSampleRate, this.outputSampleRate)
      sampleBits = Math.min(this.inputSampleBits, this.oututSampleBits)
      bytes = this.compress()
      dataLength = bytes.length * (sampleBits / 8)
      buffer = new ArrayBuffer(44 + dataLength)
      data = new DataView(buffer)

      channelCount = 1 # 单声道
      offset = 0

      writeString = (str) ->
        for ch, i in str
          data.setUint8(offset + i, str.charCodeAt(i))
      
      # 资源交换文件标识符 
      writeString('RIFF')
      offset += 4
      # 下个地址开始到文件尾总字节数,即文件大小-8 
      data.setUint32(offset, 36 + dataLength, true)
      offset += 4
      # WAV文件标志
      writeString('WAVE')
      offset += 4
      # 波形格式标志 
      writeString('fmt ')
      offset += 4
      # 过滤字节,一般为 0x10 = 16 
      data.setUint32(offset, 16, true)
      offset += 4
      # 格式类别 (PCM形式采样数据) 
      data.setUint16(offset, 1, true)
      offset += 2
      # 通道数 
      data.setUint16(offset, channelCount, true)
      offset += 2
      # 采样率,每秒样本数,表示每个通道的播放速度 
      data.setUint32(offset, sampleRate, true)
      offset += 4
      # 波形数据传输率 (每秒平均字节数) 单声道×每秒数据位数×每样本数据位/8 
      data.setUint32(offset, channelCount * sampleRate * (sampleBits / 8), true)
      offset += 4
      # 快数据调整数 采样一次占用字节数 单声道×每样本的数据位数/8 
      data.setUint16(offset, channelCount * (sampleBits / 8), true)
      offset += 2
      # 每样本数据位数 
      data.setUint16(offset, sampleBits, true)
      offset += 2
      # 数据标识符 
      writeString('data')
      offset += 4
      # 采样数据总数,即数据总大小-44 
      data.setUint32(offset, dataLength, true)
      offset += 4
      # 写入采样数据 
      if sampleBits == 8
        for abyte in bytes
          s = Math.max(-1, Math.min(1, abyte))
          val = s < 0 ? s * 0x8000 : s * 0x7FFF
          val = parseInt(255 / (65535 / (val + 32768)))
          data.setInt8(offset, val, true)
          offset++
      else
        for abyte in bytes
          s = Math.max(-1, Math.min(1, abyte))
          data.setInt16(offset, s < 0 ? s * 0x8000 : s * 0x7FFF, true)
          offset += 2
      this.buffer=[]
      this.size=0
      return new Blob([data], { type: 'audio/wav' })

  rec2 = () ->
    recorder.getBuffer (buffers) ->
      process(buffers)
      newSource = audio_context.createBufferSource()
      newBuffer = audio_context.createBuffer( 2, buffers[0].length, audio_context.sampleRate )
      newBuffer.getChannelData(0).set(buffers[0])
      newBuffer.getChannelData(1).set(buffers[1])
      # newSource.buffer = null

      newSource.buffer = newBuffer

      newSource.connect( audio_context.destination )
      newSource.start()
      recorder.clear()
  
  rec = () ->
    recorder.getBuffer (buffers) ->
      # process(buffers)
      audioData.input(buffers[0])
      w = audioData.encodeWAV()
      process(w)
      recorder.clear()

  _check_and_start_timer = 0
  start = () ->
    return if started
    _check_and_start = () ->
      if _check_and_start_timer > 0 then clearTimeout _check_and_start_timer
      if recorder
        started = true
        recorder.record()
        newSource = undefined # = audio_context.createBufferSource();
        newBuffer = undefined
        has = 0
        timer = setInterval(rec, 1000)
      else
        _check_and_start_timer = setTimeout _check_and_start, 100
    _check_and_start()

  stop = () ->
    return unless started
    started = false
    clearInterval(timer)
  
  startmedia = (stream) ->
    console.log("start audio record");
    try
      audio_context = new AudioContext()
    catch e
      console.error(e)
    input = audio_context.createMediaStreamSource(stream)
    # input.connect(audio_context.destination)
    workerPath = document.location.pathname.replace(/[^\.]+\.[^\.]+$/, '')
    workerPath += "vendor/scripts/recorderWorker.js"
    recorder = new Recorder(input, { workerPath: workerPath })

  this.startrec = start
  this.stoprec = stop

  mediaerror = (e) ->
    console.error "Failed to initialize audio recorder", e
    return

  navigator.getUserMedia({audio:true}, startmedia, mediaerror)

# `function Qrecorder() { _Qrecorder.apply(undefined, arguments); }`
