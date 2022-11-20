---
banner: "assets/banners/Beets-Banner.png"
banner_x: 0.5
banner_y: 0.5
---

# All Beets Albums

This code displays all albums from the Beets folder sorted by artist.

````markdown
```dataview
TABLE WITHOUT ID
  artist AS "Artist",
  album AS "Album",
  year AS "Year"
FROM "Beets"
WHERE artist != null AND album != null
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
WHERE artist != null AND album != null
SORT artist ASC
```
