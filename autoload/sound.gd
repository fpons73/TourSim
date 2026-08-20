extends Node
## Sound — efectos de sonido básicos generados proceduralmente (sin assets).

var _click: AudioStreamWAV
var _finish: AudioStreamWAV
var _player: AudioStreamPlayer

func _ready() -> void:
	_click = _make_beep(880.0, 0.06)
	_finish = _make_beep(523.0, 0.35)
	_player = AudioStreamPlayer.new()
	add_child(_player)

func play_click() -> void:
	if Config.sound_enabled:
		_player.stream = _click
		_player.play()

func play_finish() -> void:
	if Config.sound_enabled:
		_player.stream = _finish
		_player.play()

static func _make_beep(freq: float, duration: float) -> AudioStreamWAV:
	var sample_rate := 22050
	var n := int(duration * sample_rate)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t := float(i) / sample_rate
		var env := 1.0 - float(i) / n
		var sample := int(sin(TAU * freq * t) * 32767.0 * env * 0.4)
		data.encode_s16(i * 2, sample)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = data
	return wav
