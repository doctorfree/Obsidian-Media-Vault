columns_of_interest=['track_id','song_name','play_count','skip_count','album','artist' \
 ,'genre','kind','persistent_id','year_of_release','play_date','skip_date',\
 'release_date','date_modified']
temp_apple = df_apple_music.loc[:,['Track ID','Name','Play Count','Skip Count','Album',\
 'Artist','Genre','Kind','Persistent ID','Year','Play Date UTC',\
 'Skip Date','Release Date','Date Modified']]
temp_purchased = df_purchased.loc[:,['Track ID','Name','Play Count','Skip Count', \
 'Album','Artist','Genre','Kind','Persistent ID','Year',\
 'Play Date UTC','Skip Date','Release Date','Date Modified']]
df_songs = pd.concat([temp_purchased,temp_apple],axis = 0)
df_songs.columns = columns_of_interest

df_songs[['track_id','play_count','skip_count','year_of_release']] = df_songs[['track_id',\
        'play_count','skip_count','year_of_release']].apply(pd.to_numeric)
df_songs[['play_date','skip_date','release_date','date_modified']] = df_songs[['play_date',\
        'skip_date','release_date','date_modified']].apply(pd.to_datetime)