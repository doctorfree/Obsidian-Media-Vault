---
banner: "assets/banners/Beets-Banner.png"
banner_x: 0.5
banner_y: 0.5
---

# Beets Albums released in 1977

This code displays all albums from the Beets folder released in 1977 sorted by artist.

````markdown
```dataview
TABLE WITHOUT ID
  artist AS "Artist",
  album AS "Album",
  year AS "Year"
FROM "Beets"
WHERE artist != null AND album != null AND year = 1977
SORT artist ASC
```
````

Output of above code:

```dataview
TABLE WITHOUT ID
  artist AS "Artist",
  album AS "Album",
  year AS "Year"
FROM "Beets"
WHERE artist != null AND album != null AND year = 1977
SORT artist ASC
```
