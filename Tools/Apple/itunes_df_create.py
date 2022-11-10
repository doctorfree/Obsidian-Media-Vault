def df_creation(kind,cols):
    df=pd.DataFrame(columns=cols)
    dict1={}
    for i in range(len(kind)):
        for j in range(len(kind[i])):
            if kind[i][j].tag=="key":
                dict1[kind[i][j].text]=kind[i][j+1].text
        list_values=[i for i in dict1.values()]
        list_keys=[j for j in dict1.keys()]
        df_temp=pd.DataFrame([list_values],columns=list_keys)
        df = pd.concat([df,df_temp],axis=0,ignore_index=True,sort=True)
    return df
df_apple_music = df_creation(apple_music,apple_music_cols)
df_podcast = df_creation(podcast,podcast_cols)
df_purchased = df_creation(purchased,purchased_cols)