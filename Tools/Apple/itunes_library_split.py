import pandas as pd
import xml.etree.ElementTree as ET ## XML parsing

lib = r'data/Library.xml'

tree = ET.parse(lib)
root = tree.getroot()
main_dict=root.findall('dict')
for item in list(main_dict[0]):
    if item.tag=="dict":
        tracks_dict=item
        break

tracklist=list(tracks_dict.findall('dict'))

podcast=[] #All podcast elements
purchased=[] # All purchased music
apple_music=[] # Music added to lirary through subscription
for item in tracklist:
    x=list(item)
    for i in range(len(x)):
        if x[i].text=="Genre" and x[i+1].text=="Podcast": #          
            podcast.append(list(item))
        if x[i].text=="Kind" and x[i+1].text=="Purchased AAC audio file":
            purchased.append(list(item)) 
        if x[i].text=="Kind" and x[i+1].text=="Apple Music AAC audio file":
            apple_music.append(list(item))

print ("Number of tracks under Podcast: ",str(len(podcast)))
print ("Number of tracks Purchased: ",str(len(purchased)))
print ("Number of Music added thought Apple Music subscription: ",str(len(apple_music)))
