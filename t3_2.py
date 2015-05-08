def ex2(frase):
  
#Data
    artigo = {"o":"s m", "a":"s f","os":"p m","as":"p f", "O":"s m", "A":"s f","Os":"p m","As":"p f"}
    substantivo = {"tempo":"s m", "cacador":"s m", "rio":"s m", "rosto":"s m", "mar":"s m", "vento":"s m", "martelo":"s m", "cachorro":"s m", "tambor":"s m", "sino":"s m", "lobos":"p m", "tambores":"p m","menina":"s f", "floresta":"s f", "mae":"s f", "vida":"s f", "noticia":"s f", "cidade":"s f", "porta":"s f", "lagrimas":"p f"}
    verbo = {"corre":"s", "correu":"s", "bateu":"s","correram":"p", "corriam":"p", "batiam":"p", "bateram":"p"}
    preposicao = {"para":"", "pela":"s f", "com":"", "pelo":"s m", "a":"s f", "no":"s m","na":"s f"}

  
#Helpers
    fraseNominal = []
    fraseVerbal = []
    numero = ""
    ffinal = ""
  

#Creates nominal and verbal phrases
    i=0
    while i != len(frase):
        if frase[i] not in verbo.keys():
            i+=1
        else:
            fraseNominal = frase[:i]
            fraseVerbal = frase[i:]
            i=len(frase)
  
#Tests if prahse is nominal, test if is valid, and classifies words 
    if len(fraseNominal) <= 1:
        return "Frase Invalida"
  
    if len(fraseNominal) == 2:
        if fraseNominal[0] not in artigo.keys() or fraseNominal[1] not in substantivo.keys():
            return "Frase Invalida"
        else:
            numero = artigo[fraseNominal[0]]
            ffinal = ffinal + "frase_nom(artigo('"
              
        if numero != substantivo[fraseNominal[1]]:
            return "Frase Invalida"
        else:
            ffinal = ffinal +fraseNominal[0]+"'),substantivo('"+fraseNominal[1]+"'))"
  
  
  
    if verbo[fraseVerbal[0]] != numero[0]:
            return "Frase Invalida"
              
#tests verbal phrase with just one word
    if len(fraseVerbal) == 1:
        if fraseVerbal[0] not in verbo.keys():
            return "Frase Invalida"
        else:
            return ffinal + ",frase_verbal(verbo('"+fraseVerbal[0]+"'))"
  
  
  
      
    ffinal = ffinal + ",frase_verbal(verbo('"+fraseVerbal[0]+"')"
    fraseVerbal.pop(0)
	
#tests complement after withdrawal the verb
    if len(fraseVerbal)>3 or len(fraseVerbal)<2:
        return "Frase invalida"
      
#Cases with 2 words
    if len(fraseVerbal)==2:
        if fraseVerbal[0] in artigo.keys():
            numero = artigo[fraseVerbal[0]]
            ffinal = ffinal +",artigo('"+fraseVerbal[0]+"')"
        elif fraseVerbal[0] in preposicao.keys():
            numero = preposicao[fraseVerbal[0]]
            ffinal = ffinal +",preposicao('"+fraseVerbal[0]+"')"
        else:
            return "Frase Invalida"
              
  
        if fraseVerbal[1] not in substantivo.keys():
            return "Frase Invalida"
        elif substantivo[fraseVerbal[1]] != numero:
            return "Frase Invalida"
        else:
            ffinal = ffinal +",substantivo('"+fraseVerbal[1]+"'))"
       
  
#Cases with 3 words
    if len(fraseVerbal)==3:
        if fraseVerbal[0] not in preposicao.keys() or fraseVerbal[1] not in artigo.keys() and fraseVerbal[2] not in substantivo.keys():
            return "Frase Invalida"
  
        if fraseVerbal[0] in preposicao.keys():
            ffinal = ffinal +",preposicao('"+fraseVerbal[0]+"')"
              
        if fraseVerbal[1] in artigo.keys():
            numero = artigo[fraseVerbal[1]]
            ffinal = ffinal +",artigo('"+fraseVerbal[1]+"')"
  
        if fraseVerbal[2] in substantivo.keys():
            if substantivo[fraseVerbal[2]] != numero:
                return "Frase Invalida"
            else:
                ffinal = ffinal +",substantivo('"+fraseVerbal[2]+"'))"
           
  
    ffinal = ffinal + ")"
    return ffinal
             
#Init program
print "Apenas contem as palavras presentes nas frases de teste do enunciado.\n"
print "Exemplo: A menina bateu no tambor"
frase = raw_input("Insira uma frase: ")
frase = frase.split(" ")
print "sent("+ex2(frase)+")"
