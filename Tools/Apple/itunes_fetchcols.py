def cols(kind):
    cols=[]
    for i in range(len(kind)):
        for j in range(len(kind[i])):
            if kind[i][j].tag=="key":
                cols.append(kind[i][j].text)
    return set(cols)

podcast_cols=cols(podcast)
purchased_cols=cols(purchased)
apple_music_cols=cols(apple_music)