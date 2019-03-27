extends Node

export (NodePath) var hfp
export (NodePath) var hfp_file
export (NodePath) var srt
export (NodePath) var srt_file
export (NodePath) var insert

var hfp_text
var srt_text

var sub_size = 0
var subtitles = []

#Start Key
var key_i = '<Name>text</Name><Default V="4"><st>Text</st></Default><Static V="4"><st>Text</st></Static>'
var keyl = str('<Name>text</Name><Default V="4"><st>Text</st></Default><Static V="4"><st>Text</st></Static>').length()

#Begin with TAG <Animation>
var key0 = ['<Key Ti="',0,'" Tp="2" STp="2" V="5"><TLk>0</TLk><SLk>0</SLk><Vl V="4"><st>',"oi tudo bem gente",'</st></Vl></Key>']
#Ends with </Animation></Prop>



func _ready():
	hfp = get_node(hfp)
	hfp_file = get_node(hfp_file)
	srt = get_node(srt)
	srt_file = get_node(srt_file)


func _on_Button_HFP_pressed():
	if hfp_file is FileDialog:
		hfp_file.show()
		enable_controls(false)


func _on_FileDialog_HFP_file_selected(path):
	hfp.get_node("LineEdit_HFP").text = path
	hfp_file.hide()
	open_hfp(path)

func open_hfp(path):
	var file = File.new()
	file.open(path,File.READ)
	hfp_text = file.get_as_text()
	file.close()
	hfp_find_tag(path)

func hfp_find_tag(path):
	var i1 = str(hfp_text).findn("<Name>Subtitle</Name>")
	var i2 = str(hfp_text).findn("<Name>Subtitle</Name>",i1)
	var i3 = str(hfp_text).findn("<st>Text</st>",i2)
	var erase1 = str(hfp_text).findn("<Animation>",i3)
	var erase2 = str(hfp_text).findn("</Animation>",i3)
	
	if i1 != -1 and i2 != -1 and i3 != -1:
		if erase1 != -1 or erase2 != -1:
			var remove = str(hfp_text).substr(erase1 , (erase2-erase1)+12 )
			hfp_text = str(hfp_text).replacen(remove,"")

	else:
		$Error.show()
		$Error.on_error("Invalid! Please, create a Panel \n with the name Subtitle")
		hfp.get_node("LineEdit_HFP").text = ""
	
#	var new_text = hfp_text
	
	#Formata o arquivo com \n entre as linhas
#	if str(hfp_text).rfindn("\n") == 38:
#		new_text = ""
#		var array = str(hfp_text).split("</Prop>")
#		for i in range(array.size()):
#			array[i] = str(array[i],"\n")
#
#		for i in range(array.size()):
#			new_text = str(new_text,array[i])
#
#	hfp_text = new_text


func enable_controls(b : bool):
	if b:
		hfp.get_node("Button_HFP").disabled = false
		srt.get_node("Button_SRT").disabled = false
	else:
		hfp.get_node("Button_HFP").disabled = true
		srt.get_node("Button_SRT").disabled = true

func _on_FileDialog_HFP_hide():
	enable_controls(true)

func _on_Button_SRT_pressed():
	if srt_file is FileDialog:
		srt_file.show()
		enable_controls(false)

func _on_FileDialog_SRT_file_selected(path):
	srt.get_node("LineEdit_SRT").text = path
	srt_file.hide()
	open_srt(path)
	
func open_srt(path):
	var file = File.new()
	file.open(path,File.READ)
	srt_text = file.get_as_text()
	file.close()
	srt.get_node("LineEdit_SRT").text = path
	srt_find_tag(path)

func _on_FileDialog_SRT_hide():
	enable_controls(true)
	
func srt_find_tag(path):
	var find = "\n\n"
	var srt_array = str(srt_text).split(find)
	subtitles.clear()
	
	for x in range(srt_array.size() ):
		subtitles.append([])
		for y in range(2):
			subtitles[x].append("")

	for i in range(srt_array.size() ):
		var ti = str(srt_array[i]).substr(2,13)  # Tempo
		ti = str(ti).replacen(":","")
		ti = str(ti).replacen(",","")
		ti = float(ti)
		var text =  str(str(srt_array[i]).substr(    32  ,     str(srt_array[i]).length() -32 )).strip_edges()  # Texto
		subtitles[i][0] = text
		subtitles[i][1] = ti
		sub_size += 1

func _on_InsertSubtitles_pressed():
	subtitles.invert()
	for i in range(sub_size):
		var index = str(hfp_text).findn(key_i)+keyl
		
		if i == 0 : #Insere a Tag Fechando
			hfp_text = str(hfp_text).insert(index,"</Animation>\n")
		
		##Insere o Texto
		hfp_text = str(hfp_text).insert(index,str(key0[0],subtitles[i][1],key0[2],subtitles[i][0],key0[4],"\n") )
		
		if i == sub_size-1: #Insere a Tag Abrindo
			print(str("Ok ",i) )
			hfp_text = str(hfp_text).insert(index,"<Animation>\n")
			
	var file = File.new()
	file.open(hfp.get_node("LineEdit_HFP").text,File.WRITE)
	file.store_string(hfp_text)
	file.close()
	sub_size = 0
	$Error.show()
	$Error.on_error("Success! Subtitles created \n within the file.")
	hfp.get_node("LineEdit_HFP").text = ""
	srt.get_node("LineEdit_SRT").text = ""
	
	pass # Replace with function body.
